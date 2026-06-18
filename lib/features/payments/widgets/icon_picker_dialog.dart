import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart'
    hide colorFromHex, colorToHex;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:path_provider/path_provider.dart';

import '../../../shared/widgets/color_letter_avatar.dart';

bool _isSvg(String path) =>
    path.toLowerCase().split('?').first.trimRight().endsWith('.svg');

const Map<String, IconData> kSubscriptionIcons = {
  // Streaming & Entertainment
  'play_circle': Icons.play_circle,
  'live_tv': Icons.live_tv,
  'smart_display': Icons.smart_display,
  'movie': Icons.movie,
  'theaters': Icons.theaters,
  'tv': Icons.tv,
  'podcasts': Icons.podcasts,
  'radio': Icons.radio,
  // Music
  'music_note': Icons.music_note,
  'headphones': Icons.headphones,
  'queue_music': Icons.queue_music,
  'mic': Icons.mic,
  // Gaming
  'videogame_asset': Icons.videogame_asset,
  'sports_esports': Icons.sports_esports,
  'casino': Icons.casino,
  // Software & Cloud
  'computer': Icons.computer,
  'laptop': Icons.laptop,
  'phone_android': Icons.phone_android,
  'cloud': Icons.cloud,
  'storage': Icons.storage,
  'backup': Icons.backup,
  'code': Icons.code,
  'terminal': Icons.terminal,
  'developer_mode': Icons.developer_mode,
  // Design & Creativity
  'palette': Icons.palette,
  'brush': Icons.brush,
  'camera_alt': Icons.camera_alt,
  // Productivity & Office
  'work': Icons.work,
  'description': Icons.description,
  'table_chart': Icons.table_chart,
  'task_alt': Icons.task_alt,
  'calendar_month': Icons.calendar_month,
  // Security
  'security': Icons.security,
  'vpn_key': Icons.vpn_key,
  'vpn_lock': Icons.vpn_lock,
  'lock': Icons.lock,
  // Finance
  'account_balance': Icons.account_balance,
  'savings': Icons.savings,
  'payments': Icons.payments,
  'receipt_long': Icons.receipt_long,
  'trending_up': Icons.trending_up,
  'currency_bitcoin': Icons.currency_bitcoin,
  // Health & Fitness
  'fitness_center': Icons.fitness_center,
  'health_and_safety': Icons.health_and_safety,
  'medical_services': Icons.medical_services,
  'spa': Icons.spa,
  'self_improvement': Icons.self_improvement,
  'directions_run': Icons.directions_run,
  // Communication
  'mail': Icons.mail,
  'chat_bubble': Icons.chat_bubble,
  'forum': Icons.forum,
  'video_call': Icons.video_call,
  // News & Reading
  'book': Icons.book,
  'menu_book': Icons.menu_book,
  'newspaper': Icons.newspaper,
  'article': Icons.article,
  'rss_feed': Icons.rss_feed,
  // Shopping
  'shopping_bag': Icons.shopping_bag,
  'storefront': Icons.storefront,
  'local_mall': Icons.local_mall,
  'restaurant': Icons.restaurant,
  'fastfood': Icons.fastfood,
  'local_cafe': Icons.local_cafe,
  'delivery_dining': Icons.delivery_dining,
  // Education
  'school': Icons.school,
  'cast_for_education': Icons.cast_for_education,
  'translate': Icons.translate,
  'psychology': Icons.psychology,
  // Travel & Transport
  'flight': Icons.flight,
  'directions_car': Icons.directions_car,
  'hotel': Icons.hotel,
  'commute': Icons.commute,
  // Home & Lifestyle
  'home': Icons.home,
  'pets': Icons.pets,
  'child_care': Icons.child_care,
  'smart_toy': Icons.smart_toy,
  // Other
  'language': Icons.language,
  'star': Icons.star,
  'category': Icons.category,
};

const List<Color> kAvatarColors = [
  Color(0xFFE53935),
  Color(0xFFE91E63),
  Color(0xFF8E24AA),
  Color(0xFF1E88E5),
  Color(0xFF43A047),
  Color(0xFFFB8C00),
  Color(0xFF00ACC1),
  Color(0xFF757575),
];

class IconPickerResult {
  final String iconType; // 'bundled', 'avatar', 'url', or 'file'
  final String iconIdentifier;
  final String colorHex;

  const IconPickerResult({
    required this.iconType,
    required this.iconIdentifier,
    required this.colorHex,
  });
}

Future<IconPickerResult?> showIconPicker(
  BuildContext context, {
  required String paymentName,
  required IconPickerResult current,
}) {
  return showDialog<IconPickerResult>(
    context: context,
    builder: (ctx) => _IconPickerDialog(
      paymentName: paymentName,
      current: current,
    ),
  );
}

class _IconPickerDialog extends StatefulWidget {
  final String paymentName;
  final IconPickerResult current;

  const _IconPickerDialog({
    required this.paymentName,
    required this.current,
  });

  @override
  State<_IconPickerDialog> createState() => _IconPickerDialogState();
}

