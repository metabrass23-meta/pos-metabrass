import 'package:flutter/foundation.dart';
import '../models/sales/sale_model.dart';
import '../services/invoice_service.dart';
import '../utils/debug_helper.dart';

class InvoiceProvider extends ChangeNotifier {
  final InvoiceService _invoiceService = InvoiceService();

  // State variables
  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _error;
  String? _success;
  Map<String, dynamic>? _pagination;

  // Filter state
  String? _selectedSaleId;
  String? _selectedCustomerId;
  String? _selectedStatus;
  DateTime? _dateFrom;
  DateTime? _dateTo;
  bool _showInactive = false;

  // Getters
  List<InvoiceModel> get invoices => _invoices;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get success => _success;
  Map<String, dynamic>? get pagination => _pagination;

  // Filter getters
  String? get selectedSaleId => _selectedSaleId;
  String? get selectedCustomerId => _selectedCustomerId;
  String? get selectedStatus => _selectedStatus;
  DateTime? get dateFrom => _dateFrom;
  DateTime? get dateTo => _dateTo;
  bool get showInactive => _showInactive;

  // Computed properties
  List<InvoiceModel> get pendingInvoices => _invoices.where((invoice) => invoice.status == 'PENDING').toList();
  List<InvoiceModel> get paidInvoices => _invoices.where((invoice) => invoice.status == 'PAID').toList();
  List<InvoiceModel> get overdueInvoices => _invoices.where((invoice) => invoice.status == 'OVERDUE').toList();
  int get totalInvoices => _invoices.length;
  int get pendingCount => pendingInvoices.length;
  int get paidCount => paidInvoices.length;
  int get overdueCount => overdueInvoices.length;

  /// Initialize the provider
  Future<void> initialize() async {
    await loadInvoices();
  }

  /// Load invoices with current filters
  Future<void> loadInvoices({bool refresh = false, int? page, int? pageSize}) async {
    if (!refresh && _invoices.isNotEmpty) return;

    _setLoading(true);
    _clearMessages();

    try {
      final response = await _invoiceService.listInvoices(
        status: _selectedStatus,
        customerId: _selectedCustomerId,
        dateFrom: _dateFrom?.toIso8601String(),
        dateTo: _dateTo?.toIso8601String(),
        showInactive: _showInactive,
        page: page,
        pageSize: pageSize,
      );

      if (response.success && response.data != null) {
        // ✅ FIXED: Service now returns List<InvoiceModel> directly
        _invoices = response.data!;

        // Note: With the simplified service return type, we nullify pagination
        // to prevent the type error.
        _pagination = null;

        _setSuccess('Invoices loaded successfully');
      } else {
        _setError(response.message);
      }
    } catch (e) {
      DebugHelper.printError('Load invoices in provider', e);
      _setError('Failed to load invoices: $e');
    } finally {
      _setLoading(false);
    }
  }

  /// Create a new invoice
  Future<bool> createInvoice({required String saleId, String? notes, DateTime? dueDate}) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _invoiceService.createInvoice(saleId: saleId, notes: notes, dueDate: dueDate);

