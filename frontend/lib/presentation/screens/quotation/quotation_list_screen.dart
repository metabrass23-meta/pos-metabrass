import 'package:flutter/material.dart';
import 'dart:io';
import 'package:provider/provider.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../../../src/config/api_config.dart';
import '../../../src/models/quotation/quotation_model.dart';
import '../../../src/services/quotation_service.dart';
import 'add_quotation_screen.dart';

class QuotationListScreen extends StatefulWidget {
  const QuotationListScreen({Key? key}) : super(key: key);

  @override
  _QuotationListScreenState createState() => _QuotationListScreenState();
}

class _QuotationListScreenState extends State<QuotationListScreen> {
  final QuotationService _quotationService = QuotationService();
  final TextEditingController _searchController = TextEditingController();
  List<QuotationModel> _quotations = [];
  List<QuotationModel> _filteredQuotations = [];
  bool _isLoading = true;
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _fetchQuotations();
  }

  Future<void> _fetchQuotations() async {
    setState(() => _isLoading = true);
    final response = await _quotationService.getQuotations();
    if (response.success && response.data != null) {
      setState(() {
        _quotations = response.data!;
        _applyFilters();
      });
    }
    setState(() => _isLoading = false);
  }

  void _applyFilters() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredQuotations = _quotations.where((q) {
        bool matchesSearch = q.customerName.toLowerCase().contains(query) ||
            q.quotationNumber.toLowerCase().contains(query);
        
        bool matchesDate = true;
        if (_selectedDate != null) {
          matchesDate = q.dateIssued.year == _selectedDate!.year &&
              q.dateIssued.month == _selectedDate!.month &&
              q.dateIssued.day == _selectedDate!.day;
        }
        
        return matchesSearch && matchesDate;
      }).toList();
    });
  }

  void _onSearchChanged(String query) {
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F6F9),
      body: Column(
        children: [
          // Header Section
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Row(
              children: [
                Expanded(
                  flex: 4,
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 14),
                    decoration: InputDecoration(
                      hintText: 'SEARCH BY CUSTOMER OR QTN...',
                      hintStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold, fontSize: 13),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.blueAccent, width: 2)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Colors.black26, width: 1.5)),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _selectedDate != null ? Colors.blueAccent : Colors.black26, width: 1.5),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: _selectedDate ?? DateTime.now(),
                                firstDate: DateTime(2020),
                                lastDate: DateTime(2030),
                                builder: (context, child) => Theme(
                                  data: ThemeData.light().copyWith(
                                    colorScheme: const ColorScheme.light(primary: Colors.blueAccent, onPrimary: Colors.white, surface: Colors.white, onSurface: Colors.black),
                                  ),
                                  child: child!,
                                ),
                              );
                              if (picked != null) {
                                setState(() {
                                  _selectedDate = picked;
                                  _applyFilters();
                                });
                              }
                            },
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              child: Row(
                                children: [
                                  const Icon(Icons.calendar_month, size: 20, color: Colors.blueAccent),
                                  const SizedBox(width: 10),
                                  Text(
                                    _selectedDate == null ? 'FILTER BY DATE' : '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}',
                                    style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        if (_selectedDate != null)
                          IconButton(
                            icon: const Icon(Icons.close, size: 20, color: Colors.redAccent),
                            onPressed: () {
                              setState(() {
                                _selectedDate = null;
                                _applyFilters();
                              });
                            },
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final result = await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddQuotationScreen()));
                      if (result == true) _fetchQuotations();
                    },
                    icon: const Icon(Icons.add_circle, color: Colors.white, size: 24),
                    label: const Text('NEW QUOTATION', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14, letterSpacing: 1.0)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0061E0),
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      elevation: 6,
                      shadowColor: Colors.blueAccent.withOpacity(0.5),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Table
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.black12)),
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: SingleChildScrollView(
                          child: DataTable(
                            headingRowColor: MaterialStateProperty.all(const Color(0xFFE9ECEF)),
                            columns: const [
                              DataColumn(label: Text('Quotation No', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                              DataColumn(label: Text('Customer', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                              DataColumn(label: Text('Date', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                              DataColumn(label: Text('Total', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                              DataColumn(label: Text('Status', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                              DataColumn(label: Text('Actions', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black))),
                            ],
                            rows: _filteredQuotations.map((quote) => _buildRow(quote)).toList(),
                          ),
                        ),
                      ),
                    ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  DataRow _buildRow(QuotationModel quote) {
    bool isConverted = quote.conversionStatus == 'CONVERTED_TO_SALE';
    return DataRow(cells: [
      DataCell(Text(quote.quotationNumber, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 13))),
      DataCell(Text(quote.customerName, style: const TextStyle(color: Colors.black, fontWeight: FontWeight.w600, fontSize: 13))),
      DataCell(Text(quote.dateIssued.toString().split(' ')[0], style: const TextStyle(color: Colors.black, fontSize: 13))),
      DataCell(Text('PKR ${quote.grandTotal.toStringAsFixed(0)}', style: const TextStyle(color: Color(0xFF0061E0), fontWeight: FontWeight.bold, fontSize: 13))),
      DataCell(_buildBadge(isConverted)),
      DataCell(Row(
        children: [
          _btn('VIEW', Icons.visibility, Colors.blue, () => _showViewDialog(quote)),
          const SizedBox(width: 6),
          _btn('PDF', Icons.print, Colors.redAccent, () => _printQuotation(quote)),
          const SizedBox(width: 6),
          if (!isConverted) _btn('EDIT', Icons.edit, Colors.grey.shade700, () => _navigateToEdit(quote)),
          const SizedBox(width: 6),
          if (!isConverted)
            ElevatedButton.icon(
              onPressed: () => _convert(quote.id),
              icon: const Icon(Icons.sync, size: 14, color: Colors.white),
              label: const Text('CONVERT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.teal, padding: const EdgeInsets.symmetric(horizontal: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4))),
            ),
          const SizedBox(width: 6),
          if (!isConverted) _btn('DELETE', Icons.delete, Colors.red, () => _delete(quote.id)),
        ],
      )),
    ]);
  }

  void _showViewDialog(QuotationModel quote) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('QUOTATION DETAILS', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF0061E0))),
            IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
          ],
        ),
        content: SizedBox(
          width: 500,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _detailRow('QTN NO:', quote.quotationNumber),
                _detailRow('CUSTOMER:', quote.customerName),
                _detailRow('DATE:', quote.dateIssued.toString().split(' ')[0]),
                _detailRow('STATUS:', quote.conversionStatus),
                const Divider(height: 30, thickness: 1.5),
                const Text('ITEMS:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 10),
                Table(
                  columnWidths: const {0: FlexColumnWidth(3), 1: FlexColumnWidth(1), 2: FlexColumnWidth(2)},
                  children: [
                    const TableRow(children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Qty', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 8), child: Text('Total', textAlign: TextAlign.right, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12))),
                    ]),
                    ...quote.items.map((item) => TableRow(children: [
                      Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text(item.productName, style: const TextStyle(fontSize: 12))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text(item.quantity.toString(), style: const TextStyle(fontSize: 12))),
                      Padding(padding: EdgeInsets.symmetric(vertical: 6), child: Text('PKR ${item.lineTotal.toStringAsFixed(0)}', textAlign: TextAlign.right, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold))),
                    ])),
                  ],
                ),
                const Divider(height: 30, thickness: 1.5),
                _totalRow('Subtotal:', 'PKR ${quote.baseAmount.toStringAsFixed(0)}'),
                _totalRow('Discount:', 'PKR ${quote.discountAmount.toStringAsFixed(0)}'),
                const SizedBox(height: 10),
                _totalRow('GRAND TOTAL:', 'PKR ${quote.grandTotal.toStringAsFixed(0)}', isGrand: true),
              ],
            ),
          ),
        ),
        actions: [
          ElevatedButton.icon(
            onPressed: () => _printQuotation(quote),
            icon: const Icon(Icons.print, color: Colors.white),
            label: const Text('PRINT QUOTATION', style: TextStyle(color: Colors.white)),
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF0061E0)),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black54, fontSize: 13)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _totalRow(String label, String value, {bool isGrand = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isGrand ? FontWeight.bold : FontWeight.normal, fontSize: isGrand ? 16 : 13)),
          Text(value, style: TextStyle(fontWeight: FontWeight.bold, fontSize: isGrand ? 18 : 13, color: isGrand ? const Color(0xFF0061E0) : Colors.black)),
        ],
      ),
    );
  }

  Future<void> _printQuotation(QuotationModel quote) async {
    final String url = '${ApiConfig.baseUrl}${ApiConfig.generateQuotationPdf(quote.id)}';
    
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator(color: Colors.white)),
    );

    try {
      final dio = Dio();
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final String savePath = '${tempDir.path}/quotation_${quote.quotationNumber}.pdf';

      // Download the file
      final response = await dio.download(
        url,
        savePath,
        options: Options(
          validateStatus: (status) => true, // Accept all statuses to see errors
        ),
      );

      // Close loading dialog
      Navigator.pop(context);

      // Check if it's actually a PDF
      if (response.headers.value('content-type')?.contains('application/pdf') == true) {
        // Open the file
        final result = await OpenFile.open(savePath);
        if (result.type != ResultType.done) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not open PDF: ${result.message}')));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error: Server did not return a valid PDF. Please try again.')));
      }
    } catch (e) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error downloading PDF: $e')));
    }
  }

  void _navigateToEdit(QuotationModel quote) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddQuotationScreen(existingQuotation: quote)),
    );
    if (result == true) _fetchQuotations();
  }

  Widget _buildBadge(bool isConverted) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(color: isConverted ? Colors.green.shade100 : Colors.orange.shade100, borderRadius: BorderRadius.circular(4)),
      child: Text(isConverted ? 'Converted' : 'Pending', style: TextStyle(color: isConverted ? Colors.green : Colors.orange.shade800, fontSize: 12, fontWeight: FontWeight.bold)),
    );
  }

  Widget _btn(String label, IconData icon, Color col, VoidCallback tap) {
    return ElevatedButton.icon(
      onPressed: tap,
      icon: Icon(icon, size: 14, color: Colors.white),
      label: Text(label, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
      style: ElevatedButton.styleFrom(backgroundColor: col, padding: const EdgeInsets.symmetric(horizontal: 8), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)), elevation: 0),
    );
  }

  Future<void> _convert(String id) async {
    // Show Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const AlertDialog(
        content: Row(
          children: [
            CircularProgressIndicator(color: Color(0xFF0061E0)),
            SizedBox(width: 20),
            Text("Converting to Sale...", style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );

    final response = await _quotationService.convertToSale(id);
    
    // Close Loading Dialog
    Navigator.pop(context);

    if (response.success) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('SUCCESS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
          content: const Text(
            'Quotation successfully converted to Sale! Check the Sales screen.',
            style: TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300, 
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('OK', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
          ],
        ),
      );
      _fetchQuotations();
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('CONVERSION ERROR', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          content: Text(
            response.message ?? 'Unknown error occurred during conversion.',
            style: const TextStyle(color: Colors.black, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          actions: [
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade300,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
              ),
              child: const Text('GOT IT', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
            ),
            const SizedBox(width: 10),
          ],
        ),
      );
    }
  }

  Future<void> _delete(String id) async {
    setState(() => _isLoading = true);
    await _quotationService.deleteQuotation(id);
    _fetchQuotations();
  }
}
