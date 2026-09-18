import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/module_header.dart';
import 'package:sevenup_mobile/common/nav_drawer.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/views/loan_pdf.dart';

/// How often repayments are made. [perYear] derives the periodic interest rate
/// and the number of payments from a tenure expressed in months.
enum RepaymentFrequency { weekly, monthly, quarterly }

extension on RepaymentFrequency {
  String get label => switch (this) {
        RepaymentFrequency.weekly => 'Weekly',
        RepaymentFrequency.monthly => 'Monthly',
        RepaymentFrequency.quarterly => 'Quarterly',
      };

  String get adjective => switch (this) {
        RepaymentFrequency.weekly => 'weekly',
        RepaymentFrequency.monthly => 'monthly',
        RepaymentFrequency.quarterly => 'quarterly',
      };

  double get perYear => switch (this) {
        RepaymentFrequency.weekly => 52,
        RepaymentFrequency.monthly => 12,
        RepaymentFrequency.quarterly => 4,
      };
}

/// How interest is charged. Reducing balance charges interest on the
/// outstanding balance (amortized). Flat rate charges interest on the original
/// principal for the whole tenure — higher total interest for the same rate.
enum InterestMethod { reducingBalance, flat }

extension on InterestMethod {
  String get label => switch (this) {
        InterestMethod.reducingBalance => 'Reducing balance',
        InterestMethod.flat => 'Flat rate',
      };
}

/// One line of the amortization schedule.
class AmortRow {
  final int index;
  final double payment;
  final double principal;
  final double interest;
  final double balance;
  const AmortRow(
      this.index, this.payment, this.principal, this.interest, this.balance);
}

/// The result of a loan calculation, including a full amortization schedule
/// and the effective annual rate (APR) reflecting any upfront fees.
class LoanEstimate {
  final double principal;
  final double annualRatePct;
  final int tenureMonths;
  final RepaymentFrequency frequency;
  final InterestMethod method;
  final int payments;
  final double perPayment;
  final double totalInterest;
  final double managementFee;
  final double insurance;
  final double totalFees;
  final double totalRepayment; // principal + interest (sum of installments)
  final double totalCostOfCredit; // interest + fees
  final double effectiveAnnualRatePct; // APR
  final List<AmortRow> schedule;

  const LoanEstimate({
    required this.principal,
    required this.annualRatePct,
    required this.tenureMonths,
    required this.frequency,
    required this.method,
    required this.payments,
    required this.perPayment,
    required this.totalInterest,
    required this.managementFee,
    required this.insurance,
    required this.totalFees,
    required this.totalRepayment,
    required this.totalCostOfCredit,
    required this.effectiveAnnualRatePct,
    required this.schedule,
  });

  factory LoanEstimate.compute({
    required double principal,
    required double annualRatePct,
    required int tenureMonths,
    required RepaymentFrequency frequency,
    required InterestMethod method,
    double managementFeePct = 0,
    double insurance = 0,
  }) {
    final n = math.max(1, (tenureMonths / 12 * frequency.perYear).round());
    final r = (annualRatePct / 100) / frequency.perYear; // periodic rate

    // Level per-period payment.
    double perExact;
    if (method == InterestMethod.flat) {
      final years = tenureMonths / 12;
      final flatInterest = principal * (annualRatePct / 100) * years;
      perExact = (principal + flatInterest) / n;
    } else if (r == 0) {
      perExact = principal / n;
    } else {
      final pow = math.pow(1 + r, n).toDouble();
      perExact = principal * r * pow / (pow - 1);
    }

    final perRounded = perExact.roundToDouble();
    final totalRepayment = perRounded * n;
    final totalInterest = totalRepayment - principal;

    // Amortization schedule (doubles; final row clears the balance to zero).
    final schedule = <AmortRow>[];
    double balance = principal;
    if (method == InterestMethod.flat) {
      final principalPer = principal / n;
      final interestPer = totalInterest / n;
      for (var k = 1; k <= n; k++) {
        final principalPart = (k < n) ? principalPer : balance;
        final pay = principalPart + interestPer;
        balance -= principalPart;
        if (balance < 0) balance = 0;
        schedule.add(AmortRow(k, pay, principalPart, interestPer, balance));
      }
    } else {
      for (var k = 1; k <= n; k++) {
        final interest = balance * r;
        double principalPart = perRounded - interest;
        double pay = perRounded;
        if (k == n || principalPart > balance) {
          principalPart = balance;
          pay = principalPart + interest;
        }
        balance -= principalPart;
        if (balance < 0) balance = 0;
        schedule.add(AmortRow(k, pay, principalPart, interest, balance));
      }
    }

    final managementFee = principal * (managementFeePct / 100);
    final totalFees = managementFee + insurance;

    // Effective annual rate (APR): the periodic IRR i solving
    //   (principal − upfront fees) = perExact · (1 − (1+i)^−n) / i
    // then annualized. Fees reduce net proceeds, so they raise the APR.
    final net = principal - totalFees;
    final apr = _effectiveAnnualRate(
      net: net,
      payment: perExact,
      n: n,
      periodsPerYear: frequency.perYear,
    );

    return LoanEstimate(
      principal: principal,
      annualRatePct: annualRatePct,
      tenureMonths: tenureMonths,
      frequency: frequency,
      method: method,
      payments: n,
      perPayment: perRounded,
      totalInterest: totalInterest,
      managementFee: managementFee,
      insurance: insurance,
      totalFees: totalFees,
      totalRepayment: totalRepayment,
      totalCostOfCredit: totalInterest + totalFees,
      effectiveAnnualRatePct: apr,
      schedule: schedule,
    );
  }
}

