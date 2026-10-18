import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/models/expense_model.dart';
import '../../../../core/utils/image_compressor_helper.dart';
import '../providers/add_expense_provider.dart';

class AddExpenseScreen extends ConsumerStatefulWidget {
  const AddExpenseScreen({super.key});

  @override
  ConsumerState<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends ConsumerState<AddExpenseScreen> {
  late final TextEditingController _titleController;
  late final TextEditingController _amountController;

  static const List<String> _categories = ['Food', 'Hostel', 'Fuel', 'Udhar'];

  @override
  void initState() {
    super.initState();
    final state = ref.read(addExpenseProvider);
    _titleController = TextEditingController(text: state.title);
    _amountController = TextEditingController(text: state.totalAmount.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _onAmountChanged(String val) {
    final parsed = int.tryParse(val) ?? 0;
    ref.read(addExpenseProvider.notifier).setTotalAmount(parsed);
  }

  Future<void> _pickReceipt(ImageSource source) async {
    HapticFeedback.lightImpact();
    final path = await ImageCompressorHelper.pickAndCompressImage(source: source);
    if (path != null) {
      ref.read(addExpenseProvider.notifier).setReceiptPath(path);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Receipt compressed to <150 KB and attached!')),
        );
      }
    }
  }

  void _showImageSourceDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(AppDimensions.modalSheetRadius),
              topRight: Radius.circular(AppDimensions.modalSheetRadius),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt_rounded, color: AppColors.mint),
                title: const Text('Take Photo of Bill'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.camera);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library_rounded, color: AppColors.indigo),
                title: const Text('Choose from Gallery'),
                onTap: () {
                  Navigator.pop(ctx);
                  _pickReceipt(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(addExpenseProvider);
    final notifier = ref.read(addExpenseProvider.notifier);
    final currencyFormatter = NumberFormat('#,###');

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final ctaBgColor = isDark ? AppColors.darkPillActive : AppColors.cockpitGradientStart;

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
            children: [
              // Cockpit Header: Back, "New expense", Hero Amount, "Paid by You in Hostel Gang"
              Padding(
                padding: const EdgeInsets.only(top: 10, left: 16, right: 16, bottom: 20),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white, size: 24),
                          onPressed: () => Navigator.of(context).pop(),
                        ),
                        Text(
                          'New expense',
                          style: AppTypography.bodySemiBold.copyWith(
                            color: AppColors.textDarkMuted,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(width: 48), // Balance close icon
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Hero Amount Display & Editable Field
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Rs ',
                          style: AppTypography.screenTitle.copyWith(
                            color: AppColors.mint,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        IntrinsicWidth(
                          child: TextField(
                            controller: _amountController,
                            keyboardType: TextInputType.number,
                            textAlign: TextAlign.center,
                            style: AppTypography.heroBalance.copyWith(
                              fontSize: 48,
                              color: Colors.white,
                              letterSpacing: -1,
                            ),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.zero,
                            ),
                            onChanged: _onAmountChanged,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),

                    // "Paid by You in Hostel Gang"
                    Text.rich(
                      TextSpan(
                        text: 'Paid by ',
                        style: AppTypography.caption.copyWith(
                          color: AppColors.textDarkMuted,
                          fontSize: 13,
                        ),
                        children: [
                          TextSpan(
                            text: state.payerName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: ' in ${state.groupName}'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Bottom 65% Surface Sheet
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
                    top: 22,
                    left: AppDimensions.screenHorizontalPadding,
                    right: AppDimensions.screenHorizontalPadding,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title Field with Underline
                      TextField(
                        controller: _titleController,
                        style: AppTypography.cardTitle.copyWith(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        ),
                        decoration: InputDecoration(
                          hintText: 'What was this expense for?',
                          hintStyle: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          ),
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
                        onChanged: notifier.setTitle,
                      ),

                      const SizedBox(height: 14),

                      // Category Pills
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        child: Row(
                          children: _categories.map((cat) {
                            final isSelected = cat == state.category;
                            final Color bgColor = isSelected
                                ? AppColors.mint
                                : (isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive);
                            final Color txtColor = isSelected
                                ? AppColors.textLightPrimary
                                : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted);

                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: InkWell(
                                onTap: () => notifier.setCategory(cat),
                                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: bgColor,
                                    borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                                  ),
                                  child: Text(
                                    cat,
                                    style: AppTypography.caption.copyWith(
                                      color: txtColor,
                                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Split Mode Segmented Bar
                      Container(
                        decoration: BoxDecoration(
                          color: isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _SplitTabItem(
                              title: 'Equal',
                              isSelected: state.splitMode == SplitMode.equal,
                              onTap: () => notifier.setSplitMode(SplitMode.equal),
                            ),
                            _SplitTabItem(
                              title: 'Exact',
                              isSelected: state.splitMode == SplitMode.exact,
                              onTap: () => notifier.setSplitMode(SplitMode.exact),
                            ),
                            _SplitTabItem(
                              title: 'Percent',
                              isSelected: state.splitMode == SplitMode.percent,
                              onTap: () => notifier.setSplitMode(SplitMode.percent),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 10),

                      // Odd-Rupee Remainder Notification Badge
                      if (state.hasRemainder && state.splitMode == SplitMode.equal)
                        Container(
                          margin: const EdgeInsets.only(bottom: 8),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: isDark ? AppColors.indigo.withOpacity(0.18) : AppColors.indigoSquircleBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '+Rs 1 rounding assigned to You (payer)',
                            style: AppTypography.caption.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: isDark ? AppColors.indigoTextDark : AppColors.indigoNotice,
                            ),
                          ),
                        ),

                      // Member Allocation Rows
                      Expanded(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.only(bottom: 80),
                          itemCount: state.members.length,
                          itemBuilder: (context, index) {
                            final m = state.members[index];
                            return _MemberShareRow(
                              initials: m.initials,
                              name: m.name,
                              amount: m.shareAmount,
                              colorHex: m.colorHex,
                            );
                          },
                        ),
                      ),

                      // Attach Receipt Dashed Button
                      InkWell(
                        onTap: _showImageSourceDialog,
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
                              style: BorderStyle.solid,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                state.receiptPath != null ? Icons.check_circle_rounded : Icons.camera_alt_outlined,
                                size: 16,
                                color: state.receiptPath != null ? AppColors.mint : AppColors.textLightMuted,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                state.receiptPath != null
                                    ? 'Receipt attached (<150 KB)'
                                    : 'Attach receipt (auto-compressed)',
                                style: AppTypography.caption.copyWith(
                                  color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Sticky Bottom Save Expense CTA
                      InkWell(
                        onTap: () async {
                          HapticFeedback.mediumImpact();
                          final success = await notifier.saveExpense();
                          if (success && context.mounted) {
                            Navigator.of(context).pop();
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'Logged Rs ${currencyFormatter.format(state.totalAmount)} successfully!',
                                ),
                              ),
                            );
                          }
                        },
                        borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                        child: Container(
                          height: AppDimensions.ctaHeight,
                          width: double.infinity,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: ctaBgColor,
                            borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                          ),
                          child: state.isSaving
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Save expense',
                                  style: AppTypography.cardTitle.copyWith(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w800,
                                    fontSize: 15,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(height: 16),
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

class _SplitTabItem extends StatelessWidget {
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  const _SplitTabItem({
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final Color activeBg = isDark ? AppColors.darkPillActive : Colors.white;
    final Color activeText = isDark ? Colors.white : AppColors.textLightPrimary;
    final Color inactiveText = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;

    return Expanded(
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap();
        },
        borderRadius: BorderRadius.circular(10),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          height: 36,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected ? activeBg : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
          ),
          child: Text(
            title,
            style: AppTypography.caption.copyWith(
              color: isSelected ? activeText : inactiveText,
              fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
              fontSize: 13,
            ),
          ),
        ),
      ),
    );
  }
}

class _MemberShareRow extends StatelessWidget {
  final String initials;
  final String name;
  final int amount;
  final String colorHex;

  const _MemberShareRow({
    required this.initials,
    required this.name,
    required this.amount,
    required this.colorHex,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat('#,###');

    // Parse color
    Color sqBg = Color(int.parse(colorHex.replaceAll('#', '0xFF')));
    Color sqText = Colors.white;

    if (initials == 'AL') {
      sqBg = isDark ? AppColors.darkPillActive : AppColors.cockpitGradientStart;
      sqText = Colors.white;
    } else if (initials == 'SH') {
      sqBg = isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg;
      sqText = isDark ? AppColors.mintTextDark : AppColors.mintTextLight;
    } else if (initials == 'KP') {
      sqBg = isDark ? AppColors.indigo.withOpacity(0.18) : AppColors.indigoSquircleBg;
      sqText = isDark ? AppColors.indigoTextDark : AppColors.indigoTextLight;
    } else if (initials == 'HM') {
      sqBg = isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg;
      sqText = isDark ? AppColors.roseTextDark : AppColors.roseTextLight;
    }

    final Color dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

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
              initials,
              style: TextStyle(
                color: sqText,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              name,
              style: AppTypography.cardTitle.copyWith(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
              ),
            ),
          ),
          Text(
            currencyFormatter.format(amount),
            style: AppTypography.rupeeAmount.copyWith(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
