import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:uuid/uuid.dart';
import '../../../providers/providers.dart';
import '../../../models/category_model.dart';
import '../../../core/theme/app_colors.dart';

class CategoriesScreen extends ConsumerStatefulWidget {
  const CategoriesScreen({super.key});

  @override
  ConsumerState<CategoriesScreen> createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends ConsumerState<CategoriesScreen> {
  bool _showCreateForm = false;
  final _nameController = TextEditingController();
  int _selectedColorIndex = 0;
  double _customHue = 180.0;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _addCategory() async {
    if (_nameController.text.trim().isEmpty) return;

    final Color categoryColor;
    if (_selectedColorIndex < AppColors.categoryColors.length) {
      categoryColor = AppColors.categoryColors[_selectedColorIndex];
    } else {
      categoryColor = HSVColor.fromAHSV(1.0, _customHue, 1.0, 1.0).toColor();
    }

    final newCategory = CategoryModel(
      id: const Uuid().v4(),
      name: _nameController.text.trim(),
      color: categoryColor,
    );

    await ref.read(categoriesProvider.notifier).addCategory(newCategory);

    setState(() {
      _nameController.clear();
      _showCreateForm = false;
    });
  }

  void _deleteCategory(String id) async {
    await ref.read(categoriesProvider.notifier).deleteCategory(id);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categories = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(LucideIcons.arrowLeft),
        ),
        title: const Text('Categorías'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                final category = categories[index];
                return Dismissible(
                  key: Key(category.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      LucideIcons.trash2,
                      color: AppColors.error,
                      size: 20,
                    ),
                  ),
                  onDismissed: (_) => _deleteCategory(category.id),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.surface,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.5),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 20,
                          height: 20,
                          decoration: BoxDecoration(
                            color: category.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            category.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: () {
                            // TODO: Edit category
                          },
                          icon: Icon(
                            LucideIcons.pencil,
                            size: 16,
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.4,
                            ),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          onPressed: () => _deleteCategory(category.id),
                          icon: Icon(
                            LucideIcons.trash2,
                            size: 16,
                            color: AppColors.error.withValues(alpha: 0.8),
                          ),
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          // ─── Create form ───
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOutCubic,
            child: _showCreateForm
                ? _buildCreateForm()
                : const SizedBox.shrink(),
          ),

          // ─── Create button ───
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton.icon(
                onPressed: () {
                  setState(() => _showCreateForm = !_showCreateForm);
                },
                icon: Icon(
                  _showCreateForm ? LucideIcons.x : LucideIcons.plus,
                  size: 18,
                ),
                label: Text(_showCreateForm ? 'Cancelar' : 'Nueva Categoría'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _showCreateForm
                      ? theme.colorScheme.surface
                      : theme.colorScheme.primary,
                  foregroundColor: _showCreateForm
                      ? theme.colorScheme.onSurface
                      : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: _showCreateForm
                        ? BorderSide(color: theme.colorScheme.outline)
                        : BorderSide.none,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCreateForm() {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.5),
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Nueva categoría',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          // ─── Name ───
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              hintText: 'Nombre de la categoría',
            ),
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),
          // ─── Color selector ───
          Text(
            'Color',
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: List.generate(AppColors.categoryColors.length + 1, (i) {
              final isCustom = i == AppColors.categoryColors.length;
              final isSelected = i == _selectedColorIndex;
              final Color displayColor = isCustom
                  ? HSVColor.fromAHSV(1.0, _customHue, 1.0, 1.0).toColor()
                  : AppColors.categoryColors[i];

              return GestureDetector(
                onTap: () => setState(() => _selectedColorIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: displayColor,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? theme.colorScheme.onSurface
                          : Colors.transparent,
                      width: 2.5,
                    ),
                    gradient: isCustom && !isSelected
                        ? const SweepGradient(
                            colors: [
                              Colors.red,
                              Colors.yellow,
                              Colors.green,
                              Colors.cyan,
                              Colors.blue,
                              Colors.purple,
                              Colors.red,
                            ],
                          )
                        : null,
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: displayColor.withValues(alpha: 0.4),
                              blurRadius: 8,
                            ),
                          ]
                        : null,
                  ),
                  child: isSelected
                      ? const Icon(
                          LucideIcons.check,
                          color: Colors.white,
                          size: 18,
                        )
                      : (isCustom
                            ? const Icon(
                                LucideIcons.pipette,
                                color: Colors.white,
                                size: 16,
                              )
                            : null),
                ),
              );
            }),
          ),
          if (_selectedColorIndex == AppColors.categoryColors.length) ...[
            const SizedBox(height: 16),
            Text(
              'Ajustar tono brillante',
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
              ),
            ),
            SliderTheme(
              data: SliderTheme.of(context).copyWith(
                activeTrackColor: theme.colorScheme.primary,
                inactiveTrackColor: theme.colorScheme.primary.withValues(
                  alpha: 0.2,
                ),
                thumbColor: HSVColor.fromAHSV(
                  1.0,
                  _customHue,
                  1.0,
                  1.0,
                ).toColor(),
                overlayColor: theme.colorScheme.primary.withValues(alpha: 0.1),
                trackHeight: 4,
              ),
              child: Slider(
                value: _customHue,
                min: 0.0,
                max: 360.0,
                onChanged: (val) {
                  setState(() => _customHue = val);
                },
              ),
            ),
          ],
          const SizedBox(height: 16),
          // ─── Save button ───
          SizedBox(
            width: double.infinity,
            height: 44,
            child: ElevatedButton(
              onPressed: _addCategory,
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.primary,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text('Guardar'),
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
