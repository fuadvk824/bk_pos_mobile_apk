import 'dart:io';

import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:bk_pos/model/transaction_detail_model.dart';

class PdfSjService {
  // Standard font seperti Microsoft Word
  static const double bodyFont = 12;
  static const double smallFont = 10;
  static const double subTitleFont = 14;
  static const double titleFont = 18;

  static const PdfPageFormat sjPaper = PdfPageFormat(
    9.5 * PdfPageFormat.inch,
    11 * PdfPageFormat.inch,
  );

  static Future<File> generate({
    required TransactionDetailModel transaction,
  }) async {
    final logoBytes = await rootBundle.load("assets/images/logo.jpeg");
    final logo = pw.MemoryImage(logoBytes.buffer.asUint8List());
    final pdf = pw.Document();

    final printedDate = DateFormat(
      "dd-MMM-yyyy",
      "id_ID",
    ).format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        // pageFormat: PdfPageFormat.a4,
        // margin: const pw.EdgeInsets.all(56),
        pageFormat: sjPaper,
        margin: const pw.EdgeInsets.fromLTRB(20, 15, 20, 15),
        build: (context) {
          return [
            _header(logo, transaction, printedDate),
            pw.SizedBox(height: 15),
            _customerSection(transaction),
            pw.SizedBox(height: 15),
            _table(transaction),
            pw.SizedBox(height: 15),
            _footer(transaction),
          ];
        },
      ),
    );

    final dir = await getApplicationDocumentsDirectory();
    final file = File(
      "${dir.path}/surat_jalan_${transaction.invoiceNumber}.pdf",
    );
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static Future<void> share({
    required TransactionDetailModel transaction,
  }) async {
    final file = await generate(transaction: transaction);

    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split("/").last,
    );
  }

  static pw.Widget cell(String text, {bool center = false, bool bold = false}) {
    return pw.Container(
      alignment: center ? pw.Alignment.center : pw.Alignment.centerLeft,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: bodyFont,
          fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
        ),
      ),
    );
  }

  static pw.Widget _infoBox({
    required String title,
    required pw.Widget child,
    double width = 110,
  }) {
    return pw.Container(
      width: width,
      decoration: pw.BoxDecoration(border: pw.Border.all(width: .5)),
      child: pw.Column(
        children: [
          pw.Container(
            width: double.infinity,
            height: 16,
            alignment: pw.Alignment.center,
            decoration: const pw.BoxDecoration(
              border: pw.Border(bottom: pw.BorderSide(width: .5)),
            ),
            child: pw.Text(
              title,
              style: pw.TextStyle(
                fontSize: subTitleFont,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          ),
          child,
        ],
      ),
    );
  }

  static pw.Widget _tableHeader(String title) {
    return pw.Container(
      alignment: pw.Alignment.center,
      padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: pw.Text(
        title,
        textAlign: pw.TextAlign.center,
        style: pw.TextStyle(fontSize: bodyFont, fontWeight: pw.FontWeight.bold),
      ),
    );
  }

  static pw.Widget _header(
    pw.MemoryImage logo,
    TransactionDetailModel trx,
    String printedDate,
  ) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // LOGO
        pw.Container(
          width: 100,
          height: 50,
          child: pw.Image(logo, fit: pw.BoxFit.fill),
        ),

        pw.SizedBox(width: 8),

        // COMPANY
        pw.Expanded(
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                trx.companyName ?? "-",
                maxLines: 2,
                style: pw.TextStyle(
                  fontSize: titleFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 3),

              pw.Text(
                trx.companyAddress ?? "-",
                maxLines: 2,
                style: const pw.TextStyle(fontSize: bodyFont, lineSpacing: 1.2),
              ),

              pw.SizedBox(height: 2),

              pw.Text("Telp : -", style: pw.TextStyle(fontSize: bodyFont)),
            ],
          ),
        ),

        pw.SizedBox(width: 6),

        // BOX PENGIRIMAN
        _infoBox(
          title: "Surat Jalan",
          width: 110,
          child: pw.Table(
            border: const pw.TableBorder(
              verticalInside: pw.BorderSide(width: .5),
              horizontalInside: pw.BorderSide(width: .5),
            ),
            columnWidths: const {
              0: pw.FixedColumnWidth(38),
              1: pw.FlexColumnWidth(),
            },
            children: [
              pw.TableRow(
                children: [cell("Tanggal", bold: true), cell(printedDate)],
              ),
              pw.TableRow(
                children: [cell("Nota", bold: true), cell(trx.invoiceNumber)],
              ),
            ],
          ),
        ),
      ],
    );
  }

  static pw.Widget _customerSection(TransactionDetailModel trx) {
    return pw.Row(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // CUSTOMER
        pw.Container(
          width: 220,
          padding: const pw.EdgeInsets.fromLTRB(4, 4, 4, 12),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: .5)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Kepada Yth :",
                style: pw.TextStyle(
                  fontSize: subTitleFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 2),

              pw.Text(
                trx.storeView ?? "-",
                maxLines: 1,
                style: pw.TextStyle(
                  fontSize: bodyFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 2),

              pw.Text(
                trx.storeAddress ?? "-",
                maxLines: 2,
                style: const pw.TextStyle(fontSize: bodyFont, lineSpacing: 1.2),
              ),
            ],
          ),
        ),

        pw.Spacer(),

        // OPERATOR
        _infoBox(
          title: "Operator",
          width: 110,
          child: pw.Container(
            height: 34,
            alignment: pw.Alignment.center,
            child: pw.Text(
              trx.printedBy ?? "-",
              style: const pw.TextStyle(fontSize: bodyFont),
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _table(TransactionDetailModel trx) {
    final totalQty = trx.items.fold<int>(0, (v, e) => v + e.quantity);
    final totalItem = trx.items.length;

    return pw.Column(
      children: [
        pw.Table(
          border: pw.TableBorder.all(color: PdfColors.black, width: .5),

          columnWidths: const {
            0: pw.FixedColumnWidth(22),
            1: pw.FixedColumnWidth(65),
            2: pw.FlexColumnWidth(),
            3: pw.FixedColumnWidth(32),
            4: pw.FixedColumnWidth(35),
          },

          children: [
            pw.TableRow(
              decoration: const pw.BoxDecoration(color: PdfColors.grey300),

              children: [
                _tableHeader("No"),
                _tableHeader("Item"),
                _tableHeader("Deskripsi"),
                _tableHeader("Qty"),
                _tableHeader("Unit"),
              ],
            ),

            ...List.generate(trx.items.length, (index) {
              final item = trx.items[index];

              return pw.TableRow(
                children: [
                  cell("${index + 1}", center: true),
                  cell(item.productCode),
                  cell(item.productName),
                  cell(item.quantity.toString(), center: true),
                  cell(item.unit, center: true),
                ],
              );
            }),
          ],
        ),

        // TOTAL
        pw.Container(
          width: double.infinity,

          decoration: const pw.BoxDecoration(
            border: pw.Border(
              left: pw.BorderSide(width: .5),
              right: pw.BorderSide(width: .5),
              bottom: pw.BorderSide(width: .5),
            ),
          ),

          padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 4),

          alignment: pw.Alignment.centerRight,

          child: pw.Text(
            "JUMLAH : $totalQty ($totalItem Unit)",

            style: pw.TextStyle(
              fontSize: bodyFont,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  static pw.Widget _footer(TransactionDetailModel trx) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        // KETERANGAN
        pw.Container(
          width: double.infinity,
          padding: const pw.EdgeInsets.all(4),
          decoration: pw.BoxDecoration(border: pw.Border.all(width: .5)),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Keterangan :",
                style: pw.TextStyle(
                  fontSize: subTitleFont,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                "${trx.customerName ?? "-"} (${trx.customerPhone ?? "-"})",
                style: const pw.TextStyle(fontSize: bodyFont),
              ),

              pw.Text(
                trx.customerAddress ?? "-",
                style: const pw.TextStyle(fontSize: bodyFont),
              ),

              pw.SizedBox(height: 4),

              pw.Text(
                (trx.notes?.isEmpty ?? true) ? "-" : trx.notes!,
                style: const pw.TextStyle(fontSize: bodyFont, lineSpacing: 1.2),
              ),

              pw.SizedBox(height: 30),
            ],
          ),
        ),

        pw.SizedBox(height: 25),

        // SIGNATURE
        pw.Row(
          children: [
            pw.Expanded(child: _signature("Gudang")),

            pw.SizedBox(width: 24),

            pw.Expanded(child: _signature("Di Check Oleh")),

            pw.SizedBox(width: 24),

            pw.Expanded(child: _signature("Tanda Terima")),
          ],
        ),
      ],
    );
  }



  static pw.Widget _signature(String title) {
    return pw.Column(
      children: [
        pw.SizedBox(height: 65),

        pw.Container(
          width: double.infinity,
          decoration: const pw.BoxDecoration(
            border: pw.Border(top: pw.BorderSide(width: .5)),
          ),
        ),

        pw.SizedBox(height: 5),

        pw.Text(
          title,
          textAlign: pw.TextAlign.center,
          style: pw.TextStyle(
            fontSize: bodyFont,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
