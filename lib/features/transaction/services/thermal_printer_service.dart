import 'dart:typed_data';
import 'dart:ui';

import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart';
import 'package:intl/intl.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

import 'package:bk_pos/model/transaction_detail_model.dart';

class ThermalPrinterService {
  static final currency = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  static Future<List<BluetoothInfo>> getPairedPrinters() async {
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;

      debugPrint('Jumlah Bluetooth paired: ${devices.length}');

      for (final device in devices) {
        debugPrint(
          'Bluetooth: ${device.name} - ${device.macAdress}',
        );
      }

      return devices;
    } catch (e) {
      debugPrint('Error mengambil Bluetooth paired: $e');
      return [];
    }
  }

  static Future<bool> isBluetoothEnabled() async {
    try {
      return await PrintBluetoothThermal.bluetoothEnabled;
    } catch (e) {
      debugPrint('Error cek Bluetooth: $e');
      return false;
    }
  }

  static Future<bool> isPrinterConnected() async {
    try {
      return await PrintBluetoothThermal.connectionStatus;
    } catch (e) {
      debugPrint('Error cek koneksi printer: $e');
      return false;
    }
  }

  static Future<PrintResult> connectToPrinter(
    BluetoothInfo printer,
  ) async {
    try {
      final bluetoothEnabled = await isBluetoothEnabled();

      if (!bluetoothEnabled) {
        return PrintResult(
          success: false,
          message: 'Bluetooth HP belum aktif.',
        );
      }

      final alreadyConnected = await isPrinterConnected();

      if (alreadyConnected) {
        return PrintResult(
          success: true,
          message: 'Printer sudah terhubung.',
        );
      }

      debugPrint(
        'Mencoba connect ke: '
        '${printer.name} - ${printer.macAdress}',
      );

      try {
        await PrintBluetoothThermal.disconnect;
      } catch (_) {}

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      bool connected;

      try {
        connected = await PrintBluetoothThermal.connect(
          macPrinterAddress: printer.macAdress,
        ).timeout(
          const Duration(seconds: 8),
          onTimeout: () {
            debugPrint('Timeout connect printer.');
            return false;
          },
        );
      } catch (e) {
        debugPrint('Error connect: $e');

        return PrintResult(
          success: false,
          message: 'Gagal menghubungkan ke ${printer.name}.',
        );
      }

      if (!connected) {
        return PrintResult(
          success: false,
          message:
              'Tidak berhasil terhubung ke ${printer.name}.\n'
              'Pastikan printer menyala dan tidak terhubung ke perangkat lain.',
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 500),
      );

      final verified = await isPrinterConnected();

      if (!verified) {
        return PrintResult(
          success: false,
          message: 'Koneksi printer belum terverifikasi.',
        );
      }

      return PrintResult(
        success: true,
        message: '${printer.name} berhasil terhubung.',
      );
    } catch (e) {
      debugPrint('Connect printer error: $e');

      return PrintResult(
        success: false,
        message: 'Error koneksi printer:\n$e',
      );
    }
  }

  static Future<void> disconnectPrinter() async {
    try {
      final connected = await isPrinterConnected();

      if (connected) {
        await PrintBluetoothThermal.disconnect;

        debugPrint('Printer berhasil disconnect');
      }
    } catch (e) {
      debugPrint('Error disconnect printer: $e');
    }
  }

  static Future<PrintResult> printReceipt({
    required TransactionDetailModel transaction,
    required GlobalKey receiptKey,
  }) async {
    try {
      final connected = await isPrinterConnected();

      if (!connected) {
        return PrintResult(
          success: false,
          message: 'Printer belum terhubung.',
        );
      }

      await Future.delayed(
        const Duration(milliseconds: 300),
      );

      final imageBytes = await _captureReceipt(receiptKey);

      if (imageBytes == null) {
        return PrintResult(
          success: false,
          message: 'Gagal mengambil gambar nota.',
        );
      }

      final bytes = await _convertToEscPos(imageBytes);

      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (!result) {
        return PrintResult(
          success: false,
          message: 'Gagal mengirim data ke printer.',
        );
      }

      return PrintResult(
        success: true,
        message: 'Nota berhasil dicetak.',
      );
    } catch (e) {
      debugPrint('Print error: $e');

      return PrintResult(
        success: false,
        message: 'Error saat mencetak:\n$e',
      );
    }
  }

  static Future<Uint8List?> _captureReceipt(
    GlobalKey receiptKey,
  ) async {
    try {
      final boundary =
          receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(
        pixelRatio: 2.0,
      );

      final byteData = await image.toByteData(
        format: ImageByteFormat.png,
      );

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capture nota: $e');
      return null;
    }
  }

  static Future<List<int>> _convertToEscPos(
    Uint8List imageBytes,
  ) async {
    final profile = await CapabilityProfile.load();

    final generator = Generator(
      PaperSize.mm80,
      profile,
    );

    final image = decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Gagal membaca image nota.');
    }

    final cropHeight = image.height > 20
        ? image.height - 20
        : image.height;

    final croppedImage = copyCrop(
      image,
      x: 0,
      y: image.height > 20 ? 20 : 0,
      width: image.width,
      height: cropHeight,
    );

    final bytes = <int>[];

    bytes.addAll(generator.reset());

    bytes.addAll(
      generator.imageRaster(
        croppedImage,
        align: PosAlign.center,
      ),
    );

    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.cut());

    return bytes;
  }
}

class PrintResult {
  final bool success;
  final String message;

  PrintResult({
    required this.success,
    required this.message,
  });
}