/// Solves for the periodic internal rate of return via bisection, then
/// annualizes it. Returns a percentage. Falls back to 0 when there is no cost.
double _effectiveAnnualRate({
  required double net,
  required double payment,
  required int n,
  required double periodsPerYear,
}) {
  if (net <= 0 || payment <= 0) return 0;
  if (payment * n <= net) return 0; // nothing paid beyond what was received

  double pv(double i) => payment * (1 - math.pow(1 + i, -n)) / i;

  double lo = 1e-9;
  double hi = 1.0; // 100% per period upper guess
  // Expand the upper bound until PV drops below net (guaranteed bracket).
  var guard = 0;
  while (pv(hi) > net && guard < 60) {
    hi *= 2;
    guard++;
  }
  for (var k = 0; k < 200; k++) {
    final mid = (lo + hi) / 2;
    if (pv(mid) > net) {
      lo = mid;
    } else {
      hi = mid;
    }
  }
  final i = (lo + hi) / 2;
  return (math.pow(1 + i, periodsPerYear) - 1) * 100;
}

/// Groups an integer amount with thousands separators and an "NGN " prefix,
/// e.g. 5990904 → "NGN 5,990,904". Uses the "NGN" code rather than the ₦ glyph
/// because the bundled Manrope font has no naira sign (it renders as tofu).
/// Also avoids pulling in `intl` (only a transitive dep).
String formatNaira(double value) => 'NGN ${_grouped(value.round())}';

String _grouped(int n) {
  final digits = n.abs().toString();
  final buf = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
    buf.write(digits[i]);
  }
  return '${n < 0 ? '-' : ''}$buf';
}

String _trimPct(double v) =>
    v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);

/// Loan Calculator input (Figma 19F, extended to bank-grade). Fully functional
/// — no backend. Adds an interest-method toggle and optional fees on top of
/// the amount / rate / tenure / frequency inputs.
class LoanCalculatorPage extends StatefulWidget {
  const LoanCalculatorPage({super.key});

  @override
  State<LoanCalculatorPage> createState() => _LoanCalculatorPageState();
}