class _IconPickerDialogState extends State<_IconPickerDialog>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  late String _selectedKey;
  late Color _selectedColor;
  late TextEditingController _urlCtrl;
  String? _localFilePath;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _selectedColor = colorFromHex(
      widget.current.colorHex.isNotEmpty ? widget.current.colorHex : '#6750A4',
    );

    switch (widget.current.iconType) {
      case 'bundled':
        _tabController.index = 0;
        _selectedKey = widget.current.iconIdentifier;
        _urlCtrl = TextEditingController();
      case 'url':
        _tabController.index = 2;
        _selectedKey = '';
        _urlCtrl = TextEditingController(text: widget.current.iconIdentifier);
      case 'file':
        _tabController.index = 3;
        _selectedKey = '';
        _urlCtrl = TextEditingController();
        _localFilePath = widget.current.iconIdentifier;
      default: // 'avatar'
        _tabController.index = 1;
        _selectedKey = '';
        _urlCtrl = TextEditingController();
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _urlCtrl.dispose();
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
    final letter = widget.paymentName.isEmpty
        ? '?'
        : widget.paymentName[0].toUpperCase();

    return AlertDialog(
      title: const Text('Choose Icon'),
      content: SizedBox(
        width: 340,
        height: 380,
        child: Column(
          children: [
            TabBar(
              controller: _tabController,
              isScrollable: true,
              tabAlignment: TabAlignment.start,
              tabs: const [
                Tab(text: 'Icons'),
                Tab(text: 'Avatar'),
                Tab(text: 'URL'),
                Tab(text: 'Device'),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // ── Tab 0: Bundled icon grid ──────────────────────────────
                  GridView.builder(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 6,
                      mainAxisSpacing: 6,
                      crossAxisSpacing: 6,
                    ),
                    itemCount: kSubscriptionIcons.length,
                    itemBuilder: (_, i) {
                      final key = kSubscriptionIcons.keys.elementAt(i);
                      final icon = kSubscriptionIcons.values.elementAt(i);
                      final selected = _selectedKey == key;
                      return GestureDetector(
                        onTap: () => setState(() => _selectedKey = key),
                        child: Container(
                          decoration: BoxDecoration(
                            color: selected
                                ? Theme.of(context)
                                    .colorScheme
                                    .primaryContainer
                                : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, size: 24),
                        ),
                      );
                    },
                  ),

                  // ── Tab 1: Color letter avatar ────────────────────────────
                  Column(
                    children: [
                      ColorLetterAvatar(
                        letter: letter,
                        color: _selectedColor,
                        size: 64,
                      ),
                      const SizedBox(height: 16),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ...kAvatarColors.map((c) {
                            final isSelected = _selectedColor == c;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedColor = c),
                              child: Container(
                                width: 36,
                                height: 36,
                                decoration: BoxDecoration(
                                  color: c,
                                  shape: BoxShape.circle,
                                  border: isSelected
                                      ? Border.all(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                          width: 3,
                                        )
                                      : null,
                                ),
                              ),
                            );
                          }),
                          // Custom color
                          GestureDetector(
                            onTap: () => _pickCustomColor(context),
                            child: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .outline,
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
                    ],
                  ),

                  // ── Tab 2: Image URL ──────────────────────────────────────
                  _UrlTab(controller: _urlCtrl),

                  // ── Tab 3: Device image ───────────────────────────────────
                  _DeviceTab(
                    currentPath: _localFilePath,
                    onPicked: (path) => setState(() => _localFilePath = path),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            final tab = _tabController.index;
            if (tab == 3 && _localFilePath == null) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Pick an image first')),
              );
              return;
            }
            Navigator.pop(
              context,
              IconPickerResult(
                iconType: switch (tab) {
                  0 => 'bundled',
                  2 => 'url',
                  3 => 'file',
                  _ => 'avatar',
                },
                iconIdentifier: switch (tab) {
                  0 => _selectedKey,
                  2 => _urlCtrl.text.trim(),
                  3 => _localFilePath ?? '',
                  _ => '',
                },
                colorHex: colorToHex(_selectedColor),
              ),
            );
          },
          child: const Text('Select'),
        ),
      ],
    );
  }
}

// ─── URL tab ──────────────────────────────────────────────────────────────────

class _UrlTab extends StatefulWidget {
  final TextEditingController controller;

  const _UrlTab({required this.controller});

  @override
  State<_UrlTab> createState() => _UrlTabState();
}

class _UrlTabState extends State<_UrlTab> {
  String _previewUrl = '';

