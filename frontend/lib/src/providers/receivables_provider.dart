import 'package:flutter/material.dart';
import '../services/sales_service.dart';
import '../services/receivables_service.dart';
import '../models/receivables/receivable_model.dart';
import '../models/api_response.dart';

export '../models/receivables/receivable_model.dart';

class ReceivablesProvider extends ChangeNotifier {
  List<Receivable> _receivables = [];
  List<Receivable> _filteredReceivables = [];
  String _searchQuery = '';
  bool _isLoading = false;
  String? _errorMessage;

  List<Receivable> get receivables => _filteredReceivables;
  String get searchQuery => _searchQuery;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  final SalesService _salesService = SalesService();
  final ReceivablesService _receivablesService = ReceivablesService();

  ReceivablesProvider() {
    fetchReceivables();
  }

  Future<void> fetchReceivables() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1. Fetch manual receivables from backend
      final manRes = await _receivablesService.getReceivables();
      List<Receivable> manualReceivables = [];
      if (manRes.success && manRes.data != null) {
        manualReceivables = manRes.data!;
      }

      // 2. Fetch unpaid sales from backend
      final salesRes = await _salesService.getSales(
        params: SalesListParams(pageSize: 100),
      );
      List<Receivable> salesReceivables = [];
      if (salesRes.success && salesRes.data != null) {
        final sales = salesRes.data!.sales;
        salesReceivables = sales
            .map((s) => Receivable(
                  id: s.id,
                  debtorName: s.customerName.isEmpty ? 'Walk-in Customer' : s.customerName,
                  debtorPhone: s.customerPhone.isEmpty ? 'N/A' : s.customerPhone,
                  amountGiven: s.grandTotal,
                  reasonOrItem: 'Sale #${s.invoiceNumber}',
                  dateLent: s.createdAt,
                  expectedReturnDate: s.createdAt.add(const Duration(days: 30)),
                  amountReturned: s.amountPaid,
                  balanceRemaining: s.remainingAmount,
                  notes: s.notes,
                  createdAt: s.createdAt,
                  updatedAt: s.updatedAt,
                  relatedSaleId: s.id,
                ))
            .toList();
      }

      // 3. Merge and deduplicate (some receivables might be linked to sales already in backend)
      final Set<String> saleIdSet = salesReceivables.map((s) => s.id).toSet();
      
      // Keep manual receivables that are NOT already in the sales list (deduplicate)
      final uniqueManual = manualReceivables.where((r) => !saleIdSet.contains(r.relatedSaleId) && !saleIdSet.contains(r.id)).toList();

      _receivables = [...salesReceivables, ...uniqueManual];
      
      // Sort: Overdue first, then by date (descending)
      _receivables.sort((a, b) {
        if (a.isOverdue && !b.isOverdue) return -1;
        if (!a.isOverdue && b.isOverdue) return 1;
        return b.createdAt.compareTo(a.createdAt);
      });

      searchReceivables(_searchQuery);
    } catch (e) {
      _errorMessage = 'Failed to load receivables: $e';
      debugPrint('Error loading receivables: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void searchReceivables(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredReceivables = List.from(_receivables);
    } else {
      final q = query.toLowerCase();
      _filteredReceivables = _receivables
          .where((r) =>
              r.id.toLowerCase().contains(q) ||
              r.debtorName.toLowerCase().contains(q) ||
              r.debtorPhone.toLowerCase().contains(q) ||
              r.reasonOrItem.toLowerCase().contains(q) ||
              r.statusText.toLowerCase().contains(q) ||
              (r.notes?.toLowerCase().contains(q) ?? false))
          .toList();
    }

    notifyListeners();
  }

  Future<bool> addReceivable({
    required String debtorName,
    required String debtorPhone,
    required double amountGiven,
    required String reasonOrItem,
    required DateTime dateLent,
    required DateTime expectedReturnDate,
    double amountReturned = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newRec = Receivable(
        id: '', // Backend will generate
        debtorName: debtorName,
        debtorPhone: debtorPhone,
        amountGiven: amountGiven,
        reasonOrItem: reasonOrItem,
        dateLent: dateLent,
        expectedReturnDate: expectedReturnDate,
        amountReturned: amountReturned,
        balanceRemaining: amountGiven - amountReturned,
        notes: notes,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      final res = await _receivablesService.createReceivable(newRec);
      if (res.success) {
        await fetchReceivables(); // Reload everything
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error adding receivable: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReceivable({
    required String id,
    required String debtorName,
    required String debtorPhone,
    required double amountGiven,
    required String reasonOrItem,
    required DateTime dateLent,
    required DateTime expectedReturnDate,
    double amountReturned = 0.0,
    String? notes,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      // Find if it's a sale-backed receivable
      final existing = _receivables.firstWhere((r) => r.id == id);
      
      if (existing.isFromSale) {
        _errorMessage = 'Please update sale-linked debts through the Sales module.';
        return false;
      }

      final updatedRec = existing.copyWith(
        debtorName: debtorName,
        debtorPhone: debtorPhone,
        amountGiven: amountGiven,
        reasonOrItem: reasonOrItem,
        dateLent: dateLent,
        expectedReturnDate: expectedReturnDate,
        amountReturned: amountReturned,
        balanceRemaining: amountGiven - amountReturned,
        notes: notes,
        updatedAt: DateTime.now(),
      );

      final res = await _receivablesService.updateReceivable(id, updatedRec);
      if (res.success) {
        await fetchReceivables();
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error updating receivable: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> deleteReceivable(String id) async {
    _isLoading = true;
    notifyListeners();

    try {
      final existing = _receivables.firstWhere((r) => r.id == id);
      if (existing.isFromSale) {
        _errorMessage = 'Sale records cannot be deleted from Receivables. Please void the sale.';
        return false;
      }

      final res = await _receivablesService.deleteReceivable(id);
      if (res.success) {
        await fetchReceivables();
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error deleting receivable: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> recordPayment(String id, double amount, {String? notes}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final res = await _receivablesService.recordPayment(id, amount, notes: notes);
      if (res.success) {
        await fetchReceivables();
        return true;
      } else {
        _errorMessage = res.message;
        return false;
      }
    } catch (e) {
      _errorMessage = 'Error recording payment: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Statistics
  double get totalOutstanding => _receivables.fold(0, (sum, item) => sum + item.balanceRemaining);
  int get overdueCount => _receivables.where((r) => r.isOverdue).length;
  int get pendingCount => _receivables.where((r) => !r.isFullyPaid && !r.isOverdue).length;
  int get fullyPaidCount => _receivables.where((r) => r.isFullyPaid).length;

  // New helper for stats card compatibility
  Map<String, dynamic> get receivablesStats {
    final totalAmountLent = _receivables.fold<double>(0, (sum, r) => sum + r.amountGiven);
    final totalAmountReturned = _receivables.fold<double>(0, (sum, r) => sum + r.amountReturned);
    
    return {
      'total': _receivables.length,
      'totalAmountLent': totalAmountLent.toStringAsFixed(0),
      'totalAmountReturned': totalAmountReturned.toStringAsFixed(0),
      'totalOutstanding': totalOutstanding.toStringAsFixed(0),
      'overdueCount': overdueCount,
      'fullyPaidCount': fullyPaidCount,
      'partiallyPaidCount': _receivables.where((r) => r.isPartiallyPaid).length,
      'returnRate': totalAmountLent > 0 ? ((totalAmountReturned / totalAmountLent) * 100).toStringAsFixed(1) : '0.0',
    };
  }
}