class _LoanCalculatorPageState extends State<LoanCalculatorPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _amount = TextEditingController(text: '5,000,000');
  final _rate = TextEditingController(text: '18');
  final _tenure = TextEditingController(text: '24');
  final _fee = TextEditingController(text: '1');
  final _insurance = TextEditingController();
  RepaymentFrequency _frequency = RepaymentFrequency.monthly;
  InterestMethod _method = InterestMethod.reducingBalance;

  String? _amountError;
  String? _rateError;
  String? _tenureError;

  @override
  void dispose() {
    _amount.dispose();
    _rate.dispose();
    _tenure.dispose();
    _fee.dispose();
    _insurance.dispose();
    super.dispose();
  }

  double? _parseAmount(String s) {
    final cleaned = s.replaceAll(RegExp(r'[^0-9.]'), '');
    if (cleaned.isEmpty) return null;
    return double.tryParse(cleaned);
  }

  void _calculate() {
    final amount = _parseAmount(_amount.text);
    final rate = double.tryParse(_rate.text.replaceAll('%', '').trim());
    final tenure = int.tryParse(_tenure.text.replaceAll(RegExp(r'[^0-9]'), ''));
    final feePct = double.tryParse(_fee.text.replaceAll('%', '').trim()) ?? 0;
    final insurance = _parseAmount(_insurance.text) ?? 0;

    setState(() {
      _amountError =
          (amount == null || amount <= 0) ? 'Enter a valid loan amount' : null;
      _rateError =
          (rate == null || rate < 0) ? 'Enter a valid interest rate' : null;
      _tenureError = (tenure == null || tenure <= 0)
          ? 'Enter the tenure in months'
          : null;
    });

    if (_amountError != null || _rateError != null || _tenureError != null) {
      return;
    }

    final estimate = LoanEstimate.compute(
      principal: amount!,
      annualRatePct: rate!,
      tenureMonths: tenure!,
      frequency: _frequency,
      method: _method,
      managementFeePct: feePct < 0 ? 0 : feePct,
      insurance: insurance < 0 ? 0 : insurance,
    );
    FocusScope.of(context).unfocus();
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => LoanEstimatePage(estimate: estimate)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Loan Calculator',
              subtitle: 'Estimate your loan repayment',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 22, AppTokens.screenPadding, 24),
                children: [
                  Text('Enter the proposed loan details below.',
                      style: AppTokens.manrope(
                          size: 15,
                          weight: 400,
                          color: AppTokens.textSecondary)),
                  const SizedBox(height: 22),
                  _Field(
                    label: 'Loan amount',
                    controller: _amount,
                    prefix: 'NGN ',
                    keyboardType: TextInputType.number,
                    inputFormatters: [_ThousandsFormatter()],
                    error: _amountError,
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    label: 'Annual interest rate',
                    controller: _rate,
                    suffix: '%',
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    error: _rateError,
                  ),
                  const SizedBox(height: 18),
                  _Field(
                    label: 'Loan tenure',
                    controller: _tenure,
                    suffix: 'months',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    error: _tenureError,
                  ),
                  const SizedBox(height: 18),
                  Text('Interest method',
                      style: AppTokens.manrope(
                          size: 16,
                          weight: 700,
                          color: AppTokens.textPrimary)),
                  const SizedBox(height: 8),
                  _MethodToggle(
                    value: _method,
                    onChanged: (m) => setState(() => _method = m),
                  ),
                  const SizedBox(height: 18),
                  Text('Repayment frequency',
                      style: AppTokens.manrope(
                          size: 16,
                          weight: 700,
                          color: AppTokens.textPrimary)),
                  const SizedBox(height: 8),
                  _FrequencyDropdown(
                    value: _frequency,
                    onChanged: (f) => setState(() => _frequency = f),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _Field(
                          label: 'Management fee',
                          controller: _fee,
                          suffix: '%',
                          keyboardType: const TextInputType.numberWithOptions(
                              decimal: true),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: _Field(
                          label: 'Insurance',
                          controller: _insurance,
                          prefix: 'NGN ',
                          hint: '0',
                          keyboardType: TextInputType.number,
                          inputFormatters: [_ThousandsFormatter()],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text('Optional — leave blank if not applicable.',
                      style: AppTokens.manrope(
                          size: 13,
                          weight: 400,
                          color: AppTokens.textSecondary)),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: _calculate,
                      child: Text('Calculate repayment',
                          style: AppTokens.manrope(
                              size: 17, weight: 700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'This estimate is indicative only. Final terms are '
                    'determined by the bank.',
                    textAlign: TextAlign.center,
                    style: AppTokens.manrope(
                        size: 13,
                        weight: 400,
                        height: 19,
                        color: AppTokens.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final String? prefix;
  final String? suffix;
  final String? hint;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? error;

  const _Field({
    required this.label,
    required this.controller,
    this.prefix,
    this.suffix,
    this.hint,
    required this.keyboardType,
    this.inputFormatters,
    this.error,
  });

  @override
  Widget build(BuildContext context) {
    final hasError = error != null;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: AppTokens.manrope(
                size: 16, weight: 700, color: AppTokens.textPrimary)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: inputFormatters,
          style: AppTokens.manrope(
              size: 18, weight: 600, color: AppTokens.textPrimary),
          decoration: InputDecoration(
            prefixText: prefix,
            prefixStyle: AppTokens.manrope(
                size: 18, weight: 600, color: AppTokens.textPrimary),
            suffixText: suffix,
            suffixStyle: AppTokens.manrope(
                size: 16, weight: 500, color: AppTokens.textSecondary),
            hintText: hint,
            hintStyle:
                AppTokens.manrope(size: 18, color: AppTokens.placeholder),
            filled: true,
            fillColor: AppTokens.surface,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppTokens.accent : AppTokens.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                  color: hasError ? AppTokens.accent : AppTokens.primary,
                  width: hasError ? 2 : 1),
            ),
          ),
        ),
        if (hasError) ...[
          const SizedBox(height: 6),
          Text(error!,
              style: AppTokens.manrope(
                  size: 13, weight: 600, color: AppTokens.accent)),
        ],
      ],
    );
  }
}

class _MethodToggle extends StatelessWidget {
  final InterestMethod value;
  final ValueChanged<InterestMethod> onChanged;
  const _MethodToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: AppTokens.lightGreen.withOpacity(0.6),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: InterestMethod.values.map((m) {
          final active = m == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(m),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? AppTokens.primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(m.label,
                    style: AppTokens.manrope(
                        size: 14,
                        weight: active ? 700 : 600,
                        color:
                            active ? Colors.white : AppTokens.textSecondary)),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class _FrequencyDropdown extends StatelessWidget {
  final RepaymentFrequency value;
  final ValueChanged<RepaymentFrequency> onChanged;
  const _FrequencyDropdown({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppTokens.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppTokens.border),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<RepaymentFrequency>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down,
              color: AppTokens.textPrimary),
          borderRadius: BorderRadius.circular(14),
          style: AppTokens.manrope(
              size: 18, weight: 600, color: AppTokens.textPrimary),
          items: RepaymentFrequency.values
              .map((f) => DropdownMenuItem(
                    value: f,
                    child: Text(f.label,
                        style: AppTokens.manrope(
                            size: 18,
                            weight: 600,
                            color: AppTokens.textPrimary)),
                  ))
              .toList(),
          onChanged: (f) {
            if (f != null) onChanged(f);
          },
        ),
      ),
    );
  }
}

