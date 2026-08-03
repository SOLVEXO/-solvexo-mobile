import 'package:book_store_app/app/data/models/finance/finance_dashboard_model.dart';
import 'package:book_store_app/app/data/models/finance/finance_transaction_model.dart';
import 'package:book_store_app/app/data/models/finance/payout_method_model.dart';
import 'package:book_store_app/app/data/models/finance/payout_schedule_model.dart';
import 'package:book_store_app/app/data/models/finance/tax_report_model.dart';
import 'package:book_store_app/app/data/repositories/seller_finance_repository.dart';
import 'package:book_store_app/shared_prefrences/app_prefrences.dart';
import 'package:book_store_app/utils/toast_util.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

export 'package:book_store_app/app/data/models/finance/finance_transaction_model.dart' show FinanceTransactionType, FinanceTransactionTypeX;

class SellerFinanceController extends GetxController {
  final SellerFinanceRepository _repo = SellerFinanceRepository();

  String storeId = '';
  final RxBool isLoading = false.obs;

  // Dashboard
  final Rx<FinanceDashboardModel> dashboard = Rx<FinanceDashboardModel>(FinanceDashboardModel.empty);

  // A store can hold a separate wallet per currency (e.g. USD from Stripe
  // sales + PKR from manual bank-transfer sales) — this picks which one the
  // whole finance screen is currently showing.
  final RxString selectedCurrency = 'USD'.obs;

  List<String> get availableCurrencies => dashboard.value.currencies;
  FinanceWallet get _wallet => dashboard.value.walletFor(selectedCurrency.value);

  void selectCurrency(String currency) {
    if (selectedCurrency.value == currency) return;
    selectedCurrency.value = currency;
    loadTransactions(reset: true);
    loadPayoutSchedule();
  }

  String amountLabel(double v) => _wallet.amountLabel(v);

  double get availableBalance => _wallet.availableBalance;
  double get pendingBalance => _wallet.pendingBalance;
  bool get isFlaggedForReview => _wallet.isFlaggedForReview;
  String? get flaggedReason => _wallet.flaggedReason;

  String get nextPayoutDate {
    final date = _wallet.nextPayout.scheduledAt ?? _wallet.payoutSchedule.nextPayoutAt;
    return date != null ? DateFormat('MMM d').format(date) : '—';
  }

  String get paymentMethod {
    final method = _wallet.nextPayout.method;
    if (method != null) return method.label;
    final defaults = payoutMethods.where((m) => m.currency == selectedCurrency.value && m.isDefault);
    return defaults.isEmpty ? 'Not set up' : defaults.first.displayLabel;
  }

  double get monthRevenue => _wallet.summary.thisMonthRevenue;
  double get revenueChange => _wallet.summary.revenueGrowthPercent;
  double get platformFees => _wallet.summary.platformFees;
  double get totalPaidOut => _wallet.summary.totalPaidOut;
  double get pendingTax => _wallet.summary.pendingTax;

  List<MapEntry<String, String>> get feeItems => dashboard.value.feeBreakdown.asEntries;

  // Transactions
  final RxString activeFilter = 'All'.obs;
  final filters = const ['All', 'Sales', 'Payouts', 'Fees', 'Refunds', 'Adjustments'];
  final RxList<FinanceTransactionModel> transactions = <FinanceTransactionModel>[].obs;
  final RxBool isLoadingTransactions = false.obs;
  final RxBool isLoadingMoreTransactions = false.obs;
  final RxBool isExportingTransactions = false.obs;
  int _txPage = 1;
  int _txPages = 1;

  bool get hasMoreTransactions => _txPage < _txPages;

  static const _filterToType = {
    'Sales': 'sale',
    'Payouts': 'payout',
    'Fees': 'fee',
    'Refunds': 'refund',
    'Adjustments': 'adjustment',
  };

  // Payout methods
  final RxList<PayoutMethodModel> payoutMethods = <PayoutMethodModel>[].obs;
  final RxBool isLoadingPayoutMethods = false.obs;
  final RxBool isSavingPayoutMethod = false.obs;
  final RxBool isRequestingPayout = false.obs;

  // Payout schedule
  final Rx<PayoutScheduleModel> payoutSchedule = Rx<PayoutScheduleModel>(PayoutScheduleModel.empty);
  final RxBool isSavingSchedule = false.obs;

