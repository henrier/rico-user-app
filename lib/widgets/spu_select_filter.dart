import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import '../common/constants/app_constants.dart' as constants;

class SpuSelectFilterOption {
  final String id;
  final String label;

  const SpuSelectFilterOption({required this.id, required this.label});
}

class SpuSelectFilterSection {
  final String title;
  final List<SpuSelectFilterOption> options;

  const SpuSelectFilterSection({required this.title, required this.options});
}

typedef SpuFilterSelections = Map<String, Set<String>>; // sectionTitle -> set of option ids

Future<SpuFilterSelections?> showSpuSelectFilter(
  BuildContext context, {
  required List<SpuSelectFilterSection> sections,
  SpuFilterSelections? initialSelections,
  String title = 'Filtering',
  String clearText = 'Clear',
  String confirmText = 'Confirm',
}) {
  return showGeneralDialog<SpuFilterSelections>(
    context: context,
    barrierColor: const Color(0xB3000000), // rgba(0,0,0,0.7) 匹配Figma设计
    barrierDismissible: true,
    barrierLabel: 'Dismiss',
    transitionDuration: constants.AppConstants.mediumAnimation,
    pageBuilder: (context, _, __) {
      return Align(
        alignment: Alignment.centerRight,
        child: _SpuSelectFilterDrawer(
          sections: sections,
          initialSelections: initialSelections,
          title: title,
          clearText: clearText,
          confirmText: confirmText,
        ),
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curved = CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return SlideTransition(
        position: Tween<Offset>(begin: const Offset(1.0, 0.0), end: Offset.zero).animate(curved),
        child: child,
      );
    },
  );
}

class _SpuSelectFilterDrawer extends StatefulWidget {
  final List<SpuSelectFilterSection> sections;
  final SpuFilterSelections? initialSelections;
  final String title;
  final String clearText;
  final String confirmText;

  const _SpuSelectFilterDrawer({
    required this.sections,
    this.initialSelections,
    required this.title,
    required this.clearText,
    required this.confirmText,
  });

  @override
  State<_SpuSelectFilterDrawer> createState() => _SpuSelectFilterDrawerState();
}

class _SpuSelectFilterDrawerState extends State<_SpuSelectFilterDrawer> {
  late SpuFilterSelections selections;

  @override
  void initState() {
    super.initState();
    selections = {};
    for (final section in widget.sections) {
      final preset = widget.initialSelections?[section.title];
      selections[section.title] = preset != null ? Set<String>.from(preset) : <String>{};
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final drawerWidth = 479.w; // 根据Figma设计稿宽度

    return Material(
      color: Colors.transparent,
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => Navigator.of(context).maybePop(),
              ),
            ),
            Container(
              width: drawerWidth,
              height: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1A000000), // rgba(0,0,0,0.1)
                    blurRadius: 12.r,
                    offset: Offset(-4.w, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: 40.w,
                      vertical: 30.h,
                    ),
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: const Color(0xFF212222),
                        fontWeight: FontWeight.w500,
                        fontSize: 36.sp, // 根据Figma设计稿调整
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  Expanded(
                    child: ListView.separated(
                      padding: EdgeInsets.symmetric(
                        horizontal: 40.w,
                        vertical: 20.h,
                      ),
                      itemCount: widget.sections.length,
                      separatorBuilder: (_, __) => SizedBox(height: 40.h),
                      itemBuilder: (context, index) {
                        final section = widget.sections[index];
                        final selected = selections[section.title]!;
                        return _FilterSection(
                          title: section.title,
                          options: section.options,
                          selected: selected,
                          onToggle: (optionId) {
                            setState(() {
                              if (selected.contains(optionId)) {
                                selected.remove(optionId);
                              } else {
                                selected.add(optionId);
                              }
                            });
                          },
                        );
                      },
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(40.w),
                    child: Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 88.h, // 根据Figma设计稿高度
                            decoration: BoxDecoration(
                              color: const Color(0xFFF4F4F4),
                              borderRadius: BorderRadius.circular(44.r), // 完全圆角
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(44.r),
                                onTap: () {
                                  // 清空所有选择并立即返回空结果
                                  final emptySelections = <String, Set<String>>{};
                                  for (final key in selections.keys) {
                                    emptySelections[key] = <String>{};
                                  }
                                  Navigator.of(context).pop(emptySelections);
                                },
                                child: Center(
                                  child: Text(
                                    widget.clearText,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF090909),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32.sp, // 根据Figma设计稿调整
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 25.w), // 根据Figma设计稿间距
                        Expanded(
                          child: Container(
                            height: 88.h, // 根据Figma设计稿高度
                            decoration: BoxDecoration(
                              color: const Color(0xFF0DEE80),
                              borderRadius: BorderRadius.circular(44.r), // 完全圆角
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                borderRadius: BorderRadius.circular(44.r),
                                onTap: () {
                                  Navigator.of(context).pop(selections);
                                },
                                child: Center(
                                  child: Text(
                                    widget.confirmText,
                                    style: theme.textTheme.titleMedium?.copyWith(
                                      color: const Color(0xFF090909),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32.sp, // 根据Figma设计稿调整
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSection extends StatelessWidget {
  final String title;
  final List<SpuSelectFilterOption> options;
  final Set<String> selected;
  final ValueChanged<String> onToggle;

  const _FilterSection({
    required this.title,
    required this.options,
    required this.selected,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.only(left: 8.w),
          child: Text(
            title, 
            style: theme.textTheme.titleMedium?.copyWith(
              color: const Color(0xFF212222),
              fontWeight: FontWeight.w500,
              fontSize: 24.sp, // 根据Figma设计稿调整
            ),
          ),
        ),
        SizedBox(height: 20.h),
        // 使用网格布局来更好地控制间距和对齐
        Wrap(
          spacing: 20.w, // 根据Figma设计调整间距
          runSpacing: 20.h, // 垂直间距
          alignment: WrapAlignment.start,
          children: [
            for (final opt in options)
              _SelectableChip(
                label: opt.label,
                selected: selected.contains(opt.id),
                onTap: () => onToggle(opt.id),
              ),
          ],
        ),
      ],
    );
  }
}

class _SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _SelectableChip({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      height: 54.h, // 根据Figma设计的高度
      constraints: BoxConstraints(
        minWidth: 99.w, // 最小宽度，根据Figma中最小的chip
        maxWidth: 143.w, // 最大宽度，根据Figma中最大的chip
      ),
      decoration: BoxDecoration(
        color: selected ? const Color(0xFF0DEE80) : const Color(0xFFF4F4F4),
        borderRadius: BorderRadius.circular(27.r), // 完全圆角
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(27.r),
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 13.h),
            child: Center(
              child: Text(
                label,
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: const Color(0xFF212222),
                  fontWeight: FontWeight.w400,
                  fontSize: 24.sp, // 根据Figma设计稿调整
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
