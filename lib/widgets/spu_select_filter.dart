import 'package:flutter/material.dart';

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
    barrierColor: Colors.black45,
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
    final media = MediaQuery.of(context);
    final drawerWidth = media.size.width * 0.78; // leave left gap to tap back

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
                color: theme.colorScheme.surface,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 12,
                    offset: const Offset(-4, 0),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: constants.AppConstants.largePadding,
                      vertical: constants.AppConstants.defaultPadding,
                    ),
                    child: Text(
                      widget.title,
                      style: theme.textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const Divider(height: 1),
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(
                        horizontal: constants.AppConstants.largePadding,
                        vertical: constants.AppConstants.defaultPadding,
                      ),
                      itemCount: widget.sections.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
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
                  const Divider(height: 1),
                  Padding(
                    padding: const EdgeInsets.all(constants.AppConstants.largePadding),
                    child: Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              // 清空所有选择并立即返回空结果
                              final emptySelections = <String, Set<String>>{};
                              for (final key in selections.keys) {
                                emptySelections[key] = <String>{};
                              }
                              Navigator.of(context).pop(emptySelections);
                            },
                            child: Text(widget.clearText),
                          ),
                        ),
                        const SizedBox(width: constants.AppConstants.defaultPadding),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.of(context).pop(selections);
                            },
                            child: Text(widget.confirmText),
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
        Text(title, style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        Wrap(
          spacing: 12,
          runSpacing: 12,
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
    final selectedColor = theme.colorScheme.primary.withOpacity(0.12);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(constants.AppConstants.defaultBorderRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? selectedColor : theme.colorScheme.surfaceVariant.withOpacity(0.6),
          borderRadius: BorderRadius.circular(constants.AppConstants.defaultBorderRadius),
          border: Border.all(
            color: selected ? theme.colorScheme.primary : theme.dividerColor,
          ),
        ),
        child: Text(
          label,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: selected ? theme.colorScheme.primary : theme.colorScheme.onSurface,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
          ),
        ),
      ),
    );
  }
}