/// Formats the amount fields with thousands separators as the user types.
class _ThousandsFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return const TextEditingValue(text: '');
    final buf = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buf.write(',');
      buf.write(digits[i]);
    }
    final formatted = buf.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

/// Loan Estimate result (Figma 19G, extended). Headline repayment, a full
/// breakdown including fees + effective rate, and links to the amortization
/// schedule and back to the input.
class LoanEstimatePage extends StatelessWidget {
  final LoanEstimate estimate;
  const LoanEstimatePage({super.key, required this.estimate});

  @override
  Widget build(BuildContext context) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final e = estimate;
    return Scaffold(
      key: scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Loan Estimate',
              subtitle: 'Estimated ${e.frequency.adjective} repayment',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => scaffoldKey.currentState?.openDrawer(),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(
                    AppTokens.screenPadding, 20, AppTokens.screenPadding, 24),
                children: [
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 30),
                    decoration: BoxDecoration(
                      color: AppTokens.primary,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Text(
                          'ESTIMATED ${e.frequency.adjective.toUpperCase()} '
                          'REPAYMENT',
                          textAlign: TextAlign.center,
                          style: AppTokens.manrope(
                              size: 14,
                              weight: 700,
                              color: Colors.white,
                              letterSpacing: 0.5),
                        ),
                        const SizedBox(height: 14),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(formatNaira(e.perPayment),
                              style: AppTokens.manrope(
                                  size: 44,
                                  weight: 700,
                                  color: Colors.white)),
                        ),
                        const SizedBox(height: 12),
                        Text('${e.payments} ${e.frequency.adjective} payments',
                            style: AppTokens.manrope(
                                size: 16, weight: 500, color: Colors.white)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTokens.surface,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppTokens.border),
                    ),
                    child: Column(
                      children: [
                        _Row('Loan amount', formatNaira(e.principal)),
                        _divider(),
                        _Row('Interest rate',
                            '${_trimPct(e.annualRatePct)}% p.a.'),
                        _divider(),
                        _Row('Interest method', e.method.label),
                        _divider(),
                        _Row('Total interest', formatNaira(e.totalInterest)),
                        if (e.managementFee > 0) ...[
                          _divider(),
                          _Row('Management fee', formatNaira(e.managementFee)),
                        ],
                        if (e.insurance > 0) ...[
                          _divider(),
                          _Row('Insurance', formatNaira(e.insurance)),
                        ],
                        _divider(),
                        _Row('Effective rate (APR)',
                            '${_trimPct(e.effectiveAnnualRatePct)}%',
                            emphasize: true),
                        _divider(),
                        _Row('Total cost of credit',
                            formatNaira(e.totalCostOfCredit)),
                        _divider(),
                        _Row('Total repayment', formatNaira(e.totalRepayment),
                            emphasize: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(context).push(
                        MaterialPageRoute(
                            builder: (_) => LoanSchedulePage(estimate: e)),
                      ),
                      child: Text('View repayment schedule',
                          style: AppTokens.manrope(
                              size: 17, weight: 700, color: Colors.white)),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTokens.primary),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14)),
                      ),
                      onPressed: () => Navigator.of(context).maybePop(),
                      child: Text('Adjust loan details',
                          style: AppTokens.manrope(
                              size: 17,
                              weight: 700,
                              color: AppTokens.primary)),
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    'Estimate only. Fees, insurance and bank charges shown are '
                    'indicative; final terms are set by the bank.',
                    textAlign: TextAlign.center,
                    style: AppTokens.manrope(
                        size: 13,
                        weight: 400,
                        height: 19,
                        color: AppTokens.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _divider() => const Divider(height: 1, color: AppTokens.border);
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  final bool emphasize;
  const _Row(this.label, this.value, {this.emphasize = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        children: [
          Flexible(
            child: Text(label,
                style: AppTokens.manrope(
                    size: 15,
                    weight: 400,
                    color: emphasize
                        ? AppTokens.textPrimary
                        : AppTokens.textSecondary)),
          ),
          const SizedBox(width: 12),
          Flexible(
            child: FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerRight,
              child: Text(value,
                  maxLines: 1,
                  textAlign: TextAlign.right,
                  style: AppTokens.manrope(
                      size: emphasize ? 17 : 16,
                      weight: 700,
                      color: emphasize
                          ? AppTokens.primary
                          : AppTokens.textPrimary)),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full amortization schedule (bank-grade addition). A scrollable table of
/// every payment: principal vs interest and the running outstanding balance,
/// with a "Share as PDF" export.
class LoanSchedulePage extends StatefulWidget {
  final LoanEstimate estimate;
  const LoanSchedulePage({super.key, required this.estimate});

  @override
  State<LoanSchedulePage> createState() => _LoanSchedulePageState();
}

class _LoanSchedulePageState extends State<LoanSchedulePage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  bool _sharing = false;

  Future<void> _share() async {
    if (_sharing) return;
    setState(() => _sharing = true);
    try {
      await shareLoanSchedule(widget.estimate);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context)
          ..hideCurrentSnackBar()
          ..showSnackBar(const SnackBar(
              content: Text("Couldn't generate the PDF. Please try again.")));
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.estimate;
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppTokens.screenBg,
      drawer: const NavDrawer(),
      bottomNavigationBar: const AppBottomNav(currentIndex: 3),
      body: SafeArea(
        child: Column(
          children: [
            ModuleHeader(
              title: 'Repayment Schedule',
              subtitle:
                  '${e.payments} ${e.frequency.adjective} payments · ${e.method.label}',
              onBack: () => Navigator.of(context).maybePop(),
              onMenu: () => _scaffoldKey.currentState?.openDrawer(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                  AppTokens.screenPadding, 10, AppTokens.screenPadding, 10),
              child: Align(
                alignment: Alignment.centerRight,
                child: OutlinedButton.icon(
                  onPressed: _sharing ? null : _share,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTokens.primary),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 12),
                  ),
                  icon: _sharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: AppTokens.primary),
                        )
                      : const Icon(Icons.picture_as_pdf_outlined,
                          color: AppTokens.primary, size: 18),
                  label: Text(_sharing ? 'Preparing…' : 'Share as PDF',
                      style: AppTokens.manrope(
                          size: 14, weight: 700, color: AppTokens.primary)),
                ),
              ),
            ),
            _ScheduleHeader(),
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.zero,
                itemCount: e.schedule.length,
                itemBuilder: (_, i) =>
                    _ScheduleRow(row: e.schedule[i], even: i.isEven),
              ),
            ),
            _ScheduleFooter(estimate: e),
          ],
        ),
      ),
    );
  }
}

