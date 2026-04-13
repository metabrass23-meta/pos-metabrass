import 'dart:typed_data';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:printing/printing.dart';
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:esc_pos_utils/esc_pos_utils.dart';
import 'package:esc_pos_printer/esc_pos_printer.dart';
import 'receipt_service.dart';
import '../models/sales/sale_model.dart';

class PrintService {
  static final PrintService _instance = PrintService._internal();
  factory PrintService() => _instance;
  PrintService._internal();

  final ReceiptService _receiptService = ReceiptService();

  /// Generate and Print PDF Receipt
  Future<bool> generateAndPrintPdfReceipt(String saleId) async {
    try {
      debugPrint('🖨️ [PrintService] Starting PDF receipt generation for sale: $saleId');

      // Generate PDF from backend
      final pdfResponse = await _receiptService.generateSaleReceiptPdf(saleId);
      
      if (!pdfResponse.success) {
        debugPrint('❌ [PrintService] Failed to generate PDF: ${pdfResponse.message}');
        return false;
      }

      // Get PDF bytes from response
      Uint8List? pdfBytes;
      if (pdfResponse.data != null) {
        if (pdfResponse.data is Map<String, dynamic>) {
          final data = pdfResponse.data as Map<String, dynamic>;
          if (data.containsKey('pdf_bytes')) {
            // If backend returns base64 encoded PDF
            final base64String = data['pdf_bytes'];
            pdfBytes = Uint8List.fromList(
              const Base64Decoder().convert(base64String)
            );
          } else if (data.containsKey('pdf_url')) {
            // If backend returns PDF URL, download it
            pdfBytes = await _downloadPdfFromUrl(data['pdf_url']);
          }
        }
      }

      if (pdfBytes == null) {
        debugPrint('❌ [PrintService] No PDF data received');
        return false;
      }

      // Save PDF to temporary file
      final directory = await getTemporaryDirectory();
      final fileName = 'Receipt_$saleId.pdf';
      final filePath = '${directory.path}/$fileName';
      
      final file = File(filePath);
      await file.writeAsBytes(pdfBytes);
      
      debugPrint('✅ [PrintService] PDF saved to: $filePath');

      // Show print dialog
      await Printing.layoutPdf(
        onLayout: (PdfPageFormat format) async => pdfBytes,
        name: 'Receipt_$saleId',
        format: PdfPageFormat.standard.letter,
        allowPrinting: true,
        allowSharing: true,
      );

      return true;
    } catch (e) {
      debugPrint('💥 [PrintService] Error generating PDF receipt: $e');
      return false;
    }
  }

