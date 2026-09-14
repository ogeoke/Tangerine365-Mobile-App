import 'dart:typed_data';

import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'loan_calculator_page.dart';

/// Groups an integer with thousands separators and an "NGN " prefix. The PDF
/// uses "NGN" rather than the ₦ glyph because the built-in PDF fonts don't
/// carry the naira sign; "NGN 5,000,000" is unambiguous and needs no embedded
/// (variable) font.
String _ngn(double v) {
  final n = v.round();
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return 'NGN ${n < 0 ? '-' : ''}$buf';
}

String _pct(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

String _methodLabel(InterestMethod m) => m == InterestMethod.reducingBalance
    ? 'Reducing balance'
    : 'Flat rate';

/// Builds a bank-grade loan repayment schedule PDF from a [LoanEstimate]:
/// a summary of terms followed by the full amortization table, paginated
/// automatically. Returns the raw PDF bytes.
Future<Uint8List> buildLoanSchedulePdf(LoanEstimate e) async {
  final doc = pw.Document();

  const green = PdfColor.fromInt(0xFF397B27);
  const ink = PdfColor.fromInt(0xFF141A21);
  const grey = PdfColor.fromInt(0xFF6B7385);
  const light = PdfColor.fromInt(0xFFEBF6E7);

  pw.Widget summaryRow(String k, String v, {bool bold = false}) => pw.Padding(
        padding: const pw.EdgeInsets.symmetric(vertical: 3),
        child: pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          children: [
            pw.Text(k, style: const pw.TextStyle(color: grey, fontSize: 10)),
            pw.Text(v,
                style: pw.TextStyle(
                    color: ink,
                    fontSize: 10,
                    fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal)),
          ],
        ),
      );

  final freq = e.frequency.name; // weekly / monthly / quarterly

  doc.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(28),
      header: (context) => context.pageNumber == 1
          ? pw.SizedBox()
          : pw.Container(
              alignment: pw.Alignment.centerRight,
              margin: const pw.EdgeInsets.only(bottom: 8),
              child: pw.Text('Loan Repayment Schedule',
                  style: const pw.TextStyle(color: grey, fontSize: 9)),
            ),
      footer: (context) => pw.Container(
        alignment: pw.Alignment.centerRight,
        margin: const pw.EdgeInsets.only(top: 8),
        child: pw.Text('Page ${context.pageNumber} of ${context.pagesCount}',
            style: const pw.TextStyle(color: grey, fontSize: 9)),
      ),
      build: (context) => [
        // Title
        pw.Text('Loan Repayment Estimate',
            style: pw.TextStyle(
                color: ink, fontSize: 20, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 2),
        pw.Text('Tangerine365 — indicative estimate',
            style: const pw.TextStyle(color: green, fontSize: 11)),
        pw.SizedBox(height: 16),

        // Summary
        pw.Container(
          padding: const pw.EdgeInsets.all(14),
          decoration: pw.BoxDecoration(
            color: light,
            borderRadius: pw.BorderRadius.circular(8),
          ),
          child: pw.Column(
            children: [
              summaryRow('Loan amount', _ngn(e.principal)),
              summaryRow('Annual interest rate', '${_pct(e.annualRatePct)}% p.a.'),
              summaryRow('Interest method', _methodLabel(e.method)),
              summaryRow('Repayment frequency',
                  '${freq[0].toUpperCase()}${freq.substring(1)}'),
              summaryRow('Tenure', '${e.tenureMonths} months'),
              summaryRow('Number of payments', '${e.payments}'),
              pw.Divider(color: PdfColors.grey400),
              summaryRow('Repayment per period', _ngn(e.perPayment), bold: true),
              summaryRow('Total interest', _ngn(e.totalInterest)),
              if (e.managementFee > 0)
                summaryRow('Management fee', _ngn(e.managementFee)),
              if (e.insurance > 0) summaryRow('Insurance', _ngn(e.insurance)),
              summaryRow('Effective rate (APR)',
                  '${_pct(e.effectiveAnnualRatePct)}%', bold: true),
              summaryRow('Total cost of credit', _ngn(e.totalCostOfCredit)),
              summaryRow('Total repayment', _ngn(e.totalRepayment), bold: true),
            ],
          ),
        ),
        pw.SizedBox(height: 18),

        pw.Text('Amortization schedule',
            style: pw.TextStyle(
                color: ink, fontSize: 13, fontWeight: pw.FontWeight.bold)),
        pw.SizedBox(height: 8),

        pw.TableHelper.fromTextArray(
          headerStyle: pw.TextStyle(
              color: ink, fontSize: 9, fontWeight: pw.FontWeight.bold),
          headerDecoration: const pw.BoxDecoration(color: light),
          cellStyle: const pw.TextStyle(color: ink, fontSize: 9),
          cellAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          headerAlignments: {
            0: pw.Alignment.centerLeft,
            1: pw.Alignment.centerRight,
            2: pw.Alignment.centerRight,
            3: pw.Alignment.centerRight,
            4: pw.Alignment.centerRight,
          },
          border: pw.TableBorder.all(color: PdfColors.grey300, width: 0.5),
          headers: ['#', 'Payment', 'Principal', 'Interest', 'Balance'],
          data: e.schedule
              .map((r) => [
                    '${r.index}',
                    _ngn(r.payment),
                    _ngn(r.principal),
                    _ngn(r.interest),
                    _ngn(r.balance),
                  ])
              .toList(),
        ),
        pw.SizedBox(height: 14),
        pw.Text(
          'Estimate only. Fees, insurance and bank charges shown are '
          'indicative; final terms are determined by the bank.',
          style: const pw.TextStyle(color: grey, fontSize: 9),
        ),
      ],
    ),
  );

  return doc.save();
}

/// Builds the schedule PDF and opens the system share/print sheet.
Future<void> shareLoanSchedule(LoanEstimate e) async {
  final bytes = await buildLoanSchedulePdf(e);
  await Printing.sharePdf(bytes: bytes, filename: 'loan-repayment-schedule.pdf');
}
