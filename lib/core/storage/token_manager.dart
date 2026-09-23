import 'package:bk_pos/core/storage/secure_storage.dart';
import 'package:flutter/foundation.dart';

class TokenManager {
  static String? _token;
  static DateTime? _expiresAt;
  static String? get token => _token;
  static DateTime? get expiresAt => _expiresAt;

  static bool get isExpired {
    if (_token == null || _expiresAt == null) {
      return true;
    }

    return !DateTime.now().isBefore(_expiresAt!);
  }

  static Duration? get remainingDuration {
    if (_expiresAt == null) {
      return null;
    }

    final remaining = _expiresAt!.difference(DateTime.now());

    if (remaining.isNegative) {
      return Duration.zero;
    }

    return remaining;
  }

  static Future<void> init() async {
    try {
      final token = await SecureStorage.read('token');
      final expiresAtString = await SecureStorage.read('token_expires_at');

      if (token == null || expiresAtString == null) {
        _token = null;
        _expiresAt = null;
        return;
      }

      final expiresAt = DateTime.tryParse(expiresAtString);

      if (expiresAt == null || !DateTime.now().isBefore(expiresAt)) {
        await clear();
        return;
      }

      _token = token;
      _expiresAt = expiresAt;
    } catch (e, stackTrace) {
      debugPrint('TokenManager.init ERROR: $e');
      debugPrintStack(stackTrace: stackTrace);

      _token = null;
      _expiresAt = null;
    }
  }

  static Future<void> set(String token) async {
    // Masa berlaku token lokal.
    const duration = Duration(hours: 3);
    final expiresAt = DateTime.now().add(duration);

    _token = token;
    _expiresAt = expiresAt;

    await SecureStorage.write('token', token);
    await SecureStorage.write('token_expires_at', expiresAt.toIso8601String());
  }

  static Future<void> clear() async {
    _token = null;
    _expiresAt = null;

    await SecureStorage.delete('token');
    await SecureStorage.delete('token_expires_at');
  }
}