class _ScheduleHeader extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    TextStyle s() => AppTokens.manrope(
        size: 13, weight: 700, color: AppTokens.textPrimary);
    return Container(
      color: AppTokens.lightGreen.withOpacity(0.5),
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPadding, vertical: 12),
      child: Row(
        children: [
          SizedBox(width: 30, child: Text('#', style: s())),
          Expanded(
              flex: 3,
              child: Text('Payment', textAlign: TextAlign.right, style: s())),
          Expanded(
              flex: 3,
              child:
                  Text('Principal', textAlign: TextAlign.right, style: s())),
          Expanded(
              flex: 3,
              child: Text('Interest', textAlign: TextAlign.right, style: s())),
          Expanded(
              flex: 3,
              child: Text('Balance', textAlign: TextAlign.right, style: s())),
        ],
      ),
    );
  }
}

class _ScheduleRow extends StatelessWidget {
  final AmortRow row;
  final bool even;
  const _ScheduleRow({required this.row, required this.even});

  @override
  Widget build(BuildContext context) {
    TextStyle s({bool bold = false}) => AppTokens.manrope(
        size: 13,
        weight: bold ? 700 : 400,
        color: bold ? AppTokens.textPrimary : AppTokens.textSecondary);
    return Container(
      color: even ? AppTokens.surface : AppTokens.screenBg,
      padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.screenPadding, vertical: 12),
      child: Row(
        children: [
          SizedBox(
              width: 30,
              child: Text('${row.index}', style: s(bold: true))),
          Expanded(
              flex: 3,
              child: Text(_g(row.payment),
                  textAlign: TextAlign.right, style: s(bold: true))),
          Expanded(
              flex: 3,
              child: Text(_g(row.principal),
                  textAlign: TextAlign.right, style: s())),
          Expanded(
              flex: 3,
              child:
                  Text(_g(row.interest), textAlign: TextAlign.right, style: s())),
          Expanded(
              flex: 3,
              child:
                  Text(_g(row.balance), textAlign: TextAlign.right, style: s())),
        ],
      ),
    );
  }

  static String _g(double v) => _grouped(v.round());
}

class _ScheduleFooter extends StatelessWidget {
  final LoanEstimate estimate;
  const _ScheduleFooter({required this.estimate});

  @override
  Widget build(BuildContext context) {
    final e = estimate;
    return Container(
      decoration: const BoxDecoration(
        color: AppTokens.surface,
        border: Border(top: BorderSide(color: AppTokens.border)),
      ),
      padding: const EdgeInsets.fromLTRB(
          AppTokens.screenPadding, 14, AppTokens.screenPadding, 14),
      child: SafeArea(
        top: false,
        child: Row(
          children: [
            Expanded(
              child: _foot('Total principal', formatNaira(e.principal)),
            ),
            Expanded(
              child: _foot('Total interest', formatNaira(e.totalInterest)),
            ),
            Expanded(
              child: _foot('Total repaid', formatNaira(e.totalRepayment)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _foot(String label, String value) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: AppTokens.manrope(
                  size: 12, weight: 400, color: AppTokens.textSecondary)),
          const SizedBox(height: 2),
          Text(value,
              style: AppTokens.manrope(
                  size: 14, weight: 700, color: AppTokens.textPrimary)),
        ],
      );
}
