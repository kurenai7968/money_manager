import 'package:flutter/foundation.dart';
import 'package:material_ui/material_ui.dart';
import 'package:money_manager/core/extensions/context_extension.dart';
import 'package:money_manager/models/account_book_kinds.dart';
import 'package:money_manager/models/category_model.dart';
import 'package:money_manager/themes/app_themes.dart';
import 'package:money_manager/themes/account_book_palette.dart';

class RecordCategoryGrid extends StatelessWidget {
  final List<CategoryModel> categories;
  final int? selectedId;
  final ValueChanged<int> onSelected;
  @visibleForTesting
  static int debugBuildCount = 0;

  const RecordCategoryGrid({
    required this.categories,
    required this.selectedId,
    required this.onSelected,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    debugBuildCount++;
    return LayoutBuilder(
      builder: (context, constraints) {
        const columns = 4;
        const gap = AppSpacing.s;
        const maxCellWidth = 72.0;
        const cellHeight = 112.0;
        final horizontalPadding = AppSpacing.l * 2;
        final available = constraints.maxWidth - horizontalPadding;
        final stretched = available <= gap * (columns - 1)
            ? 0.0
            : (available - gap * (columns - 1)) / columns;
        final cellWidth = stretched < maxCellWidth ? stretched : maxCellWidth;
        final contentWidth = cellWidth * columns + gap * (columns - 1);
        final gridWidth = contentWidth + horizontalPadding;
        final width = gridWidth < constraints.maxWidth
            ? gridWidth
            : constraints.maxWidth;
        return Align(
          alignment: AlignmentDirectional.topCenter,
          child: SizedBox(
            width: width,
            height: constraints.maxHeight,
            child: GridView.builder(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.l,
                AppSpacing.m,
                AppSpacing.l,
                AppSpacing.m,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: columns,
                mainAxisSpacing: gap,
                crossAxisSpacing: gap,
                mainAxisExtent: cellHeight,
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                final selected = category.id == selectedId;
                final label = category.labelFor(context.categoryLanguageCode);
                final color = AccountBookPalette.directionColor(
                  income: category.type == CategoryKind.income,
                );
                final scheme = Theme.of(context).colorScheme;
                return Semantics(
                  button: true,
                  selected: selected,
                  label: label,
                  excludeSemantics: true,
                  child: Material(
                    color: selected
                        ? color.withValues(alpha: 0.14)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.m),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(AppRadius.m),
                      onTap: () {
                        final id = category.id;
                        if (id != null) {
                          onSelected(id);
                        }
                        Scrollable.ensureVisible(context);
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 52,
                            height: 52,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: selected
                                          ? color
                                          : Colors.transparent,
                                      width: 2,
                                    ),
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: color,
                                    child: Icon(
                                      AccountBookPalette.icon(category.icon),
                                      color: scheme.onPrimary,
                                      size: 20,
                                    ),
                                  ),
                                ),
                                if (selected)
                                  Positioned(
                                    right: 0,
                                    bottom: 2,
                                    child: DecoratedBox(
                                      decoration: BoxDecoration(
                                        color: scheme.surface,
                                        shape: BoxShape.circle,
                                      ),
                                      child: Icon(
                                        Icons.check_circle,
                                        size: 16,
                                        color: color,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Flexible(
                            child: Text(
                              label,
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context).textTheme.labelMedium
                                  ?.copyWith(
                                    color: selected ? color : scheme.onSurface,
                                    fontWeight: selected
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}
