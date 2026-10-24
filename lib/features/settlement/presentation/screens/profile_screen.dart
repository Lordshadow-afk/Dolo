import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../presentation/providers/profile_provider.dart';

/// Profile Screen (Screen 7) — Pay Me QR, Raast ID, Edit navigation.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final String name = profile.name;
    final String phone = profile.phone;
    final String raastId = profile.raastId;
    final String bankName = profile.bankName;
    final String avatarInitial =
        name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : 'U';

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Profile & Pay Me QR'),
        elevation: 0,
        backgroundColor: Colors.transparent,
        actions: [
          TextButton.icon(
            onPressed: () => _navigateToEditProfile(context, ref),
            icon: const Icon(Icons.edit_rounded, size: 16),
            label: const Text('Edit'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding:
            const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Column(
          children: [
            // ── User Identity Card ────────────────────────────────────
            _Card(
              isDark: isDark,
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: AppColors.indigoSquircleBg,
                    child: Text(
                      avatarInitial,
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.indigoDeep,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name.isNotEmpty ? name : 'Your Name',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark
                                ? AppColors.textDarkPrimary
                                : AppColors.textLightPrimary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          phone.isNotEmpty ? phone : 'Add phone number',
                          style: const TextStyle(
                              color: AppColors.textLightMuted,
                              fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Pay Me QR Card ────────────────────────────────────────
            _Card(
              isDark: isDark,
              child: Column(
                children: [
                  const Text(
                    'PAY ME QR',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  // QR Code generated from Raast ID
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(AppDimensions.cardRadius),
                      border: Border.all(
                          color: AppColors.lightBorder, width: 1.5),
                    ),
                    child: QrImageView(
                      data: raastId.isNotEmpty
                          ? 'raast:$raastId'
                          : 'raast:03001234567',
                      version: QrVersions.auto,
                      size: 180,
                      backgroundColor: Colors.white,
                      errorStateBuilder: (ctx, _) => const SizedBox(
                        width: 180,
                        height: 180,
                        child: Center(
                          child: Text(
                            'Set Raast ID\nto generate QR',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: AppColors.textLightMuted),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Raast ID: ${raastId.isNotEmpty ? raastId : "Not set"}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textLightMuted,
                        fontSize: 13),
                  ),
                  const SizedBox(height: 12),
                  // Share QR button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () =>
                          Share.share('Pay me via Raast: $raastId (Dolo)'),
                      icon: const Icon(Icons.share_rounded, size: 16),
                      label: const Text('Share QR / Raast ID'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.mint,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(
                              AppDimensions.ctaRadius),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Payment Details Card ──────────────────────────────────
            _Card(
              isDark: isDark,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'PAYMENT DETAILS',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.5,
                      color: AppColors.textLightMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _DetailRow(
                    label: 'Bank / Wallet',
                    value: bankName.isNotEmpty ? bankName : 'Not set',
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  _DetailRow(
                    label: 'Raast ID / IBAN',
                    value: raastId.isNotEmpty ? raastId : 'Not set',
                    isDark: isDark,
                    onCopy: raastId.isNotEmpty
                        ? () {
                            Clipboard.setData(
                                ClipboardData(text: raastId));
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Raast ID copied!'),
                                duration: Duration(seconds: 2),
                              ),
                            );
                          }
                        : null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // ── Settings Rows ─────────────────────────────────────────
            _Card(
              isDark: isDark,
              child: Column(
                children: [
                  _SettingsRow(
                    icon: Icons.group_rounded,
                    label: 'Group Nicknames',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.notifications_rounded,
                    label: 'Reminders',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.sync_rounded,
                    label: 'Cloud Sync',
                    isDark: isDark,
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  _SettingsRow(
                    icon: Icons.palette_rounded,
                    label: 'Appearance & App Icon',
                    isDark: isDark,
                    onTap: () {},
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  void _navigateToEditProfile(BuildContext context, WidgetRef ref) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _EditProfileSheet(ref: ref),
    );
  }
}

// ─── Shared Card Wrapper ─────────────────────────────────────────────────────

class _Card extends StatelessWidget {
  final Widget child;
  final bool isDark;
  const _Card({required this.child, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: child,
    );
  }
}

// ─── Detail Row ───────────────────────────────────────────────────────────────

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isDark;
  final VoidCallback? onCopy;
  const _DetailRow(
      {required this.label,
      required this.value,
      required this.isDark,
      this.onCopy});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textLightMuted)),
        Row(
          children: [
            Text(
              value,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: isDark
                      ? AppColors.textDarkPrimary
                      : AppColors.textLightPrimary),
            ),
            if (onCopy != null) ...[
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onCopy,
                child: const Icon(Icons.copy_rounded,
                    size: 14, color: AppColors.textLightMuted),
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ─── Settings Row ────────────────────────────────────────────────────────────

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isDark;
  final VoidCallback onTap;
  const _SettingsRow(
      {required this.icon,
      required this.label,
      required this.isDark,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: Icon(icon, color: AppColors.indigo, size: 22),
      title: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.w500,
            color: isDark
                ? AppColors.textDarkPrimary
                : AppColors.textLightPrimary),
      ),
      trailing: const Icon(Icons.chevron_right_rounded,
          color: AppColors.textLightMuted),
      contentPadding: EdgeInsets.zero,
    );
  }
}

// ─── Edit Profile Bottom Sheet ───────────────────────────────────────────────

class _EditProfileSheet extends ConsumerStatefulWidget {
  final WidgetRef ref;
  const _EditProfileSheet({required this.ref});

  @override
  ConsumerState<_EditProfileSheet> createState() =>
      _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<_EditProfileSheet> {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _phoneCtrl;
  late final TextEditingController _raastCtrl;
  late final TextEditingController _bankCtrl;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(profileProvider);
    _nameCtrl = TextEditingController(text: profile.name);
    _phoneCtrl = TextEditingController(text: profile.phone);
    _raastCtrl = TextEditingController(text: profile.raastId);
    _bankCtrl = TextEditingController(text: profile.bankName);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _phoneCtrl.dispose();
    _raastCtrl.dispose();
    _bankCtrl.dispose();
    super.dispose();
  }

  void _save() {
    ref.read(profileProvider.notifier).updateProfile(
          name: _nameCtrl.text.trim(),
          phone: _phoneCtrl.text.trim(),
          raastId: _raastCtrl.text.trim(),
          bankName: _bankCtrl.text.trim(),
        );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkSurface : Colors.white,
          borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppDimensions.radiusXL)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Edit Profile',
                style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            const Text(
              'Your Pay Me QR updates automatically when you save.',
              style: TextStyle(
                  color: AppColors.textLightMuted, fontSize: 13),
            ),
            const SizedBox(height: 20),
            _Field(controller: _nameCtrl, label: 'Full Name'),
            const SizedBox(height: 12),
            _Field(
                controller: _phoneCtrl,
                label: 'Phone (for WhatsApp)',
                keyboardType: TextInputType.phone),
            const SizedBox(height: 12),
            _Field(
                controller: _raastCtrl,
                label: 'Raast ID / IBAN',
                keyboardType: TextInputType.text),
            const SizedBox(height: 12),
            _Field(
                controller: _bankCtrl,
                label: 'Bank / Wallet (e.g. SadaPay)'),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: AppDimensions.ctaHeight,
              child: ElevatedButton(
                onPressed: _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.mint,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppDimensions.ctaRadius)),
                  elevation: 0,
                ),
                child: const Text('Save changes',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final TextInputType keyboardType;
  const _Field({
    required this.controller,
    required this.label,
    this.keyboardType = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
    );
  }
}
