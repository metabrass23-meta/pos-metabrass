import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import '../models/quotation/quotation_model.dart';
import '../utils/debug_helper.dart';

class PdfQuotationService {
  static const String companyName = 'META BRASS';
  static const String companyAddress =
      'Kacha Eminabadroad Siddique Colony Gujranwala, 055-8174471';
  static const String companyPhone = '055-8174471';
  static const String companyTagline =
      'Sanitary Fittings & Bathroom Accessories';

  // ✅ Speed Optimization: Cache logo and fonts
  static Uint8List? _cachedLogoBytes;
  static pw.Font? _cachedRegularFont;
  static pw.Font? _cachedBoldFont;

  /// Preload logo and fonts
  static Future<void> preloadAssets() async {
    if (_cachedLogoBytes != null && _cachedRegularFont != null) return;
    try {
      final ByteData logoData = await rootBundle.load('assets/images/metabras.png');
      _cachedLogoBytes = logoData.buffer.asUint8List();
      _cachedRegularFont = pw.Font.helvetica();
      _cachedBoldFont = pw.Font.helveticaBold();
    } catch (e) {
      print('Failed to preload assets for Quotation: $e');
    }
  }

  /// Generate PDF quotation and return bytes (Works on Web & Mobile/Desktop)
  static Future<Uint8List> generateQuotationPdf(QuotationModel quotation) async {
    try {
      final pdf = pw.Document();
      final regularFont = _cachedRegularFont ?? pw.Font.helvetica();
      final boldFont = _cachedBoldFont ?? pw.Font.helveticaBold();
      
      // ✅ Speed Optimization: Use cached bytes
      pw.MemoryImage? logoImage;
      if (_cachedLogoBytes != null) {
        logoImage = pw.MemoryImage(_cachedLogoBytes!);
      } else {
        try {
          final ByteData logoData = await rootBundle.load('assets/images/metabras.png');
          _cachedLogoBytes = logoData.buffer.asUint8List();
          logoImage = pw.MemoryImage(_cachedLogoBytes!);
        } catch (e) {
          print('Error loading logo asset: $e');
        }
      }

      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a5.copyWith(
            marginBottom: 5,
            marginLeft: 5,
            marginRight: 5,
            marginTop: 5,
          ),
          theme: pw.ThemeData.withFont(
            base: regularFont,
            bold: boldFont,
          ),
          build: (pw.Context context) {
            return pw.Container(
              width: double.infinity,
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(regularFont, boldFont, logoImage),
                  pw.SizedBox(height: 10),
                  _buildQuotationInfo(quotation, regularFont, boldFont),
                  pw.SizedBox(height: 10),
                  _buildCustomerInfo(quotation, regularFont, boldFont),
                  pw.SizedBox(height: 10),
                  _buildItemsTable(quotation, regularFont, boldFont),
                  pw.SizedBox(height: 15),
                  _buildTotalsSection(quotation, regularFont, boldFont),
                  pw.Spacer(),
                  _buildFooter(regularFont, boldFont),
                ],
              ),
            );
          },
        ),
      );

      return await pdf.save();
    } catch (e) {
      DebugHelper.printError('PdfQuotationService', e);
      rethrow;
    }
  }

  /// Build header section with logo and brand bar
  static pw.Widget _buildHeader(pw.Font regularFont, pw.Font boldFont, pw.MemoryImage? logoImage) {
    pw.Widget logoWidget = pw.SizedBox(height: 80);
    if (logoImage != null) {
      logoWidget = pw.Image(logoImage, height: 90, fit: pw.BoxFit.contain);
    }

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        pw.Row(
          mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
          crossAxisAlignment: pw.CrossAxisAlignment.center, // Vertically centered with logo
          children: [
            logoWidget,
            pw.Text(
              'QUOTATION',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                font: boldFont,
                color: PdfColor.fromInt(0xFF2B4EBF),
              ),
            ),
          ],
        ),
        pw.SizedBox(height: 12),
        pw.Stack(
          alignment: pw.Alignment.centerLeft,
          children: [
            pw.Container(
              height: 24,
              width: double.infinity,
              decoration: pw.BoxDecoration(color: PdfColor.fromInt(0xFF1C378A)),
              padding: const pw.EdgeInsets.symmetric(horizontal: 12),
              alignment: pw.Alignment.centerLeft,
              child: pw.Text(
                companyTagline.toUpperCase(),
                style: pw.TextStyle(color: PdfColors.white, fontSize: 10, fontWeight: pw.FontWeight.bold, font: boldFont),
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
        pw.SizedBox(height: 4),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(companyAddress, style: pw.TextStyle(fontSize: 9, font: regularFont)),
          ],
        ),
      ],
    );
  }

  static pw.Widget _buildArrow(PdfColor color) {
    return pw.Container(
      width: 10,
      height: 24,
      child: pw.Center(
        child: pw.Text(">>", style: pw.TextStyle(color: color, fontSize: 12, fontWeight: pw.FontWeight.bold)),
      ),
    );
  }

  static pw.Widget _buildQuotationInfo(QuotationModel quotation, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(border: pw.Border.all(color: PdfColors.grey300), borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text('Quotation #: ${quotation.quotationNumber}', style: pw.TextStyle(fontSize: 13, fontWeight: pw.FontWeight.bold, font: boldFont)),
              pw.SizedBox(height: 4),
              pw.Text('Date: ${DateFormat('dd MMM yyyy').format(quotation.dateIssued)}', style: pw.TextStyle(fontSize: 10, font: regularFont)),
              pw.Text('Valid Until: ${DateFormat('dd MMM yyyy').format(quotation.expiryDate)}', style: pw.TextStyle(fontSize: 10, font: regularFont)),
            ],
          ),
          pw.Text(quotation.status.name.toUpperCase(), style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: boldFont, color: PdfColors.blue800)),
        ],
      ),
    );
  }

  static pw.Widget _buildCustomerInfo(QuotationModel quotation, pw.Font regularFont, pw.Font boldFont) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      width: double.infinity,
      decoration: pw.BoxDecoration(color: PdfColors.grey100, borderRadius: pw.BorderRadius.circular(4)),
      child: pw.Text('FOR: ${quotation.customerName.toUpperCase()}', style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: boldFont)),
    );
  }

  static pw.Widget _buildItemsTable(QuotationModel quotation, pw.Font regularFont, pw.Font boldFont) {
    return pw.Table(
      border: pw.TableBorder.all(color: PdfColors.grey400, width: 0.5),
      columnWidths: {
        0: const pw.FixedColumnWidth(30),
        1: const pw.FlexColumnWidth(3),
        2: const pw.FixedColumnWidth(50),
        3: const pw.FixedColumnWidth(80),
        4: const pw.FixedColumnWidth(80),
      },
      children: [
        pw.TableRow(
          decoration: const pw.BoxDecoration(color: PdfColors.grey200),
          children: [
            _cell('Sr#', boldFont, align: pw.TextAlign.center),
            _cell('Products', boldFont),
            _cell('Qty', boldFont, align: pw.TextAlign.center),
            _cell('Price', boldFont, align: pw.TextAlign.right),
            _cell('Total', boldFont, align: pw.TextAlign.right),
          ],
        ),
        ...quotation.items.asMap().entries.map((e) => pw.TableRow(
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
    return pw.Padding(padding: const pw.EdgeInsets.all(6), child: pw.Text(text, style: pw.TextStyle(fontSize: 9, font: font), textAlign: align));
  }

  static pw.Widget _buildTotalsSection(QuotationModel quotation, pw.Font regularFont, pw.Font boldFont) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.end,
      children: [
        pw.Container(
          width: 200,
          child: pw.Column(
            children: [
              _totalRow('Subtotal', quotation.baseAmount, regularFont),
              if (quotation.discountAmount > 0) _totalRow('Discount', -quotation.discountAmount, regularFont),
              if (quotation.taxAmount > 0) _totalRow('Tax', quotation.taxAmount, regularFont),
              pw.Divider(thickness: 1),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  pw.Text('TOTAL', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: boldFont)),
                  pw.Text('Rs.${quotation.grandTotal.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold, font: boldFont)),
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
      padding: const pw.EdgeInsets.symmetric(vertical: 2),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(label, style: pw.TextStyle(fontSize: 10, font: font)),
          pw.Text('Rs.${value.toStringAsFixed(0)}', style: pw.TextStyle(fontSize: 10, font: font)),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font regularFont, pw.Font boldFont) {
    return pw.Column(
      children: [
        pw.Divider(thickness: 1),
        pw.SizedBox(height: 10),
        pw.Text('This is a formal quotation for your consideration.', style: pw.TextStyle(fontSize: 11, fontWeight: pw.FontWeight.bold, font: boldFont)),
        pw.SizedBox(height: 5),
        pw.Text('Generated via META BRASS System: ${DateFormat('dd MMM yyyy, hh:mm a').format(DateTime.now())}', style: pw.TextStyle(fontSize: 8, font: regularFont)),
      ],
    );
  }

  static Future<void> previewAndPrintQuotation(QuotationModel quotation) async {
    try {
      final pdfBytes = await generateQuotationPdf(quotation);
      await Printing.layoutPdf(onLayout: (PdfPageFormat format) async => pdfBytes, name: 'Quotation_${quotation.quotationNumber}');
    } catch (e) {
      DebugHelper.printError('PdfQuotationService', e);
      rethrow;
    }
  }
}
