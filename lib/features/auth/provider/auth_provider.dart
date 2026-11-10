import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/storage/token_manager.dart';
import '../../../model/user_model.dart';
import '../data/auth_repository.dart';

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(),
);

final authLoadingProvider = StateProvider<bool>((ref) => false);

final authProvider =
    StateNotifierProvider<AuthNotifier, AsyncValue<UserModel?>>(
      (ref) => AuthNotifier(ref.read(authRepositoryProvider), ref),
    );

class AuthNotifier extends StateNotifier<AsyncValue<UserModel?>> {
  final AuthRepository repo;
  final Ref ref;

  Timer? _tokenExpiryTimer;

  AuthNotifier(this.repo, this.ref) : super(const AsyncValue.loading()) {
    loadUser();
  }

  Future<String?> login(String login, String password) async {
    ref.read(authLoadingProvider.notifier).state = true;

    try {
      final user = await repo.login(login, password);

      state = AsyncValue.data(user);

      _startTokenExpiryTimer();

      return null;
    } catch (e) {
      state = const AsyncValue.data(null);

      return e.toString().replaceFirst('Exception: ', '');
    } finally {
      ref.read(authLoadingProvider.notifier).state = false;
    }
  }

  Future<void> loadUser() async {
    try {
      // Periksa token lokal terlebih dahulu.
      if (TokenManager.token == null || TokenManager.isExpired) {
        await TokenManager.clear();

        if (!mounted) return;

        state = const AsyncValue.data(null);
        return;
      }

      // Request API dibatasi maksimal 15 detik.
      final user = await repo.me().timeout(const Duration(seconds: 15));

      if (!mounted) return;

      state = AsyncValue.data(user);

      _startTokenExpiryTimer();
    } on DioException catch (e, st) {
      final statusCode = e.response?.statusCode;

      // Token memang tidak valid.
      if (statusCode == 401 || statusCode == 403) {
        await TokenManager.clear();

        if (!mounted) return;

        state = const AsyncValue.data(null);
        return;
      }

      // Error jaringan/server tidak boleh menghapus token.
      if (!mounted) return;

      state = AsyncValue.error(e, st);
    } on TimeoutException catch (e, st) {
      // Request terlalu lama.
      // Token tetap disimpan.
      if (!mounted) return;

      state = AsyncValue.error(e, st);
    } catch (e, st) {
      // Error lainnya juga jangan langsung menghapus token.
      if (!mounted) return;

      state = AsyncValue.error(e, st);
    }
  }

  void _startTokenExpiryTimer() {
    _tokenExpiryTimer?.cancel();

    final remaining = TokenManager.remainingDuration;

    if (remaining == null || remaining <= Duration.zero) {
      _handleTokenExpired();
      return;
    }

    _tokenExpiryTimer = Timer(remaining, _handleTokenExpired);
  }

  Future<void> _handleTokenExpired() async {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;

    await TokenManager.clear();

    if (!mounted) return;

    state = const AsyncValue.data(null);
  }

  Future<void> logout() async {
    _tokenExpiryTimer?.cancel();
    _tokenExpiryTimer = null;

    await repo.logout();

    if (!mounted) return;

    state = const AsyncValue.data(null);
  }

  @override
  void dispose() {
    _tokenExpiryTimer?.cancel();
    super.dispose();
  }
}