      if (response.success && response.data != null) {
        _invoices.insert(0, response.data!);
        _setSuccess('Invoice created successfully');
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      DebugHelper.printError('Create invoice in provider', e);
      _setError('Failed to create invoice: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Update invoice
  Future<bool> updateInvoice({required String id, String? notes, String? status, DateTime? dueDate}) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _invoiceService.updateInvoice(id: id, notes: notes, status: status, dueDate: dueDate);

      if (response.success && response.data != null) {
        final index = _invoices.indexWhere((invoice) => invoice.id == id);
        if (index != -1) {
          _invoices[index] = response.data!;
          _setSuccess('Invoice updated successfully');
          notifyListeners();
          return true;
        }
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      DebugHelper.printError('Update invoice in provider', e);
      _setError('Failed to update invoice: $e');
      return false;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  /// Delete invoice
  Future<bool> deleteInvoice(String id) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _invoiceService.deleteInvoice(id);

      if (response.success) {
        _invoices.removeWhere((invoice) => invoice.id == id);
        _setSuccess('Invoice deleted successfully');
        notifyListeners();
        return true;
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      DebugHelper.printError('Delete invoice in provider', e);
      _setError('Failed to delete invoice: $e');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  /// Generate PDF for invoice
  Future<bool> generateInvoicePdf(String id) async {
    _setLoading(true);
    _clearMessages();

    try {
      final response = await _invoiceService.generateInvoicePdf(id);

      if (response.success && response.data != null) {
        // Update invoice status to GENERATED
        final index = _invoices.indexWhere((invoice) => invoice.id == id);
        if (index != -1) {
          _invoices[index] = _invoices[index].copyWith(status: 'GENERATED');
          _setSuccess('Invoice PDF generated successfully');
          notifyListeners();
          return true;
        }
      } else {
        _setError(response.message);
        return false;
      }
    } catch (e) {
      DebugHelper.printError('Generate invoice PDF in provider', e);
      _setError('Failed to generate invoice PDF: $e');
      return false;
    } finally {
      _setLoading(false);
    }
    return false;
  }

  /// Get invoice by ID
  InvoiceModel? getInvoiceById(String id) {
    try {
      return _invoices.firstWhere((invoice) => invoice.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Get invoices by sale ID
  List<InvoiceModel> getInvoicesBySale(String saleId) {
    return _invoices.where((invoice) => invoice.saleId == saleId).toList();
  }

  /// Get invoices by customer name
  List<InvoiceModel> getInvoicesByCustomer(String customerName) {
    return _invoices.where((invoice) => invoice.customerName == customerName).toList();
  }

  /// Filter invoices by sale
  void filterBySale(String? saleId) {
    _selectedSaleId = saleId;
    loadInvoices(refresh: true);
  }

  /// Filter invoices by customer
  void filterByCustomer(String? customerId) {
    _selectedCustomerId = customerId;
    loadInvoices(refresh: true);
  }

  /// Filter invoices by status
  void filterByStatus(String? status) {
    _selectedStatus = status;
    loadInvoices(refresh: true);
  }

  /// Filter invoices by date range
  void filterByDateRange(DateTime? from, DateTime? to) {
    _dateFrom = from;
    _dateTo = to;
    loadInvoices(refresh: true);
  }

  /// Toggle inactive invoices
  void toggleInactive(bool showInactive) {
    _showInactive = showInactive;
    loadInvoices(refresh: true);
  }

  /// Set filters for search and status
  void setFilters({String? search, String? status, String? customerId}) {
    if (search != null) {
      // Implement search logic if needed (or API side search)
    }
    if (status != null) {
      _selectedStatus = status;
    }
    if (customerId != null) {
      _selectedCustomerId = customerId;
    }
    loadInvoices(refresh: true);
  }

  /// Clear all filters
  void clearFilters() {
    _selectedSaleId = null;
    _selectedCustomerId = null;
    _selectedStatus = null;
    _dateFrom = null;
    _dateTo = null;
    _showInactive = false;
    loadInvoices(refresh: true);
  }

  /// Get filtered invoices based on current filters (Client-side helper)
  List<InvoiceModel> get filteredInvoices {
    List<InvoiceModel> filtered = _invoices;

    if (_selectedStatus != null && _selectedStatus!.isNotEmpty) {
      filtered = filtered.where((invoice) => invoice.status == _selectedStatus).toList();
    }

    if (_selectedCustomerId != null && _selectedCustomerId!.isNotEmpty) {
      // Assuming customerId in state maps to customerName for search,
      // or modify logic based on actual filtering needs
      filtered = filtered.where((invoice) => invoice.customerName == _selectedCustomerId).toList();
    }

    return filtered;
  }

  /// Refresh invoices
  Future<void> refresh() async {
    await loadInvoices(refresh: true);
  }

  // Private helper methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    _success = null;
    notifyListeners();
  }

  void _setSuccess(String success) {
    _success = success;
    _error = null;
    notifyListeners();
  }

  void _clearMessages() {
    _error = null;
    _success = null;
    notifyListeners();
  }
}