  @override
  void initState() {
    super.initState();
    _previewUrl = widget.controller.text;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          width: 72,
          height: 72,
          child: _previewUrl.isEmpty
              ? CircleAvatar(
                  radius: 36,
                  backgroundColor:
                      Theme.of(context).colorScheme.surfaceContainerHighest,
                  child: const Icon(Icons.image_outlined, size: 32),
                )
              : ClipOval(
                  child: _isSvg(_previewUrl)
                      ? SvgPicture.network(
                          _previewUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          placeholderBuilder: (_) => const SizedBox(
                            width: 72,
                            height: 72,
                            child: Center(
                                child: CircularProgressIndicator(
                                    strokeWidth: 2)),
                          ),
                        )
                      : Image.network(
                          _previewUrl,
                          width: 72,
                          height: 72,
                          fit: BoxFit.cover,
                          errorBuilder: (_, e, s) => CircleAvatar(
                            radius: 36,
                            backgroundColor:
                                Theme.of(context).colorScheme.errorContainer,
                            child: Icon(Icons.broken_image_outlined,
                                color: Theme.of(context).colorScheme.error),
                          ),
                        ),
                ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: widget.controller,
          decoration: const InputDecoration(
            labelText: 'Image URL',
            hintText: 'https://example.com/icon.png',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.link),
          ),
          keyboardType: TextInputType.url,
          onChanged: (v) => setState(() => _previewUrl = v.trim()),
        ),
        const SizedBox(height: 8),
        Text(
          'Paste a direct link to a PNG or JPG image',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

// ─── Device tab ───────────────────────────────────────────────────────────────

class _DeviceTab extends StatefulWidget {
  final String? currentPath;
  final ValueChanged<String> onPicked;

  const _DeviceTab({this.currentPath, required this.onPicked});

  @override
  State<_DeviceTab> createState() => _DeviceTabState();
}

class _DeviceTabState extends State<_DeviceTab> {
  bool _picking = false;

  Future<void> _pick() async {
    setState(() => _picking = true);
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['jpg', 'jpeg', 'png', 'webp', 'gif', 'svg'],
        allowMultiple: false,
      );
      if (result == null || result.files.isEmpty) return;
      final srcPath = result.files.first.path;
      if (srcPath == null) return;

      final appDir = await getApplicationDocumentsDirectory();
      final iconsDir = Directory('${appDir.path}/sub_icons');
      await iconsDir.create(recursive: true);
      final ext = result.files.first.extension ?? 'jpg';
      final destPath =
          '${iconsDir.path}/${DateTime.now().millisecondsSinceEpoch}.$ext';
      await File(srcPath).copy(destPath);
      widget.onPicked(destPath);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final path = widget.currentPath;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Preview
        if (path != null && File(path).existsSync())
          ClipOval(
            child: _isSvg(path)
                ? SvgPicture.file(
                    File(path),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  )
                : Image.file(
                    File(path),
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
          )
        else
          CircleAvatar(
            radius: 36,
            backgroundColor:
                Theme.of(context).colorScheme.surfaceContainerHighest,
            child: const Icon(Icons.photo_outlined, size: 36),
          ),
        const SizedBox(height: 16),
        FilledButton.icon(
          onPressed: _picking ? null : _pick,
          icon: _picking
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.photo_library_outlined),
          label: Text(_picking ? 'Opening…' : 'Choose from device'),
        ),
        const SizedBox(height: 8),
        Text(
          'Image is copied to app storage',
          style: Theme.of(context)
              .textTheme
              .bodySmall
              ?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      ],
    );
  }
}

// ─── buildPaymentIcon ─────────────────────────────────────────────────────────

Widget buildPaymentIcon(
  String iconType,
  String iconIdentifier,
  String? iconColorHex,
  String paymentName, {
  double size = 40,
}) {
  final fallbackColor = iconColorHex != null
      ? colorFromHex(iconColorHex)
      : const Color(0xFF6750A4);

  if (iconType == 'url' && iconIdentifier.isNotEmpty) {
    return ClipOval(
      child: _isSvg(iconIdentifier)
          ? SvgPicture.network(
              iconIdentifier,
              width: size,
              height: size,
              fit: BoxFit.cover,
              placeholderBuilder: (_) => ColorLetterAvatar(
                letter: paymentName.isEmpty ? '?' : paymentName[0],
                color: fallbackColor,
                size: size,
              ),
            )
          : Image.network(
              iconIdentifier,
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, e, s) => ColorLetterAvatar(
                letter: paymentName.isEmpty ? '?' : paymentName[0],
                color: fallbackColor,
                size: size,
              ),
            ),
    );
  }

  if (iconType == 'file' && iconIdentifier.isNotEmpty) {
    final file = File(iconIdentifier);
    if (file.existsSync()) {
      return ClipOval(
        child: _isSvg(iconIdentifier)
            ? SvgPicture.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
              )
            : Image.file(
                file,
                width: size,
                height: size,
                fit: BoxFit.cover,
                errorBuilder: (_, e, s) => ColorLetterAvatar(
                  letter:
                      paymentName.isEmpty ? '?' : paymentName[0],
                  color: fallbackColor,
                  size: size,
                ),
              ),
      );
    }
  }

  if (iconType == 'bundled' && kSubscriptionIcons.containsKey(iconIdentifier)) {
    return CircleAvatar(
      radius: size / 2,
      backgroundColor: fallbackColor.withValues(alpha: 0.15),
      child: Icon(kSubscriptionIcons[iconIdentifier], size: size * 0.55),
    );
  }

  return ColorLetterAvatar(
    letter: paymentName.isEmpty ? '?' : paymentName[0],
    color: fallbackColor,
    size: size,
  );
}
