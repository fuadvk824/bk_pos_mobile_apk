import 'dart:typed_data';
import 'dart:ui';

import 'package:bk_pos/model/product_model.dart';
import 'package:esc_pos_utils_plus/esc_pos_utils_plus.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:image/image.dart';
import 'package:print_bluetooth_thermal/print_bluetooth_thermal.dart';

class ThermalProductService {
 
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

  static Future<ProductPrintResult> connectPrinter() async {
    try {
      final bluetoothEnabled = await PrintBluetoothThermal.bluetoothEnabled;
      if (!bluetoothEnabled) {
        return ProductPrintResult(
          success: false,
          message: 'Bluetooth HP belum aktif.',
        );
      }

      final printer = await findPrinter();
      if (printer == null) {
        return ProductPrintResult(
          success: false,
          message:
              'Printer RPP02N tidak ditemukan.\n'
              'Pastikan printer sudah paired.',
        );
      }

      final alreadyConnected = await PrintBluetoothThermal.connectionStatus;
      if (alreadyConnected) {
        return ProductPrintResult(
          success: true,
          message: 'Printer siap digunakan.',
        );
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
        return ProductPrintResult(
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
        return ProductPrintResult(
          success: false,
          message: 'Koneksi printer belum stabil.',
        );
      }

      return ProductPrintResult(
        success: true,
        message: 'Printer siap digunakan.',
      );
    } catch (e) {
      debugPrint('Connect printer error: $e');

      return ProductPrintResult(
        success: false,
        message: 'Gagal menghubungkan printer:\n$e',
      );
    }
  }

  static Future<ProductPrintResult> printProductPrice({
    required ProductModel product,
    required GlobalKey printKey,
  }) async {
    try {
      final connected = await isPrinterConnected();

      if (!connected) {
        final connectResult = await connectPrinter();

        if (!connectResult.success) {
          return connectResult;
        }
      }

      await Future.delayed(const Duration(milliseconds: 500));

      final imageBytes = await _captureProductPrice(printKey);

      if (imageBytes == null) {
        return ProductPrintResult(
          success: false,
          message: 'Gagal mengambil gambar harga produk.',
        );
      }

      final bytes = await _convertToEscPos(imageBytes);
      final result = await PrintBluetoothThermal.writeBytes(bytes);

      if (!result) {
        await disconnectPrinter();

        return ProductPrintResult(
          success: false,
          message:
              'Gagal mengirim data ke printer.\n'
              'Silakan coba hubungkan kembali.',
        );
      }

      return ProductPrintResult(
        success: true,
        message: 'Harga produk berhasil dicetak.',
      );
    } catch (e) {
      debugPrint('Print product price error: $e');

      await disconnectPrinter();

      return ProductPrintResult(
        success: false,
        message: 'Error saat mencetak:\n$e',
      );
    }
  }

  static Future<Uint8List?> _captureProductPrice(GlobalKey printKey) async {
    try {
      final boundary =
          printKey.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        return null;
      }

      final image = await boundary.toImage(pixelRatio: 2.0);
      final byteData = await image.toByteData(format: ImageByteFormat.png);

      return byteData?.buffer.asUint8List();
    } catch (e) {
      debugPrint('Error capture product price: $e');

      return null;
    }
  }

  static Future<List<int>> _convertToEscPos(Uint8List imageBytes) async {
    final profile = await CapabilityProfile.load();
    final generator = Generator(PaperSize.mm80, profile);
    final image = decodeImage(imageBytes);

    if (image == null) {
      throw Exception('Gagal membaca image produk.');
    }

    final bytes = <int>[];

    bytes.addAll(generator.reset());
    bytes.addAll(generator.imageRaster(image, align: PosAlign.center));
    bytes.addAll(generator.feed(1));
    bytes.addAll(generator.cut());

    return bytes;
  }
}

class ProductPrintResult {
  final bool success;
  final String message;

  ProductPrintResult({required this.success, required this.message});
}
