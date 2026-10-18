import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

class MemberNicknameEntry {
  final String name;
  final String initials;
  final String colorHex;
  String nickname;
  final bool isShadow;

  MemberNicknameEntry({
    required this.name,
    required this.initials,
    required this.colorHex,
    required this.nickname,
    this.isShadow = false,
  });
}

class NewGroupScreen extends StatefulWidget {
  const NewGroupScreen({super.key});

  @override
  State<NewGroupScreen> createState() => _NewGroupScreenState();
}

class _NewGroupScreenState extends State<NewGroupScreen> {
  final TextEditingController _groupNameController = TextEditingController(text: 'Hostel Gang');

  final List<MemberNicknameEntry> _members = [
    MemberNicknameEntry(
      name: 'You',
      initials: 'AL',
      colorHex: '#09121F',
      nickname: 'Ali',
    ),
    MemberNicknameEntry(
      name: 'Sheeda',
      initials: 'SH',
      colorHex: '#DDF7F2',
      nickname: 'Sheeda',
    ),
    MemberNicknameEntry(
      name: 'Hamza',
      initials: 'HM',
      colorHex: '#FFE4EA',
      nickname: 'Kaptaan',
      isShadow: true, // Module 18: Shadow member
    ),
  ];

  @override
  void dispose() {
    _groupNameController.dispose();
    super.dispose();
  }

  Future<void> _inviteViaWhatsApp() async {
    HapticFeedback.lightImpact();
    final groupName = _groupNameController.text.trim();
    final message =
        'Join our group *$groupName* on Dolo to easily track and split hostel expenses with 0 mental math!';
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('whatsapp://send?text=$encoded');
    final fallbackUrl = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {}
  }

