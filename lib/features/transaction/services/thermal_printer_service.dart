

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

  static Future<BluetoothInfo?> findPrinter() async {
    try {
      final devices = await PrintBluetoothThermal.pairedBluetooths;

      if (devices.isEmpty) {
        debugPrint('Tidak ada perangkat Bluetooth yang sudah paired');
        return null;
      }

      for (final device in devices) {
        debugPrint(
          'Bluetooth ditemukan: '
          '${device.name} - ${device.macAdress}',
        );

        final name = device.name.toUpperCase().trim();

        if (name.contains('RPP02N')) {
          return device;
        }
      }

      return null;
    } catch (e) {
      debugPrint('Error mencari printer: $e');
      return null;
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

  static Future<void> disconnectPrinter() async {
    try {
      final connected = await PrintBluetoothThermal.connectionStatus;

      if (connected) {
        await PrintBluetoothThermal.disconnect;
        debugPrint('Printer berhasil disconnect');
      }
    } catch (e) {
      debugPrint('Error disconnect printer: $e');
    }
  }

  static Future<PrintResult> connectPrinter() async {
    try {
      final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;

      if (!bluetoothEnabled) {
        return PrintResult(
          success: false,
          message: 'Bluetooth HP belum aktif.',
        );
      }


      final printer = await findPrinter();

      if (printer == null) {
        return PrintResult(
          success: false,
          message:
              'Printer RPP02N tidak ditemukan.\n'
              'Pastikan printer sudah paired.',
        );
      }

      final alreadyConnected = await PrintBluetoothThermal.connectionStatus;

      if (alreadyConnected) {
        return PrintResult(success: true, message: 'Printer siap digunakan.');
      }

      try {
        await PrintBluetoothThermal.disconnect;
      } catch (_) {}

      await Future.delayed(const Duration(milliseconds: 500));

      debugPrint(
        'Mencoba connect ke printer: '
        '${printer.macAdress}',
      );

      final connected = await PrintBluetoothThermal.connect(
        macPrinterAddress: printer.macAdress,
      );

      if (!connected) {
        return PrintResult(
          success: false,
          message:
              'Printer ditemukan, '
              'tetapi gagal terhubung.\n'
              'Coba matikan lalu nyalakan printer.',
        );
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final verified = await PrintBluetoothThermal.connectionStatus;

      if (!verified) {
        return PrintResult(
          success: false,
          message: 'Koneksi printer belum stabil.',
        );
      }

      return PrintResult(success: true, message: 'Printer siap digunakan.');
    } catch (e) {
      debugPrint('Connect printer error: $e');

      return PrintResult(
        success: false,
        message: 'Gagal menghubungkan printer:\n$e',
      );
    }
  }

  static Future<PrintResult> printReceipt({
    required TransactionDetailModel transaction,
    required GlobalKey receiptKey,
  }) async {
    try {
      final connected = await isPrinterConnected();

      if (!connected) {
        final connectResult = await connectPrinter();

        if (!connectResult.success) {
          return connectResult;
        }
      }

      await Future.delayed(const Duration(milliseconds: 300));
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
        await disconnectPrinter();

        return PrintResult(
          success: false,
          message:
              'Gagal mengirim data ke printer.\n'
              'Silakan tekan Coba Hubungkan.',
        );
      }

      return PrintResult(success: true, message: 'Nota berhasil dicetak.');
    } catch (e) {
      debugPrint('Print error: $e');

      await disconnectPrinter();

      return PrintResult(success: false, message: 'Error saat mencetak:\n$e');
    }
  }

  static Future<Uint8List?> _captureReceipt(GlobalKey receiptKey) async {
    try {
      final boundary =
          receiptKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capture nota: $e');
      return null;
    }
  }

  static Future<List<int>> _convertToEscPos(Uint8List imageBytes) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final image = decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Gagal membaca image nota.');
    }

    final croppedImage = copyCrop(
      image,
      x: 0,
      y: 20,
      width: image.width,
      height: image.height - 20,
    );
    final bytes = <int>[];

    bytes.addAll(generator.reset());
    bytes.addAll(generator.imageRaster(croppedImage, align: PosAlign.center));
    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.cut());

    return bytes;
  }
}

class PrintResult {
  final bool success;
  final String message;

  PrintResult({required this.success, required this.message});
}
