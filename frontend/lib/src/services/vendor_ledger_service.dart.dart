

import '../models/vendor_ledger/vendor_ledger_model.dart';
import 'api_client.dart';

class VendorLedgerService {
  final ApiClient _apiClient = ApiClient();

  Future<VendorLedgerResponse> getVendorLedger({
    required String vendorId,
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      // MOCK DATA FOR TESTING - Remove when backend is ready
      await Future.delayed(Duration(seconds: 1)); // Simulate network delay

      return VendorLedgerResponse.fromJson({
        'success': true,
        'data': {
          'entries': [
            {
              'id': '1',
              'vendor_id': vendorId,
              'date': '2026-01-19T10:30:00',
              'description': 'Purchase of fabric materials',
              'transaction_type': 'PURCHASE',
              'debit': 50000.00,
              'credit': 0,
              'balance': 50000.00,
              'reference_number': 'PO-001',
              'payment_method': 'Credit',
              'notes': 'Cotton fabric for winter collection',
            },
            {
              'id': '2',
              'vendor_id': vendorId,
              'date': '2026-01-18T14:20:00',
              'description': 'Payment made to vendor',
              'transaction_type': 'PAYMENT',
              'debit': 0,
              'credit': 20000.00,
              'balance': 30000.00,
              'reference_number': 'PAY-101',
              'payment_method': 'Bank Transfer',
              'notes': 'Partial payment settlement',
            },
            {
              'id': '3',
              'vendor_id': vendorId,
              'date': '2026-01-17T09:15:00',
              'description': 'Return of defective items',
              'transaction_type': 'RETURN',
              'debit': 0,
              'credit': 5000.00,
              'balance': 25000.00,
              'reference_number': 'RET-005',
              'payment_method': null,
              'notes': 'Quality issue - torn fabric',
            },
            {
              'id': '4',
              'vendor_id': vendorId,
              'date': '2026-01-15T11:45:00',
              'description': 'Purchase of buttons and accessories',
              'transaction_type': 'PURCHASE',
              'debit': 15000.00,
              'credit': 0,
              'balance': 40000.00,
              'reference_number': 'PO-002',
              'payment_method': 'Credit',
              'notes': 'Metal buttons for winter jackets',
            },
            {
              'id': '5',
              'vendor_id': vendorId,
              'date': '2026-01-12T16:30:00',
              'description': 'Payment made',
              'transaction_type': 'PAYMENT',
              'debit': 0,
              'credit': 10000.00,
              'balance': 30000.00,
              'reference_number': 'PAY-102',
              'payment_method': 'Cash',
              'notes': 'Cash payment',
            },
            {
              'id': '6',
              'vendor_id': vendorId,
              'date': '2026-01-10T13:20:00',
              'description': 'Bulk purchase of zippers',
              'transaction_type': 'PURCHASE',
              'debit': 8000.00,
              'credit': 0,
              'balance': 38000.00,
              'reference_number': 'PO-003',
              'payment_method': 'Credit',
              'notes': 'YKK zippers - assorted sizes',
            },
            {
              'id': '7',
              'vendor_id': vendorId,
              'date': '2026-01-08T10:00:00',
              'description': 'Opening balance adjustment',
              'transaction_type': 'DEBIT',
              'debit': 30000.00,
              'credit': 0,
              'balance': 30000.00,
              'reference_number': 'ADJ-001',
              'payment_method': null,
              'notes': 'Previous balance carried forward',
            },
          ],
          'summary': {
            'opening_balance': 0,
            'total_debits': 103000.00,
            'total_credits': 35000.00,
            'closing_balance': 68000.00,
          },
          'pagination': {
            'current_page': page,
            'page_size': pageSize,
            'total_count': 7,
            'total_pages': 1,
          },
        },
      });

      // TODO: Uncomment when backend is ready
      // final response = await _apiClient.get(
      //   ApiConfig.vendorLedger(vendorId),
      //   queryParameters: {
      //     'page': page,
      //     'page_size': pageSize,
      //   },
      // );
      // return VendorLedgerResponse.fromJson(response);

    } catch (e) {
      return VendorLedgerResponse.error('Error fetching vendor ledger: $e');
    }
  }

  Future<Map<String, dynamic>?> exportVendorLedger({
    required String vendorId,
    required String format,
  }) async {
    try {
      // TODO: Uncomment when backend is ready
      // final response = await _apiClient.get(
      //   ApiConfig.vendorLedger(vendorId),
      //   queryParameters: {
      //     'format': format,
      //   },
      // );
      // return response;

      await Future.delayed(Duration(seconds: 1));
      return {'message': 'Export coming soon'};
    } catch (e) {
      return null;
    }
  }
}