  /// Generate and Print Thermal Receipt
  Future<bool> generateAndPrintThermalReceipt(String saleId) async {
    try {
      debugPrint('🖨️ [PrintService] Starting thermal receipt generation for sale: $saleId');

      // Get thermal print data from backend
      final thermalResponse = await _receiptService.generateSaleReceiptPdf(saleId);
      
      if (!thermalResponse.success) {
        debugPrint('❌ [PrintService] Failed to generate thermal data: ${thermalResponse.message}');
        return false;
      }

      // For now, we'll create a simple thermal receipt format
      // In a real implementation, you would get structured data from the backend
      final receiptData = thermalResponse.data;
      
      // Create ESC/POS data
      final profile = await CapabilityProfile.load();
      final generator = Generator(
        PaperSize.mm80,
        profile,
      );

      List<int> bytes = [];
      
      // Add receipt header
      bytes += generator.text('AL-NOOR CLOTH HOUSE',
        styles: const PosStyles(
          align: PosAlign.center,
          bold: true,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.text('D.G.KHAN',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.hr();
      
      // Add receipt details (mock data for now)
      bytes += generator.text('Receipt #: $saleId',
        styles: const PosStyles(align: PosAlign.left),
      );
      
      bytes += generator.text('Date: ${DateTime.now().toString().split(' ')[0]}',
        styles: const PosStyles(align: PosAlign.left),
      );
      
      bytes += generator.hr();
      
      // Add items (mock data)
      bytes += generator.text('Item 1        1 x 1000.00  1000.00',
        styles: const PosStyles(align: PosAlign.left),
      );
      
      bytes += generator.text('Item 2        2 x 500.00   1000.00',
        styles: const PosStyles(align: PosAlign.left),
      );
      
      bytes += generator.hr();
      
      // Add total
      bytes += generator.text('TOTAL:                     2000.00',
        styles: const PosStyles(
          align: PosAlign.right,
          bold: true,
          width: PosTextSize.size2,
        ),
      );
      
      bytes += generator.hr();
      
      // Add footer
      bytes += generator.text('Thank you for your business!',
        styles: const PosStyles(align: PosAlign.center),
      );
      
      bytes += generator.text('Please visit again',
        styles: const PosStyles(align: PosAlign.center),
      );

      // Find and connect to printer
      final printer = await _findThermalPrinter();
      
      if (printer != null) {
        try {
          debugPrint('🖨️ [PrintService] Printing to thermal printer: ${printer.name}');
          
          final posPrinter = EscPosPrinter(printer);
          await posPrinter.printBytes(Uint8List.fromList(bytes));
          
          debugPrint('✅ [PrintService] Thermal print successful');
          return true;
        } catch (printError) {
          debugPrint('❌ [PrintService] Thermal print error: $printError');
          return false;
        }
      } else {
        debugPrint('❌ [PrintService] No thermal printer found');
        return false;
      }
    } catch (e) {
      debugPrint('💥 [PrintService] Error generating thermal receipt: $e');
      return false;
    }
  }

  /// Show print dialog with options
  Future<bool> showPrintDialog(String saleId) async {
    try {
      debugPrint('🖨️ [PrintService] Showing print dialog for sale: $saleId');

      // Get available printers
      final printers = await Printing.info();
      
      if (printers.isEmpty) {
        debugPrint('❌ [PrintService] No printers available');
        return false;
      }

      // For simplicity, we'll use the first available printer
      final selectedPrinter = printers.first;
      
      debugPrint('🖨️ [PrintService] Selected printer: ${selectedPrinter.name}');

      // Generate PDF and print
      return await generateAndPrintPdfReceipt(saleId);
    } catch (e) {
      debugPrint('💥 [PrintService] Error in print dialog: $e');
      return false;
    }
  }

  /// Download PDF from URL
  Future<Uint8List?> _downloadPdfFromUrl(String url) async {
    try {
      // This would require HTTP client to download the PDF
      // For now, return null as a placeholder
      debugPrint('🌐 [PrintService] PDF download not implemented for URL: $url');
      return null;
    } catch (e) {
      debugPrint('❌ [PrintService] Error downloading PDF: $e');
      return null;
    }
  }

  /// Find available thermal printer
  Future<Printer?> _findThermalPrinter() async {
    try {
      final printers = await Printing.info();
      
      // Look for thermal printers (usually contain "thermal", "pos", "receipt" in name)
      for (final printer in printers) {
        final name = printer.name.toLowerCase();
        if (name.contains('thermal') || 
            name.contains('pos') || 
            name.contains('receipt') ||
            name.contains('epson') ||
            name.contains('star')) {
          debugPrint('🖨️ [PrintService] Found thermal printer: ${printer.name}');
          return printer;
        }
      }
      
      // If no specific thermal printer found, return the first available printer
      if (printers.isNotEmpty) {
        debugPrint('🖨️ [PrintService] Using default printer: ${printers.first.name}');
        return printers.first;
      }
      
      return null;
    } catch (e) {
      debugPrint('❌ [PrintService] Error finding thermal printer: $e');
      return null;
    }
  }

  /// Get available printers
  Future<List<Printer>> getAvailablePrinters() async {
    try {
      final printers = await Printing.info();
      debugPrint('🖨️ [PrintService] Found ${printers.length} printers');
      
      for (final printer in printers) {
        debugPrint('🖨️ [PrintService] - ${printer.name} (${printer.isAvailable ? "Available" : "Not Available"})');
      }
      
      return printers;
    } catch (e) {
      debugPrint('❌ [PrintService] Error getting printers: $e');
      return [];
    }
  }

  /// Test printer connectivity
  Future<bool> testPrinter(Printer printer) async {
    try {
      debugPrint('🖨️ [PrintService] Testing printer: ${printer.name}');
      
      // Try to get printer capabilities
      final capabilities = await Printing.getPrinterCapabilities(printer);
      
      debugPrint('✅ [PrintService] Printer test successful');
      debugPrint('🖨️ [PrintService] Capabilities: ${capabilities.toString()}');
      
      return true;
    } catch (e) {
      debugPrint('❌ [PrintService] Printer test failed: $e');
      return false;
    }
  }
}
