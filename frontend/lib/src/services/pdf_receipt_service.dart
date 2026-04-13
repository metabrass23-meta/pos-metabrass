import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';

class PdfReceiptService {
  static const String companyName = 'MetaBrass';
  static const String companyAddress =
      'Kacha Eminabadroad Siddique Colony Gujranwala';
  static const String companyPhone = '055-8174471';
  static const String companyTagline =
      'Sanitary Fittings & Bathroom Accessories';

  /// Generate and save PDF Receipt (Receipt Style, not Invoice)
  static Future<String> generateReceiptPdf(SaleModel sale) async {
    try {
      DebugHelper.printInfo(
        'PdfReceiptService',
        'Generating PDF receipt for sale: ${sale.invoiceNumber}',
      );

      final pdf = pw.Document();

      // Load fonts
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      // Build PDF content
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return pw.Column(
              children: [
                _buildReceiptHeader(regularFont, boldFont),
                pw.SizedBox(height: 10),
                _buildReceiptInfo(sale, regularFont, boldFont),
                pw.SizedBox(height: 10),
                _buildCustomerInfo(sale, regularFont, boldFont),
                pw.SizedBox(height: 10),
                _buildItemsTable(sale, regularFont, boldFont),
                pw.SizedBox(height: 10),
                _buildTotalsSection(sale, regularFont, boldFont),
                pw.SizedBox(height: 15),
                _buildFooter(regularFont, boldFont),
              ],
            );
          },
        ),
      );

      // Save PDF
      final output = await getTemporaryDirectory();
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final file = File('${output.path}/RECEIPT_${sale.invoiceNumber}_$timestamp.pdf');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      DebugHelper.printError(
        'PdfReceiptService',
        'Error generating PDF receipt: $e',
      );
      throw Exception('Failed to generate PDF receipt: $e');
    }
  }

  /// Build receipt header with MetaBrass logo and horizontal blue bar
  static pw.Widget _buildReceiptHeader(pw.Font regularFont, pw.Font boldFont) {
    pw.Widget logoWidget = pw.SizedBox(height: 60);
    try {
      final logoFile = File('assets/images/metabras.png');
      if (logoFile.existsSync()) {
        final logoImage = pw.MemoryImage(logoFile.readAsBytesSync());
        logoWidget = pw.Image(logoImage, height: 65, fit: pw.BoxFit.contain);
      }
    } catch (e) {
      print('Error loading logo for PDF: $e');
    }

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Container(
                  padding: const pw.EdgeInsets.all(5),
                  decoration: pw.BoxDecoration(
                    border: pw.Border.all(color: PdfColors.grey200, width: 0.5),
                    borderRadius: pw.BorderRadius.circular(5),
                  ),
                  child: logoWidget,
                ),
              ],
            ),
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'CASH RECEIPT',
                  style: pw.TextStyle(
                    fontSize: 22,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: PdfColor.fromInt(0xFF2B4EBF),
                  ),
                ),
                pw.SizedBox(height: 4),
                pw.Text(
                  companyName.toUpperCase(),
                  style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont),
                ),
                pw.Text(
                  companyAddress,
                  style: pw.TextStyle(fontSize: 8, font: regularFont, color: PdfColors.grey800),
                ),
                pw.Text(
                  'Phone: $companyPhone',
                  style: pw.TextStyle(fontSize: 8, font: regularFont, color: PdfColors.grey800),
                ),
              ],
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Stack(
          alignment: pw.Alignment.centerLeft,
          children: [
            pw.Container(
              height: 20,
              width: double.infinity,
              decoration: pw.BoxDecoration(
                color: PdfColor.fromInt(0xFF1C378A), 
              ),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                companyTagline.toUpperCase(),
                style: pw.TextStyle(
                  color: PdfColors.white,
                  fontSize: 9,
                  fontWeight: pw.FontWeight.bold,
                  font: boldFont,
                ),
              ),
            ),
            pw.Positioned(
              right: 2,
              child: pw.Row(
                children: [
                  _buildArrow(PdfColors.white),
                  _buildArrow(PdfColors.grey400),
                  _buildArrow(PdfColor.fromInt(0xFF2B4EBF)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildArrow(PdfColor color) {
    return pw.Container(
      width: 8,
      height: 20,
      child: pw.Center(
        child: pw.Text(
          ">>",
          style: pw.TextStyle(
            color: color,
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildReceiptInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(width: 1, color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                'Receipt #: ${sale.invoiceNumber}',
                style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: boldFont),
              ),
              pw.Text(
                'Date: ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                style: pw.TextStyle(fontSize: 10, font: regularFont),
              ),
            ],
          ),
          pw.Container(
            padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: pw.BoxDecoration(
              color: sale.isFullyPaid ? PdfColors.green100 : PdfColors.orange100,
              borderRadius: pw.BorderRadius.circular(4),
            ),
            child: pw.Text(
              sale.paymentStatusDisplay.toUpperCase(),
              style: pw.TextStyle(
                fontSize: 10,
                fontWeight: pw.FontWeight.bold,
                font: boldFont,
                color: sale.isFullyPaid ? PdfColors.green800 : PdfColors.orange800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      width: double.infinity,
      decoration: pw.BoxDecoration(
        color: PdfColors.grey50,
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'CUSTOMER: ${sale.customerName.toUpperCase()}',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildItemsTable(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    if (sale.saleItems.isEmpty) return pw.SizedBox();

    return pw.Table(
      border: pw.TableBorder.all(width: 0.5, color: PdfColors.grey300),
      columnWidths: {
        0: const pw.FlexColumnWidth(3),
        1: const pw.FlexColumnWidth(1),
        2: const pw.FlexColumnWidth(1.2),
        3: const pw.FlexColumnWidth(1.2),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _tableHeader('ITEM', boldFont),
            _tableHeader('QTY', boldFont, align: pw.TextAlign.center),
            _tableHeader('PRICE', boldFont, align: pw.TextAlign.right),
            _tableHeader('TOTAL', boldFont, align: pw.TextAlign.right),
          ],
        ),
        ...sale.saleItems.map((item) => pw.TableRow(
          children: [
            _tableCell(item.productName, regularFont),
            _tableCell(item.quantity.toString(), regularFont, align: pw.TextAlign.center),
            _tableCell(item.unitPrice.toStringAsFixed(0), regularFont, align: pw.TextAlign.right),
            _tableCell(item.lineTotal.toStringAsFixed(0), regularFont, align: pw.TextAlign.right),
          ],
        )),
      ],
    );
  }

  static pw.Widget _tableHeader(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, fontWeight: pw.FontWeight.bold, font: font), textAlign: align),
    );
  }

  static pw.Widget _tableCell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.all(5),
      child: pw.Text(text, style: pw.TextStyle(fontSize: 9, font: font), textAlign: align),
    );
  }

  static pw.Widget _buildTotalsSection(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 150,
          child: pw.Column(
            children: [
              _totalRow('Subtotal', sale.subtotal, regularFont),
              if (sale.overallDiscount > 0) _totalRow('Discount', -sale.overallDiscount, regularFont),
              pw.Divider(thickness: 0.5, color: PdfColors.grey300),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('GRAND TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
                  pw.Text('PKR ${sale.grandTotal.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
                ],
              ),
              if (sale.amountPaid > 0) ...[
                _totalRow('Paid', sale.amountPaid, regularFont),
                _totalRow('Balance', sale.remainingAmount, boldFont),
              ],
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, double value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, font: font)),
          pw.Text('PKR ${value.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 9, font: font)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1, color: PdfColors.grey400),
        pw.SizedBox(height: 5),
        pw.Text('THANK YOU FOR YOUR BUSINESS!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont)),
        pw.SizedBox(height: 10),
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(5),
          decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(4)),
          child: pw.Column(
            children: [
              pw.Text('Software: MetaBrass POS System', style: pw.TextStyle(fontSize: 7, font: regularFont)),
              pw.Text('Date: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 7, font: regularFont)),
            ],
          ),
        ),
      ],
    );
  }

  static Future<void> previewAndPrintReceipt(SaleModel sale) async {
    try {
      final filePath = await generateReceiptPdf(sale);
      if (Platform.isWindows) {
        await Process.run('cmd', ['/c', 'start', '', filePath.replaceAll('/', '\\')]);
      } else {
        await Process.run('open', [filePath]);
      }
    } catch (e) {
      throw Exception('Failed to open receipt PDF: $e');
    }
  }
}
