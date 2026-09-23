import 'dart:async';

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
      if (TokenManager.token == null || TokenManager.isExpired) {
        await TokenManager.clear();

        state = const AsyncValue.data(null);
        return;
      }

      final user = await repo.me();

      state = AsyncValue.data(user);

      _startTokenExpiryTimer();
    } catch (_) {
      await TokenManager.clear();

      state = const AsyncValue.data(null);
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
 