  void _showAddMemberDialog() {
    final nameController = TextEditingController();
    final nickController = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text('Add Group Member'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Friend Name / Contact'),
              ),
              TextField(
                controller: nickController,
                decoration: const InputDecoration(labelText: 'Group Nickname (e.g. Sheeda)'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                final nick = nickController.text.trim();
                if (name.isNotEmpty) {
                  final inits = name.length >= 2 ? name.substring(0, 2).toUpperCase() : name.toUpperCase();
                  setState(() {
                    _members.add(MemberNicknameEntry(
                      name: name,
                      initials: inits,
                      colorHex: '#DDF7F2',
                      nickname: nick.isEmpty ? name : nick,
                      isShadow: true,
                    ));
                  });
                  Navigator.pop(ctx);
                }
              },
              child: const Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkCockpitGradientStart, AppColors.darkCockpitGradientEnd]
                : [AppColors.cockpitGradientStart, AppColors.cockpitGradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cockpit Header (Height 110px)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'New group',
                          style: AppTypography.screenTitle.copyWith(
                            color: Colors.white,
                            fontSize: 26,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Name it and set nicknames.',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textDarkMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // Surface Sheet
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.surfaceSheetRadius),
                      topRight: Radius.circular(AppDimensions.surfaceSheetRadius),
                    ),
                  ),
                  padding: const EdgeInsets.only(
                    top: 24,
                    left: AppDimensions.screenHorizontalPadding,
                    right: AppDimensions.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // GROUP NAME Label
                      Text(
                        'GROUP NAME',
                        style: AppTypography.sectionLabel.copyWith(
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Group Name Field
                      TextField(
                        controller: _groupNameController,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        decoration: InputDecoration(
                          enabledBorder: UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: isDark ? AppColors.darkBorder : AppColors.cockpitGradientStart,
                              width: 2,
                            ),
                          ),
                          focusedBorder: const UnderlineInputBorder(
                            borderSide: BorderSide(
                              color: AppColors.mint,
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // MEMBERS AND NICKNAMES Label
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'MEMBERS AND NICKNAMES',
                            style: AppTypography.sectionLabel.copyWith(
                              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                              fontSize: 12,
                            ),
                          ),
                          InkWell(
                            onTap: _showAddMemberDialog,
                            child: Text(
                              '+ Add',
                              style: AppTypography.caption.copyWith(
                                color: AppColors.mint,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),

                      // Members with Group Nicknames List
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          itemCount: _members.length,
                          itemBuilder: (context, index) {
                            final m = _members[index];
                            return _MemberNicknameRow(
                              entry: m,
                              isDark: isDark,
                              onNicknameChanged: (val) {
                                m.nickname = val;
                              },
                            );
                          },
                        ),
                      ),

                      // + Invite via WhatsApp Button
                      InkWell(
                        onTap: _inviteViaWhatsApp,
                        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                        child: Container(
                          width: double.infinity,
                          height: 44,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.darkSurface : Colors.white,
                            borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                            border: Border.all(
                              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                              width: 1.5,
                            ),
                          ),
                          child: Text(
                            '+ Invite via WhatsApp',
                            style: AppTypography.caption.copyWith(
                              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      Center(
                        child: Text(
                          'Nicknames are visible to everyone in this group.',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Create Group CTA
                      InkWell(
                        onTap: () {
                          HapticFeedback.mediumImpact();
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Group "${_groupNameController.text}" created!'),
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                        child: Container(
                          height: AppDimensions.ctaHeight,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.mint,
                            borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                          ),
                          child: Text(
                            'Create group',
                            style: AppTypography.cardTitle.copyWith(
                              color: AppColors.textLightPrimary,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MemberNicknameRow extends StatefulWidget {
  final MemberNicknameEntry entry;
  final bool isDark;
  final ValueChanged<String> onNicknameChanged;

  const _MemberNicknameRow({
    required this.entry,
    required this.isDark,
    required this.onNicknameChanged,
  });

  @override
  State<_MemberNicknameRow> createState() => _MemberNicknameRowState();
}

class _MemberNicknameRowState extends State<_MemberNicknameRow> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.entry.nickname);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final dividerColor = widget.isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    Color sqBg = widget.isDark ? AppColors.darkPillActive : AppColors.cockpitGradientStart;
    Color sqText = Colors.white;

    if (widget.entry.initials == 'SH') {
      sqBg = widget.isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg;
      sqText = widget.isDark ? AppColors.mintTextDark : AppColors.mintTextLight;
    } else if (widget.entry.initials == 'HM') {
      sqBg = widget.isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg;
      sqText = widget.isDark ? AppColors.roseTextDark : AppColors.roseTextLight;
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 11),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
      ),
      child: Row(
        children: [
          Container(
            width: AppDimensions.squircleSmallSize,
            height: AppDimensions.squircleSmallSize,
            decoration: BoxDecoration(
              color: sqBg,
              borderRadius: BorderRadius.circular(AppDimensions.squircleSmallRadius),
            ),
            alignment: Alignment.center,
            child: Text(
              widget.entry.initials,
              style: TextStyle(
                color: sqText,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      widget.entry.name,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: widget.isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    if (widget.entry.isShadow) ...[
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: widget.isDark
                              ? AppColors.indigo.withOpacity(0.18)
                              : AppColors.indigoSquircleBg,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'Shadow',
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: widget.isDark ? AppColors.indigoTextDark : AppColors.indigoNotice,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  'Nickname in group',
                  style: AppTypography.caption.copyWith(
                    color: widget.isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Pill input for nickname
          Container(
            width: 100,
            height: 40,
            decoration: BoxDecoration(
              color: widget.isDark ? AppColors.darkSurface : Colors.white,
              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
              border: Border.all(
                color: widget.isDark ? AppColors.darkBorder : AppColors.lightBorder,
                width: 1.5,
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            alignment: Alignment.center,
            child: TextField(
              controller: _controller,
              style: AppTypography.caption.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: widget.isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              onChanged: widget.onNicknameChanged,
            ),
          ),
        ],
      ),
    );
  }
}
