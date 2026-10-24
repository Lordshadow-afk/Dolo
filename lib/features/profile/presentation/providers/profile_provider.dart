import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';

class UserProfile {
  final String name;
  final String phone;
  final String raastId;
  final String accountTitle;
  final String bankName;
  final String avatarInitials;

  const UserProfile({
    this.name = 'Ali Raza',
    this.phone = '03001234567',
    this.raastId = '03001234567',
    this.accountTitle = 'Ali Raza',
    this.bankName = 'SadaPay',
    this.avatarInitials = 'AL',
  });

  UserProfile copyWith({
    String? name,
    String? phone,
    String? raastId,
    String? accountTitle,
    String? bankName,
    String? avatarInitials,
  }) {
    return UserProfile(
      name: name ?? this.name,
      phone: phone ?? this.phone,
      raastId: raastId ?? this.raastId,
      accountTitle: accountTitle ?? this.accountTitle,
      bankName: bankName ?? this.bankName,
      avatarInitials: avatarInitials ?? this.avatarInitials,
    );
  }
}

final userProfileProvider = StateNotifierProvider<UserProfileNotifier, UserProfile>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return UserProfileNotifier(db);
});

class UserProfileNotifier extends StateNotifier<UserProfile> {
  final AppDatabase _db;

  UserProfileNotifier(this._db)
      : super(
          const UserProfile(
            name: 'Ali Raza',
            phone: '03001234567',
            raastId: '03001234567',
            accountTitle: 'Ali Raza',
            bankName: 'SadaPay / Raast',
            avatarInitials: 'AL',
          ),
        ) {
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final db = await _db.database;
      final results = await db.query(
        DbTables.contacts,
        where: 'id = ?',
        whereArgs: ['user_self'],
        limit: 1,
      );
      if (results.isNotEmpty) {
        final row = results.first;
        final name = row['name'] as String? ?? 'Ali Raza';
        final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'AL';
        state = state.copyWith(
          name: name,
          phone: row['phone'] as String? ?? '',
          raastId: row['raast_id'] as String? ?? '03001234567',
          accountTitle: name,
          avatarInitials: initials,
        );
      }
    } catch (_) {}
  }

  Future<void> updateProfile({
    required String name,
    required String phone,
    required String raastId,
    String bankName = 'SadaPay',
  }) async {
    final initials = name.length >= 2 ? name.substring(0, 2).toUpperCase() : 'AL';
    state = state.copyWith(
      name: name,
      phone: phone,
      raastId: raastId,
      accountTitle: name,
      bankName: bankName,
      avatarInitials: initials,
    );

    try {
      final db = await _db.database;
      await db.update(
        DbTables.contacts,
        {
          'name': name,
          'phone': phone,
          'raast_id': raastId,
          'avatar_initials': initials,
        },
        where: 'id = ?',
        whereArgs: ['user_self'],
      );
    } catch (_) {}
  }
}

/// Convenience alias — used by settlement/profile screens as `profileProvider`.
final profileProvider = userProfileProvider;
