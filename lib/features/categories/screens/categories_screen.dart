import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide colorFromHex, colorToHex;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../features/payments/providers/payments_provider.dart';
import '../../../shared/widgets/color_letter_avatar.dart';

const _kColors = [
  Color(0xFFE53935),
  Color(0xFFE91E63),
  Color(0xFF8E24AA),
  Color(0xFF3949AB),
  Color(0xFF1E88E5),
  Color(0xFF00ACC1),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF6D4C41),
  Color(0xFF757575),
];

const _kIcons = {
  'category': Icons.category,
  'play_circle': Icons.play_circle,
  'live_tv': Icons.live_tv,
  'music_note': Icons.music_note,
  'headphones': Icons.headphones,
  'podcasts': Icons.podcasts,
  'sports_esports': Icons.sports_esports,
  'computer': Icons.computer,
  'cloud': Icons.cloud,
  'code': Icons.code,
  'security': Icons.security,
  'vpn_lock': Icons.vpn_lock,
  'account_balance': Icons.account_balance,
  'savings': Icons.savings,
  'payments': Icons.payments,
  'trending_up': Icons.trending_up,
  'fitness_center': Icons.fitness_center,
  'medical_services': Icons.medical_services,
  'spa': Icons.spa,
  'self_improvement': Icons.self_improvement,
  'favorite': Icons.favorite,
  'mail': Icons.mail,
  'chat_bubble': Icons.chat_bubble,
  'video_call': Icons.video_call,
  'newspaper': Icons.newspaper,
  'book': Icons.book,
  'article': Icons.article,
  'shopping_bag': Icons.shopping_bag,
  'storefront': Icons.storefront,
  'restaurant': Icons.restaurant,
  'local_cafe': Icons.local_cafe,
  'delivery_dining': Icons.delivery_dining,
  'school': Icons.school,
  'translate': Icons.translate,
  'psychology': Icons.psychology,
  'home': Icons.home,
  'electrical_services': Icons.electrical_services,
  'directions_car': Icons.directions_car,
  'flight': Icons.flight,
  'hotel': Icons.hotel,
  'pets': Icons.pets,
  'child_care': Icons.child_care,
  'smart_toy': Icons.smart_toy,
  'palette': Icons.palette,
  'camera_alt': Icons.camera_alt,
  'work': Icons.work,
  'star': Icons.star,
};

class CategoriesScreen extends ConsumerWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catsAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showForm(context, ref, null),
        child: const Icon(Icons.add),
      ),
      body: catsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (cats) {
          if (cats.isEmpty) {
            return const Center(child: Text('No categories yet.'));
          }
          return ListView.builder(
            itemCount: cats.length,
            padding: const EdgeInsets.only(bottom: 96),
            itemBuilder: (context, i) {
              final cat = cats[i];
              final color = colorFromHex(cat.colorHex);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: color,
                  child: Icon(
                    // ignore: non_const_argument_for_const_parameter
                    IconData(cat.iconCodePoint, fontFamily: 'MaterialIcons'),
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                title: Text(cat.name),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit_outlined),
                      onPressed: () => _showForm(context, ref, cat),
                    ),
                    IconButton(
                      icon: Icon(Icons.delete_outline,
                          color: Theme.of(context).colorScheme.error),
                      onPressed: () => _confirmDelete(context, ref, cat),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showForm(
      BuildContext context, WidgetRef ref, Category? existing) async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => _CategoryFormDialog(
        existing: existing,
        onSave: (entry) async {
          final dao = ref.read(appDatabaseProvider).categoriesDao;
          if (existing == null) {
            await dao.insertOne(entry);
          } else {
            await dao.updateOne(entry);
          }
        },
      ),
    );
  }

  Future<void> _confirmDelete(
      BuildContext context, WidgetRef ref, Category cat) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Category'),
        content: Text(
            'Remove "${cat.name}"? It will be unlinked from all payments.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      await ref.read(appDatabaseProvider).categoriesDao.deleteById(cat.id);
    }
  }
}

// ─── Category form dialog ────────────────────────────────────────────────────

class _CategoryFormDialog extends StatefulWidget {
  final Category? existing;
  final Future<void> Function(CategoriesCompanion) onSave;

  const _CategoryFormDialog({required this.existing, required this.onSave});

  @override
  State<_CategoryFormDialog> createState() => _CategoryFormDialogState();
}

class _CategoryFormDialogState extends State<_CategoryFormDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _nameCtrl;
  late Color _selectedColor;
  late IconData _selectedIcon;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.existing?.name ?? '');
    _selectedColor = widget.existing != null
        ? colorFromHex(widget.existing!.colorHex)
        : _kColors.first;
    _selectedIcon = widget.existing != null
        // ignore: non_const_argument_for_const_parameter
        ? IconData(widget.existing!.iconCodePoint, fontFamily: 'MaterialIcons')
        : _kIcons.values.first;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickCustomColor(BuildContext context) async {
    Color temp = _selectedColor;
    final result = await showDialog<Color>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Custom Color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: temp,
            onColorChanged: (c) => temp = c,
            enableAlpha: false,
            labelTypes: const [],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, temp),
            child: const Text('Select'),
          ),
        ],
      ),
    );
    if (result != null) setState(() => _selectedColor = result);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.existing == null ? 'New Category' : 'Edit Category'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Preview
              Center(
                child: CircleAvatar(
                  radius: 28,
                  backgroundColor: _selectedColor,
                  child: Icon(_selectedIcon, color: Colors.white, size: 28),
                ),
              ),
              const SizedBox(height: 16),

              // Name
              TextFormField(
                controller: _nameCtrl,
                decoration: const InputDecoration(
                  labelText: 'Name *',
                  border: OutlineInputBorder(),
                ),
                textCapitalization: TextCapitalization.words,
                validator: (v) =>
                    v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              // Color picker
              Text('Color',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ..._kColors.map((c) {
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = c),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: c,
                          shape: BoxShape.circle,
                          border: _selectedColor == c
                              ? Border.all(
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                  width: 3)
                              : null,
                        ),
                      ),
                    );
                  }),
                  // Custom color button
                  GestureDetector(
                    onTap: () => _pickCustomColor(context),
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Theme.of(context).colorScheme.outline,
                            width: 1.5),
                        gradient: const SweepGradient(colors: [
                          Color(0xFFE53935),
                          Color(0xFFFB8C00),
                          Color(0xFF43A047),
                          Color(0xFF1E88E5),
                          Color(0xFF8E24AA),
                          Color(0xFFE53935),
                        ]),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Icon picker
              Text('Icon',
                  style: Theme.of(context).textTheme.labelMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      )),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _kIcons.entries.map((e) {
                  final selected = _selectedIcon == e.value;
                  return GestureDetector(
                    onTap: () => setState(() => _selectedIcon = e.value),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: selected
                            ? Theme.of(context).colorScheme.primaryContainer
                            : Theme.of(context)
                                .colorScheme
                                .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(e.value, size: 22),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () async {
            if (!_formKey.currentState!.validate()) return;
            final companion = CategoriesCompanion(
              id: widget.existing != null
                  ? Value(widget.existing!.id)
                  : const Value.absent(),
              name: Value(_nameCtrl.text.trim()),
              colorHex: Value(colorToHex(_selectedColor)),
              iconCodePoint: Value(_selectedIcon.codePoint),
            );
            await widget.onSave(companion);
            if (context.mounted) Navigator.pop(context);
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
