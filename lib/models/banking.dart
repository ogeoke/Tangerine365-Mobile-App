/// Plain UI models for the Banking Tools module (Forex & Rates, Forms, Loan
/// Calculator). The Loan Calculator is fully functional and needs no backend.
/// Forex/Rates AND Forms both come from the CLIENT's API (the app only consumes
/// them) — neither endpoint exists yet, so [sampleRateTables],
/// [sampleNafexRates] and [sampleFormCategories] provide placeholder content.
library;

/// A rate-table entry on the Forex & Rates hub (Figma 19B).
class RateTable {
  final String id;
  final String title;
  final String subtitle;
  const RateTable(this.id, this.title, this.subtitle);
}

/// A single currency row in a rate table (Figma 19C).
class CurrencyRate {
  final String country;
  final String code;
  final double buy;
  final double sell;
  const CurrencyRate(this.country, this.code, this.buy, this.sell);
}

/// A form category folder (Figma 19D).
class FormCategory {
  final String id;
  final String title;
  final String subtitle;
  final List<BankForm> forms;
  const FormCategory(this.id, this.title, this.subtitle, this.forms);
}

/// A single downloadable form (Figma 19E). PDF only. [sizeLabel] is
/// display-only (e.g. "1.2 MB"); [url] is the download link from the client's
/// forms endpoint (empty until that endpoint is wired).
class BankForm {
  final String id;
  final String name;
  final String sizeLabel;
  final String url;
  const BankForm(this.id, this.name, this.sizeLabel, {this.url = ''});
}

// ---------------------------------------------------------------------------
// Sample data (placeholder until the endpoints exist).
// ---------------------------------------------------------------------------

const String sampleRatesUpdated = '8 June 2026';

List<RateTable> sampleRateTables() => const [
      RateTable('nafex', 'Autonomous FX Rates — NAFEX',
          'Currency buying and selling rates'),
      RateTable('pta', 'PTA & Form A Rates', 'Eligible transaction rates'),
      RateTable('other', 'Other Conversion Rates', 'Cross-currency guides'),
      RateTable('localdep', 'Local Currency Deposit Rates',
          'Naira rates by volume and tenor'),
      RateTable('fxdep', 'Foreign Currency Deposit Rates',
          'USD rates by balance and tenor'),
      RateTable('eurobond', 'Eurobond Pricing',
          'Sovereign buying and selling prices'),
    ];

List<CurrencyRate> sampleNafexRates() => const [
      CurrencyRate('United States', 'USD', 1355.00, 1380.00),
      CurrencyRate('British Pound', 'GBP', 1795.65, 1849.48),
      CurrencyRate('Euro', 'EUR', 1550.26, 1599.56),
      CurrencyRate('Swiss Francs', 'CHF', 1682.18, 1745.73),
      CurrencyRate('Australian Dollar', 'AUD', 945.11, 983.25),
      CurrencyRate('Canadian Dollar', 'CAD', 966.06, 994.52),
      CurrencyRate('Malaysian Ringgit', 'MYR', 336.67, 339.67),
      CurrencyRate('Japanese Yen', 'JPY', 7.65, 8.65),
    ];

List<FormCategory> sampleFormCategories() => const [
      FormCategory('account', 'Account Services',
          'Account opening and maintenance', [
        BankForm('acc1', 'Account Opening Form', 'PDF • 1.1 MB'),
        BankForm('acc2', 'Mandate Update Form', 'PDF • 640 KB'),
        BankForm('acc3', 'Account Closure Request', 'PDF • 320 KB'),
      ]),
      FormCategory('payments', 'Payments & Transfers',
          'Local and international transfers', [
        BankForm('pay1', 'Standing Order Instruction', 'PDF • 480 KB'),
        BankForm('pay2', 'International Transfer Request', 'PDF • 720 KB'),
      ]),
      FormCategory('trade', 'Trade & Treasury',
          'FX, Form A and trade documents', [
        BankForm('trade1', 'Form A Application', 'PDF • 1.2 MB'),
        BankForm('trade2', 'FX Purchase Request', 'PDF • 860 KB'),
        BankForm('trade3', 'Invisible Trade Request', 'PDF • 420 KB'),
        BankForm('trade4', 'Treasury Deal Mandate', 'PDF • 740 KB'),
      ]),
      FormCategory('loans', 'Loans & Credit', 'Loan and credit applications', [
        BankForm('loan1', 'Personal Loan Application', 'PDF • 900 KB'),
        BankForm('loan2', 'Credit Facility Request', 'PDF • 1.0 MB'),
      ]),
      FormCategory('kyc', 'KYC & Compliance',
          'Customer and compliance updates', [
        BankForm('kyc1', 'KYC Update Form', 'PDF • 560 KB'),
        BankForm('kyc2', 'FATCA Declaration', 'PDF • 300 KB'),
      ]),
    ];
