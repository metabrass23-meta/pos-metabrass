import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import '../models/sales/sale_model.dart';
import '../utils/debug_helper.dart';

class PdfInvoiceService {
  static const String companyName = 'MetaBrass';
  static const String companyAddress =
      'Kacha Eminabadroad Siddique Colony Gujranwala';
  static const String companyPhone = '055-8174471';
  static const String companyTagline =
      'Sanitary Fittings & Bathroom Accessories';

  /// Generate and save PDF invoice
  static Future<String> generateInvoicePdf(SaleModel sale) async {
    try {
      final pdf = pw.Document();
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) {
            return [
              _buildHeader(regularFont, boldFont),
              pw.SizedBox(height: 10),
              _buildInvoiceInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 10),
              _buildCustomerInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 10),
              _buildItemsTable(sale, regularFont, boldFont),
              pw.SizedBox(height: 10),
              _buildTotalsSection(sale, regularFont, boldFont),
              pw.SizedBox(height: 15),
              _buildFooter(regularFont, boldFont),
            ];
          },
        ),
      );

      final fileName = 'Invoice_${sale.invoiceNumber}.pdf';
      final directory = await getTemporaryDirectory();
      final file = File('${directory.path}/$fileName');
      await file.writeAsBytes(await pdf.save());

      return file.path;
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }

  /// Build header section with logo and brand bar
  static pw.Widget _buildHeader(pw.Font regularFont, pw.Font boldFont) {
    pw.Widget logoWidget = pw.SizedBox(height: 40);
    try {
      final logoFile = File('assets/images/metabras.png');
      if (logoFile.existsSync()) {
        final logoImage = pw.MemoryImage(logoFile.readAsBytesSync());
        logoWidget = pw.Image(logoImage, height: 45);
      }
    } catch (e) {
      print('Error loading logo for Invoice PDF: $e');
    }

    return pw.Column(
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            logoWidget,
            pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  'SALES INVOICE',
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                    font: boldFont,
                    color: PdfColor.fromInt(0xFF2B4EBF),
                  ),
                ),
                pw.Text(companyAddress, style: pw.TextStyle(fontSize: 7, font: regularFont)),
                pw.Text('Phone: $companyPhone', style: pw.TextStyle(fontSize: 7, font: regularFont)),
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
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1C378A)),
              padding: const pw.EdgeInsets.symmetric(horizontal: 10),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                companyTagline.toUpperCase(),
                style: pw.TextStyle(color: PdfColors.white, fontSize: 9, fontWeight: pw.FontWeight.bold, font: boldFont),
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
        child: pw.Text(">>", style: pw.TextStyle(color: color, fontSize: 10, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  static pw.Widget _buildInvoiceInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Invoice #: ${sale.invoiceNumber}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
              pw.Text('Date: ${DateFormat('dd MMM yyyy').format(sale.dateOfSale)}', style: pw.TextStyle(fontSize: 9, font: regularFont)),
            ],
          ),
          pw.Text(sale.status.toUpperCase(), style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont, color: PdfColors.blue800)),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      width: double.infinity,
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Text('BILL TO: ${sale.customerName.toUpperCase()}', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont)),
    );
  }

  static pw.Widget _buildItemsTable(SaleModel sale, pw.Font regularFont, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(25),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(40),
        3: const pw.FixedColumnWidth(60),
        4: const pw.FixedColumnWidth(60),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Sr#', boldFont, align: pw.TextAlign.center),
            _cell('Product', boldFont),
            _cell('Qty', boldFont, align: pw.TextAlign.center),
            _cell('Price', boldFont, align: pw.TextAlign.right),
            _cell('Total', boldFont, align: pw.TextAlign.right),
          ],
        ),
        ...sale.saleItems.asMap().entries.map((e) => pw.TableRow(
          children: [
            _cell('${e.key + 1}', regularFont, align: pw.TextAlign.center),
            _cell(e.value.productName, regularFont),
            _cell('${e.value.quantity}', regularFont, align: pw.TextAlign.center),
            _cell(e.value.unitPrice.toStringAsFixed(0), regularFont, align: pw.TextAlign.right),
            _cell(e.value.lineTotal.toStringAsFixed(0), regularFont, align: pw.TextAlign.right),
          ],
        )),
      ],
    );
  }

  static pw.Widget _cell(String text, pw.Font font, {pw.TextAlign align = pw.TextAlign.left}) {
    return pw.Padding(padding: const pw.EdgeInsets.all(4), child: pw.Text(text, style: pw.TextStyle(fontSize: 8, font: font), textAlign: align));
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
              pw.Divider(thickness: 0.5),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
                  pw.Text('Rs.${sale.grandTotal.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _totalRow(String label, double value, pw.Font font) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 9, font: font)),
          pw.Text('Rs.${value.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 9, font: font)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 5),
        pw.Text('Thank you for your business!', style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont)),
        pw.SizedBox(height: 5),
        pw.Text('Generated: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 7, font: regularFont)),
      ],
    );
  }

  static Future<void> previewAndPrintInvoice(SaleModel sale) async {
    try {
      final pdf = pw.Document();
      final regularFont = pw.Font.helvetica();
      final boldFont = pw.Font.helveticaBold();

      pdf.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a5,
          margin: const pw.EdgeInsets.all(20),
          build: (pw.Context context) => [
            _buildHeader(regularFont, boldFont),
               pw.SizedBox(height: 10),
              _buildInvoiceInfo(sale, regularFont, boldFont),
               pw.SizedBox(height: 10),
              _buildCustomerInfo(sale, regularFont, boldFont),
              pw.SizedBox(height: 10),
              _buildItemsTable(sale, regularFont, boldFont),
               pw.SizedBox(height: 10),
              _buildTotalsSection(sale, regularFont, boldFont),
               pw.SizedBox(height: 15),
              _buildFooter(regularFont, boldFont),
          ],
        ),
      );

      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdf.save(), name: 'Invoice_${sale.invoiceNumber}');
    } catch (e) {
      DebugHelper.printError('PdfInvoiceService', e);
      rethrow;
    }
  }
}
