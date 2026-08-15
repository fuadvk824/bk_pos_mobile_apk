import 'package:bk_pos/features/profile/data/profile_repository.dart';
import 'package:bk_pos/model/user_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final profileRepositoryProvider = Provider<ProfileRepository>(
  (ref) => ProfileRepository(),
);

class ProfileState {
  final UserModel? user;
  final bool isLoading;

  const ProfileState({this.user, this.isLoading = false});

  ProfileState copyWith({UserModel? user, bool? isLoading}) {
    return ProfileState(
      user: user ?? this.user,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository repo;

  ProfileNotifier(this.repo) : super(const ProfileState()) {
    load();
  }

  Future<void> load() async {
    state = state.copyWith(isLoading: true);

    try {
      final user = await repo.getUserInfo();

      state = state.copyWith(user: user, isLoading: false);
    } catch (_) {
      state = state.copyWith(isLoading: false);
    }
  }

  Future<void> refresh() async {
    await load();
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>(
  (ref) => ProfileNotifier(ref.read(profileRepositoryProvider)),
);