  String get payoutFrequency => payoutSchedule.value.frequencyLabel;
  String get payoutCurrency => selectedCurrency.value;
  String get payoutMinimum => amountLabel(payoutSchedule.value.minimumAmount);

  // Tax reports
  final RxList<TaxReportModel> taxReports = <TaxReportModel>[].obs;
  final RxBool isLoadingTaxReports = false.obs;
  final RxBool isGeneratingTaxReport = false.obs;

  @override
  void onInit() {
    super.onInit();
    _init();
  }

  Future<void> _init() async {
    storeId = await AppPreferences.getStoreId() ?? '';
    if (storeId.isEmpty) {
      debugPrint('⚠️ SellerFinanceController: no storeId in prefs');
      isLoading.value = false;
      return;
    }
    await _loadAll();
  }

  Future<void> _loadAll() async {
    isLoading.value = true;
    await Future.wait([
      _loadDashboard(),
      loadTransactions(reset: true),
      loadPayoutMethods(),
      loadPayoutSchedule(),
      loadTaxReports(),
    ]);
    isLoading.value = false;
  }

  Future<void> _loadDashboard() async {
    dashboard.value = await _repo.getDashboard(storeId);
    final currencies = dashboard.value.currencies;
    if (!currencies.contains(selectedCurrency.value)) {
      selectedCurrency.value = currencies.isNotEmpty ? currencies.first : 'USD';
    }
  }

  @override
  Future<void> refresh() async => _loadAll();

  // ── Transactions ─────────────────────────────────────────────────────────

  void setFilter(String f) {
    if (activeFilter.value == f) return;
    activeFilter.value = f;
    loadTransactions(reset: true);
  }

  Future<void> loadTransactions({bool reset = false}) async {
    if (reset) {
      _txPage = 1;
      isLoadingTransactions.value = true;
    }
    final result = await _repo.getTransactions(
      storeId,
      type: _filterToType[activeFilter.value],
      currency: selectedCurrency.value,
      page: reset ? 1 : _txPage,
    );
    if (reset) {
      transactions.value = result.transactions;
    } else {
      transactions.addAll(result.transactions);
    }
    _txPage = result.page;
    _txPages = result.pages;
    if (reset) isLoadingTransactions.value = false;
  }

  Future<void> loadMoreTransactions() async {
    if (isLoadingMoreTransactions.value || !hasMoreTransactions) return;
    isLoadingMoreTransactions.value = true;
    _txPage += 1;
    final result = await _repo.getTransactions(
      storeId,
      type: _filterToType[activeFilter.value],
      currency: selectedCurrency.value,
      page: _txPage,
    );
    transactions.addAll(result.transactions);
    _txPage = result.page;
    _txPages = result.pages;
    isLoadingMoreTransactions.value = false;
  }

  Future<void> exportTransactions() async {
    if (isExportingTransactions.value) return;
    isExportingTransactions.value = true;
    try {
      final csv = await _repo.exportTransactionsCsv(storeId, type: _filterToType[activeFilter.value], currency: selectedCurrency.value);
      if (csv == null) return;
      final file = XFile.fromData(
        Uint8List.fromList(csv.codeUnits),
        name: 'transactions-${DateTime.now().millisecondsSinceEpoch}.csv',
        mimeType: 'text/csv',
      );
      await SharePlus.instance.share(ShareParams(files: [file], subject: 'Transactions Export'));
    } finally {
      isExportingTransactions.value = false;
    }
  }

  // ── Payouts ──────────────────────────────────────────────────────────────

  Future<bool> requestPayout({required double amount, required String payoutMethodId, String? notes}) async {
    if (isRequestingPayout.value) return false;
    isRequestingPayout.value = true;
    try {
      final payout = await _repo.requestPayout(storeId, amount: amount, payoutMethodId: payoutMethodId, notes: notes);
      if (payout == null) return false;
      final method = payoutMethods.where((m) => m.id == payoutMethodId).firstOrNull;
      final wallet = dashboard.value.walletFor(method?.currency ?? selectedCurrency.value);
      ToastUtil.showToast('Payout of ${wallet.amountLabel(amount)} requested.');
      await Future.wait([_loadDashboard(), loadTransactions(reset: true)]);
      return true;
    } finally {
      isRequestingPayout.value = false;
    }
  }

  // ── Payout methods ───────────────────────────────────────────────────────

