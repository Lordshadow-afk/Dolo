import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

class QuickLendBorrowSheet extends StatefulWidget {
  final String peerName;
  final bool isLent; // true for "I lent", false for "I borrowed"
  final ValueChanged<({int amount, String title, String category})> onConfirm;

  const QuickLendBorrowSheet({
    super.key,
    required this.peerName,
    required this.isLent,
    required this.onConfirm,
  });

  @override
  State<QuickLendBorrowSheet> createState() => _QuickLendBorrowSheetState();
}

class _QuickLendBorrowSheetState extends State<QuickLendBorrowSheet> {
  static const List<int> _presetChips = [100, 200, 500, 1000, 2000];
  static const List<String> _categories = ['Udhar', 'Food', 'Fuel', 'Printouts', 'Hostel'];

  int? _selectedAmount = 500;
  String _selectedCategory = 'Udhar';
  final TextEditingController _customAmountController = TextEditingController(text: '500');
  final TextEditingController _titleController = TextEditingController(text: 'Cash loan');

  @override
  void dispose() {
    _customAmountController.dispose();
    _titleController.dispose();
    super.dispose();
  }

  void _onChipSelected(int amount) {
    HapticFeedback.lightImpact();
    setState(() {
      _selectedAmount = amount;
      _customAmountController.text = amount.toString();
    });
  }

  void _onCustomAmountChanged(String val) {
    final parsed = int.tryParse(val);
    setState(() {
      _selectedAmount = parsed;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;
    final themeColor = widget.isLent ? AppColors.mint : AppColors.rose;
    final titleText = widget.isLent
        ? 'You lent to ${widget.peerName}'
        : 'You borrowed from ${widget.peerName}';

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppDimensions.modalSheetRadius),
          topRight: Radius.circular(AppDimensions.modalSheetRadius),
        ),
      ),
      padding: EdgeInsets.only(
        top: 14,
        left: AppDimensions.screenHorizontalPadding,
        right: AppDimensions.screenHorizontalPadding,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            titleText,
            style: AppTypography.screenTitle.copyWith(
              fontSize: 20,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            'Tap a preset chip to log in under 2 seconds',
            style: AppTypography.caption.copyWith(
              color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 18),

          // 1-Tap Preset Numeric Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _presetChips.map((amount) {
                final isSelected = _selectedAmount == amount;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () => _onChipSelected(amount),
                    borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? themeColor
                            : (isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive),
                        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                      ),
                      child: Text(
                        'Rs $amount',
                        style: AppTypography.rupeeAmount.copyWith(
                          fontSize: 14,
                          color: isSelected
                              ? (widget.isLent ? AppColors.textLightPrimary : Colors.white)
                              : (isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary),
                          fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 16),

          // Custom Amount Input
          Container(
            decoration: BoxDecoration(
              color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
              borderRadius: BorderRadius.circular(16),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                Text(
                  'Rs',
                  style: AppTypography.screenTitle.copyWith(
                    color: themeColor,
                    fontSize: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: _customAmountController,
                    keyboardType: TextInputType.number,
                    style: AppTypography.heroBalance.copyWith(
                      fontSize: 26,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      hintText: '0',
                    ),
                    onChanged: _onCustomAmountChanged,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // Category Pills
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: _categories.map((cat) {
                final isSelected = cat == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: InkWell(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() {
                        _selectedCategory = cat;
                        if (_titleController.text.isEmpty ||
                            _titleController.text == 'Cash loan') {
                          _titleController.text = cat == 'Udhar' ? 'Cash loan' : cat;
                        }
                      });
                    },
                    borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? (isDark ? AppColors.darkPillActive : AppColors.textLightPrimary)
                            : (isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive),
                        borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                      ),
                      child: Text(
                        cat,
                        style: AppTypography.caption.copyWith(
                          color: isSelected
                              ? Colors.white
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted),
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          const SizedBox(height: 20),

          // Confirm Action CTA
          InkWell(
            onTap: () {
              final amount = _selectedAmount ?? 0;
              if (amount > 0) {
                HapticFeedback.mediumImpact();
                widget.onConfirm((
                  amount: amount,
                  title: _titleController.text.trim().isEmpty
                      ? 'Cash loan'
                      : _titleController.text.trim(),
                  category: _selectedCategory,
                ));
                Navigator.of(context).pop();
              }
            },
            borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
            child: Container(
              height: AppDimensions.ctaHeight,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: themeColor,
                borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
              ),
              child: Text(
                'Log Rs ${_selectedAmount ?? 0} Now',
                style: AppTypography.cardTitle.copyWith(
                  color: widget.isLent ? AppColors.textLightPrimary : Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
