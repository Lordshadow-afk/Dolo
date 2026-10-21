import 'package:flutter_riverpod/flutter_riverpod.dart';

class UserProfile {
  final String name;
  final String phone;
  final String bankName;
  final String raastId;

  const UserProfile({
    this.name = 'Ashir Bin Hamid',
    this.phone = '03001234567',
    this.bankName = 'SadaPay',
    this.raastId = '03001234567',
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? bankName,
    String? raastId,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      bankName: bankName ?? this.bankName,
      raastId: raastId ?? this.raastId,
    );
  }
}

class ProfileNotifier extends StateNotifier<UserProfile> {
  ProfileNotifier() : super(const UserProfile());

  void updateProfile({
    String? name,
    String? phone,
    String? bankName,
    String? raastId,
  }) {
    state = state.copyWith(
      name: name,
      phone: phone,
      bankName: bankName,
      raastId: raastId,
    );
  }
}

final profileProvider = StateNotifierProvider<ProfileNotifier, UserProfile>((ref) {
  return ProfileNotifier();
});