  Future<void> loadPayoutMethods() async {
    isLoadingPayoutMethods.value = true;
    payoutMethods.value = await _repo.getPayoutMethods(storeId);
    isLoadingPayoutMethods.value = false;
  }

  Future<bool> addPayoutMethod({
    required String type,
    String? currency,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? routingNumber,
    String? externalAccountId,
    bool setAsDefault = false,
  }) async {
    isSavingPayoutMethod.value = true;
    try {
      final method = await _repo.addPayoutMethod(
        storeId,
        type: type,
        currency: currency,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        routingNumber: routingNumber,
        externalAccountId: externalAccountId,
        setAsDefault: setAsDefault,
      );
      if (method == null) return false;
      await Future.wait([loadPayoutMethods(), _loadDashboard()]);
      ToastUtil.showToast(
        method.isPendingVerification
            ? 'Payout method added — awaiting verification before it can be used.'
            : 'Payout method added.',
      );
      return true;
    } finally {
      isSavingPayoutMethod.value = false;
    }
  }

  Future<bool> updatePayoutMethod(
    String methodId, {
    String? currency,
    String? bankName,
    String? accountHolder,
    String? accountNumber,
    String? routingNumber,
    String? externalAccountId,
  }) async {
    isSavingPayoutMethod.value = true;
    try {
      final method = await _repo.updatePayoutMethod(
        storeId,
        methodId,
        currency: currency,
        bankName: bankName,
        accountHolder: accountHolder,
        accountNumber: accountNumber,
        routingNumber: routingNumber,
        externalAccountId: externalAccountId,
      );
      if (method == null) return false;
      await loadPayoutMethods();
      ToastUtil.showToast(
        method.isPendingVerification
            ? 'Payout method updated — changes require re-verification.'
            : 'Payout method updated.',
      );
      return true;
    } finally {
      isSavingPayoutMethod.value = false;
    }
  }

  Future<bool> deletePayoutMethod(String methodId) async {
    final ok = await _repo.deletePayoutMethod(storeId, methodId);
    if (ok) {
      await Future.wait([loadPayoutMethods(), _loadDashboard()]);
      ToastUtil.showToast('Payout method removed.');
    }
    return ok;
  }

  Future<bool> setDefaultPayoutMethod(String methodId) async {
    final ok = await _repo.setDefaultPayoutMethod(storeId, methodId);
    if (ok) {
      await Future.wait([loadPayoutMethods(), _loadDashboard()]);
      ToastUtil.showToast('Default payout method updated.');
    }
    return ok;
  }

  // ── Payout schedule ──────────────────────────────────────────────────────

  Future<void> loadPayoutSchedule() async {
    payoutSchedule.value = await _repo.getPayoutSchedule(storeId, currency: selectedCurrency.value);
  }

  Future<bool> updatePayoutSchedule({
    String? frequency,
    int? dayOfWeek,
    int? dayOfMonth,
    double? minimumAmount,
    bool? isEnabled,
    String? defaultPayoutMethodId,
  }) async {
    isSavingSchedule.value = true;
    try {
      final updated = await _repo.updatePayoutSchedule(
        storeId,
        currency: selectedCurrency.value,
        frequency: frequency,
        dayOfWeek: dayOfWeek,
        dayOfMonth: dayOfMonth,
        minimumAmount: minimumAmount,
        isEnabled: isEnabled,
        defaultPayoutMethodId: defaultPayoutMethodId,
      );
      if (updated == null) return false;
      payoutSchedule.value = updated;
      await _loadDashboard();
      ToastUtil.showToast('Payout schedule updated.');
      return true;
    } finally {
      isSavingSchedule.value = false;
    }
  }

  // ── Tax reports ──────────────────────────────────────────────────────────

  Future<void> loadTaxReports() async {
    isLoadingTaxReports.value = true;
    taxReports.value = await _repo.getTaxReports(storeId);
    isLoadingTaxReports.value = false;
  }

  Future<bool> generateTaxReport({required int year, required String period, String? currency}) async {
    isGeneratingTaxReport.value = true;
    try {
      final report = await _repo.generateTaxReport(storeId, year: year, period: period, currency: currency ?? selectedCurrency.value);
      if (report == null) return false;
      await loadTaxReports();
      ToastUtil.showToast('${report.periodLabel} report generated.');
      return true;
    } finally {
      isGeneratingTaxReport.value = false;
    }
  }
}
