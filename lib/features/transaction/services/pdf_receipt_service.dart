import 'dart:io';

import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:flutter/services.dart' show rootBundle;

class PdfReceiptService {
  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Future<File> generateReceiptPdf({
    required TransactionDetailModel transaction,
  }) async {
    final logoBytes = await rootBundle.load('assets/images/logo.jpeg');
    final logoImage = pw.MemoryImage(logoBytes.buffer.asUint8List());

    final pdf = pw.Document();

    final printedDate = DateFormat(
      'dd/MM/yyyy HH:mm',
      'id_ID',
    ).format(DateTime.now());

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat(
          80 * PdfPageFormat.mm,
          double.infinity,
          marginLeft: 4 * PdfPageFormat.mm,
          marginRight: 4 * PdfPageFormat.mm,
          marginTop: 4 * PdfPageFormat.mm,
          marginBottom: 4 * PdfPageFormat.mm,
        ),

        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.stretch,
            children: [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.center,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      mainAxisSize: pw.MainAxisSize.min,
                      children: [
                        pw.Text(
                          transaction.storeView ?? 'Bisa Kulak Gresik',
                          maxLines: 1,
                          overflow: pw.TextOverflow.clip,
                          style: pw.TextStyle(
                            fontSize: 8,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),

                        pw.SizedBox(height: 2),
                        pw.Text(
                          transaction.storeAddress ??
                              'Jl. Raya kepatihan No.49, Kecamatan Menganti, Kabupaten Gresik, Jawa Timur',
                          maxLines: 2,
                          style: pw.TextStyle(fontSize: 4, height: 1.2),
                        ),
                        pw.SizedBox(height: 1),
                        pw.Text(
                          'No. Telp: ${transaction.storePhone}',
                          style: pw.TextStyle(fontSize: 4, height: 1.2),
                        ),
                      ],
                    ),
                  ),

                  pw.SizedBox(width: 2),

                  pw.SizedBox(
                    width: 75,
                    height: 50,
                    child: pw.Image(logoImage, fit: pw.BoxFit.contain),
                  ),
                ],
              ),

              pw.SizedBox(height: 4),
              pw.Container(
                height: 0.2,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.2),
                  ),
                ),
              ),
              pw.SizedBox(height: 2),

              _infoRow('Invoice', transaction.invoiceNumber),
              _infoRow('Tanggal', printedDate),
              _infoRow('Kasir', transaction.printedBy ?? '-'),

              pw.SizedBox(height: 2),
              pw.Container(
                height: 0.2,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.2),
                  ),
                ),
              ),

              pw.SizedBox(height: 2),
              ...transaction.items.map((item) {
                final quantity = item.quantity;
                final unitPrice = item.price;
                final itemTotal = item.subtotal;

                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2),

                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.stretch,

                    children: [
                      pw.Text(
                        item.productName,
                        style: pw.TextStyle(fontSize: 5),
                      ),

                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

                        children: [
                          pw.Text(
                            '${quantity}x @${currency.format(unitPrice)}',
                            style: pw.TextStyle(fontSize: 5),
                          ),

                          pw.Text(
                            currency.format(itemTotal),
                            style: pw.TextStyle(fontSize: 5),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              }),

              pw.SizedBox(height: 2),
              pw.Container(
                height: 0.2,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.2),
                  ),
                ),
              ),

              pw.SizedBox(height: 2),
              _infoRow('Subtotal', currency.format(transaction.subtotal)),
              _infoRow('Ongkir', currency.format(transaction.shippingCost)),
              _infoRow(
                'Point/Diskon',
                '-${currency.format(transaction.pointsUsed + transaction.nego)}',
              ),

              pw.SizedBox(height: 2),
              _infoRow('TOTAL', currency.format(transaction.total), bold: true),

              pw.SizedBox(height: 2),
              pw.Container(
                height: 0.2,
                decoration: const pw.BoxDecoration(
                  border: pw.Border(
                    bottom: pw.BorderSide(color: PdfColors.black, width: 0.2),
                  ),
                ),
              ),

              pw.SizedBox(height: 4),
              pw.Text(
                'Informasi & Layanan Pelanggan\nTerima kasih, selamat berbelanja kembali!',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 5),
              ),

              pw.Text(
                'Barang yang sudah dibeli tidak dapat dikembalikan',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 5),
              ),

              pw.SizedBox(height: 2),
              pw.Text(
                'Layanan Pelanggan Bisa Kulak',
                textAlign: pw.TextAlign.center,
                style: pw.TextStyle(fontSize: 5),
              ),

              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.center,
                children: [
                  pw.Flexible(
                    child: pw.Text(
                      transaction.storeEmail ?? 'bisakulakpusat@gmail.com',
                      maxLines: 1,
                      textAlign: pw.TextAlign.right,
                      style: pw.TextStyle(fontSize: 5),
                    ),
                  ),

                  pw.Text('  -  ', style: pw.TextStyle(fontSize: 5)),

                  pw.Flexible(
                    child: pw.Text(
                      '085173372019',
                      maxLines: 1,
                      textAlign: pw.TextAlign.left,
                      style: pw.TextStyle(fontSize: 5),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );

    final directory = await getApplicationDocumentsDirectory();
    final fileName = '${transaction.invoiceNumber}.pdf';

    final file = File('${directory.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    return file;
  }

  static pw.Widget _infoRow(String label, String value, {bool bold = false}) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(vertical: 1),

      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,

        children: [
          pw.Text(
            label,
            style: pw.TextStyle(
              fontSize: 5,
              fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
            ),
          ),

          pw.Flexible(
            child: pw.Text(
              value,
              textAlign: pw.TextAlign.right,
              style: pw.TextStyle(
                fontSize: 5,
                fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Future<void> shareReceiptPdf({
    required TransactionDetailModel transaction,
  }) async {
    final file = await generateReceiptPdf(transaction: transaction);

    await Printing.sharePdf(
      bytes: await file.readAsBytes(),
      filename: file.path.split('/').last,
    );
  }
}
