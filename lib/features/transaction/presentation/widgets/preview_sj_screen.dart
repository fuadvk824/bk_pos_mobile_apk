import 'package:bk_pos/features/transaction/services/pdf_sj_service.dart';
import 'package:bk_pos/model/transaction_detail_model.dart';
import 'package:bk_pos/utils/app_toast.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PreviewSjScreen extends StatefulWidget {
  final TransactionDetailModel transaction;

  const PreviewSjScreen({super.key, required this.transaction});

  @override
  State<PreviewSjScreen> createState() => _PreviewSjScreenState();
}

class _PreviewSjScreenState extends State<PreviewSjScreen> {
  bool _generatingPdf = false;

  Future<void> _downloadPdf() async {
    if (_generatingPdf) return;

    setState(() {
      _generatingPdf = true;
    });

    try {
      await PdfSjService.generate(transaction: widget.transaction);

      if (!mounted) return;

      AppToast.success(
        title: "PDF Berhasil Dibuat",
        description: "Surat Jalan berhasil dibuat.",
      );

      await PdfSjService.share(transaction: widget.transaction);
    } catch (e) {
      if (!mounted) return;

      AppToast.error(title: "Gagal", description: e.toString());
    } finally {
      if (mounted) {
        setState(() {
          _generatingPdf = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final trx = widget.transaction;

    final printedDate = DateFormat(
      "dd-MMM-yyyy",
      "id_ID",
    ).format(DateTime.now());

    final totalQty = trx.items.fold<int>(0, (v, e) => v + e.quantity);
    final totalItem = trx.items.length;

    return Scaffold(
      backgroundColor: const Color(0xfff3f4f6),

      appBar: AppBar(
        title: const Text(
          "Preview Surat Jalan",
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 17),
        ),
        centerTitle: true,
      ),

      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),

              child: Center(
                child: Container(
                  width: double.infinity,
                  color: Colors.white,
                  padding: const EdgeInsets.all(20),

                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      //--------------------------------------
                      // HEADER
                      //--------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            width: 75,
                            height: 37,
                            color: Colors.red,
                            child: Image.asset(
                              "assets/images/logo.jpeg",
                              width: double.infinity,
                              height: double.infinity,
                              fit: BoxFit.fill,
                            ),
                          ),

                          const SizedBox(width: 8),

                          // Nama toko
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trx.companyName ?? "-",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    height: 1.15,
                                  ),
                                ),

                                const SizedBox(height: 3),

                                Text(
                                  trx.companyAddress ?? "-",
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 6,
                                    height: 1.2,
                                  ),
                                ),

                                const SizedBox(height: 2),

                                const Text(
                                  "Telp : -",
                                  style: TextStyle(fontSize: 6),
                                ),
                              ],
                            ),
                          ),

                          const SizedBox(width: 6),

                          // Box Pengiriman (diperkecil)
                          SizedBox(
                            width: 95,
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.5, // tipiskan border
                                ),
                              ),
                              child: Column(
                                children: [
                                  Container(
                                    height: 13,
                                    alignment: Alignment.center,
                                    decoration: const BoxDecoration(
                                      border: Border(
                                        bottom: BorderSide(
                                          color: Colors.black,
                                          width: 0.5,
                                        ),
                                      ),
                                    ),
                                    child: const Text(
                                      "Surat Jalan",
                                      style: TextStyle(
                                        fontSize: 8,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),

                                  _HeaderRow("Tanggal", printedDate),

                                  Container(height: 0.5, color: Colors.black),

                                  _HeaderRow("Nota", trx.invoiceNumber),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      //--------------------------------------
                      // CUSTOMER
                      //--------------------------------------
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CUSTOMER
                          SizedBox(
                            width: MediaQuery.of(context).size.width * 0.40,
                            child: Container(
                              padding: const EdgeInsets.fromLTRB(4, 4, 4, 12),
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Text(
                                    "Kepada Yth :",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),

                                  const SizedBox(height: 2),

                                  Text(
                                    trx.storeName ?? "-",
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 8,
                                    ),
                                  ),

                                  SizedBox(height: 2),

                                  Text(
                                    trx.storeAddress ?? "-",
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(
                                      fontSize: 6,
                                      height: 1.2,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const Spacer(),

                          // OPERATOR
                          SizedBox(
                            width: 95,
                            child: Align(
                              alignment: Alignment.topRight,
                              child: Container(
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.black,
                                    width: 0.5,
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      height: 13,
                                      alignment: Alignment.center,
                                      decoration: const BoxDecoration(
                                        border: Border(
                                          bottom: BorderSide(
                                            color: Colors.black,
                                            width: 0.5,
                                          ),
                                        ),
                                      ),
                                      child: const Text(
                                        "Operator",
                                        style: TextStyle(
                                          fontSize: 8,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),

                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 2,
                                        vertical: 2,
                                      ),
                                      child: Text(
                                        trx.printedBy ?? "-",
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(fontSize: 6),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      //--------------------------------------
                      // TABLE
                      //--------------------------------------
                      Column(
                        children: [
                          Table(
                            border: TableBorder.all(
                              color: Colors.black,
                              width: 0.5,
                            ),
                            columnWidths: const {
                              0: FixedColumnWidth(22),
                              1: FixedColumnWidth(65),
                              2: FlexColumnWidth(),
                              3: FixedColumnWidth(32),
                              4: FixedColumnWidth(35),
                            },
                            children: [
                              const TableRow(
                                decoration: BoxDecoration(
                                  color: Color(0xffe5e7eb),
                                ),
                                children: [
                                  _TableHeader("No"),
                                  _TableHeader("Item"),
                                  _TableHeader("Deskripsi"),
                                  _TableHeader("Qty"),
                                  _TableHeader("Unit"),
                                ],
                              ),

                              ...List.generate(trx.items.length, (index) {
                                final item = trx.items[index];

                                return TableRow(
                                  children: [
                                    _TableCell("${index + 1}", center: true),

                                    _TableCell(item.productCode),

                                    _TableCell(item.productName),

                                    _TableCell(
                                      item.quantity.toString(),
                                      center: true,
                                    ),

                                    _TableCell(item.unit, center: true),
                                  ],
                                );
                              }),
                            ],
                          ),

                          Container(
                            width: double.infinity,
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                                right: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                                bottom: BorderSide(
                                  color: Colors.black,
                                  width: 0.5,
                                ),
                              ),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 4,
                              vertical: 4,
                            ),
                            alignment: Alignment.centerRight,
                            child: Text(
                              "JUMLAH : $totalQty ($totalItem Unit)",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 6,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 15),

                      //--------------------------------------
                      // KETERANGAN
                      //--------------------------------------
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Keterangan :",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 8,
                              ),
                            ),

                            const SizedBox(height: 4),

                            Text(
                              // trx.customerName ?? "-",
                              "${trx.customerName ?? "-"} (${trx.customerPhone ?? "-"})",
                              style: TextStyle(fontSize: 6),
                            ),
                            Text(
                              trx.customerAddress ?? "-",
                              style: TextStyle(fontSize: 6),
                            ),

                            SizedBox(height: 4),

                            Text(
                              trx.notes?.isEmpty ?? true ? "-" : trx.notes!,
                              style: const TextStyle(fontSize: 6, height: 1.2),
                            ),

                            const SizedBox(height: 30),
                          ],
                        ),
                      ),

                      Row(
                        children: const [
                          Expanded(child: _Signature("Gudang")),
                          SizedBox(width: 24),
                          Expanded(child: _Signature("Di Check Oleh")),
                          SizedBox(width: 24),
                          Expanded(child: _Signature("Tanda Terima")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SafeArea(
            top: false,
            child: Container(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton.icon(
                  onPressed: _generatingPdf ? null : _downloadPdf,
                  icon: _generatingPdf
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.picture_as_pdf),
                  label: Text(
                    _generatingPdf ? "Membuat PDF..." : "Download / Share PDF",
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderRow extends StatelessWidget {
  final String title;
  final String value;

  const _HeaderRow(this.title, this.value);

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        children: [
          SizedBox(
            width: 27,
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Container(width: 0.5, color: Colors.black),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(2),
              child: Text(
                value,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TableHeader extends StatelessWidget {
  final String text;

  const _TableHeader(this.text);

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 8,
          height: 1.1,
        ),
      ),
    );
  }
}

class _TableCell extends StatelessWidget {
  final String text;
  final bool center;

  const _TableCell(this.text, {this.center = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: center ? Alignment.center : Alignment.centerLeft,
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: Text(text, style: const TextStyle(fontSize: 6, height: 1.15)),
    );
  }
}


class _Signature extends StatelessWidget {
  final String title;

  const _Signature(this.title);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 65),

        Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.black,
                width: 0.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 5),

        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 7,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}