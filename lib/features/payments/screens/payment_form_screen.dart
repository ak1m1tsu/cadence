import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:uuid/uuid.dart';

import '../../../core/database/app_database.dart';
import '../../../core/database/database_provider.dart';
import '../../../core/models/billing_cycle.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/renewal_calculator.dart';
import '../../../shared/widgets/color_letter_avatar.dart';
import '../../settings/providers/settings_provider.dart';
import '../../settings/widgets/currency_picker.dart';
import '../providers/payments_provider.dart';
import '../widgets/billing_cycle_selector.dart';
import '../widgets/icon_picker_dialog.dart';

// null = no reminder
const _kReminderOptions = <int?, String>{
  null: 'No reminder',
  0: 'Day of renewal',
  1: '1 day before',
  3: '3 days before',
  7: '1 week before',
  14: '2 weeks before',
  30: '1 month before',
};

class PaymentFormScreen extends ConsumerStatefulWidget {
  final Payment? payment;

  const PaymentFormScreen({super.key, this.payment});

  @override
  ConsumerState<PaymentFormScreen> createState() =>
      _PaymentFormScreenState();
}

class _PaymentFormScreenState
    extends ConsumerState<PaymentFormScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameCtrl;
  late final TextEditingController _priceCtrl;
  late final TextEditingController _notesCtrl;
  late final TextEditingController _intervalCtrl;

  late BillingCycle _billingCycle;
  late DateTime _startDate;
  late String _currencyCode;
  late Set<int> _selectedCategoryIds;
  late String _iconType;
  late String _iconIdentifier;
  late String _iconColorHex;
  late int? _reminderLeadDays;
  late TimeOfDay _reminderTime;
  bool _isSubmitting = false;
  bool _currencyInitialized = false;

  Future<void> _onReminderChanged(int? v) async {
    if (v == null) {
      setState(() => _reminderLeadDays = null);
      return;
    }
    final hasPerms = await NotificationService.hasPermission();
    if (!mounted) return;
    if (!hasPerms) {
      final granted = await NotificationService.requestPermissions();
      if (!mounted) return;
      if (!granted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Notification permission denied — reminders unavailable'),
          ),
        );
        return;
      }
    }
    setState(() => _reminderLeadDays = v);
  }

  @override
  void initState() {
    super.initState();
    final p = widget.payment;
    _nameCtrl = TextEditingController(text: p?.name ?? '');
    _priceCtrl =
        TextEditingController(text: p != null ? p.price.toString() : '');
    _notesCtrl = TextEditingController(text: p?.notes ?? '');
    _intervalCtrl =
        TextEditingController(text: (p?.periodInterval ?? 1).toString());
    _billingCycle =
        p != null ? BillingCycle.fromDb(p.billingCycle) : BillingCycle.monthly;
    _startDate = p != null
        ? DateTime.fromMillisecondsSinceEpoch(p.startDate)
        : DateTime.now();
    _currencyCode = p?.currencyCode ?? '';
    _selectedCategoryIds = {};
    _iconType = p?.iconType ?? 'avatar';
    _iconIdentifier = p?.iconIdentifier ?? '';
    _iconColorHex = p?.iconColorHex ?? '#6750A4';
    _reminderLeadDays = p?.reminderLeadDays;
    _reminderTime = TimeOfDay(
      hour: p?.reminderHour ?? 9,
      minute: p?.reminderMinute ?? 0,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_currencyInitialized) {
      if (widget.payment == null) {
        _currencyCode = ref.read(settingsProvider).baseCurrency;
      }
      _currencyInitialized = true;

      // Load existing categories for edit mode
      if (widget.payment != null) {
        ref
            .read(appDatabaseProvider)
            .paymentCategoriesDao
            .getForPayment(widget.payment!.id)
            .then((cats) {
          if (mounted) {
            setState(() {
              _selectedCategoryIds = cats.map((c) => c.id).toSet();
            });
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _priceCtrl.dispose();
    _notesCtrl.dispose();
    _intervalCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = ref.watch(categoriesProvider).valueOrNull ?? [];
    final isEditing = widget.payment != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Payment' : 'Add Payment'),
        actions: [
          TextButton(
            onPressed: _isSubmitting ? null : _submit,
            child: const Text('Save'),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Icon
            Center(
              child: GestureDetector(
                onTap: _pickIcon,
                child: Stack(
                  children: [
                    buildPaymentIcon(
                      _iconType,
                      _iconIdentifier,
                      _iconColorHex,
                      _nameCtrl.text,
                      size: 72,
                    ),
                    Positioned(
                      right: 0,
                      bottom: 0,
                      child: CircleAvatar(
                        radius: 12,
                        backgroundColor:
                            Theme.of(context).colorScheme.primary,
                        child: const Icon(Icons.edit,
                            size: 14, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Name
            TextFormField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Service name *',
                border: OutlineInputBorder(),
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (_) => setState(() {}),
              validator: (v) =>
                  v == null || v.trim().isEmpty ? 'Required' : null,
            ),
            const SizedBox(height: 16),

            // Price + Currency
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _priceCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Price *',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
                    ],
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Required';
                      if (double.tryParse(v) == null) return 'Invalid number';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                OutlinedButton(
                  onPressed: _pickCurrency,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 18),
                  ),
                  child: Text(_currencyCode),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Billing cycle
            BillingCycleSelector(
              cycle: _billingCycle,
              intervalController: _intervalCtrl,
              onCycleChanged: (c) => setState(() => _billingCycle = c),
            ),
            const SizedBox(height: 16),

            // Start date
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Start date'),
              subtitle: Text(DateFormat('MMM d, y').format(_startDate)),
              trailing: const Icon(Icons.calendar_today),
              onTap: _pickDate,
            ),
            const Divider(),
            const SizedBox(height: 8),

            // Categories (multi-select chips)
            if (categories.isNotEmpty) ...[
              Text(
                'Categories',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: categories.map((cat) {
                  final selected = _selectedCategoryIds.contains(cat.id);
                  final color = colorFromHex(cat.colorHex);
                  return FilterChip(
                    label: Text(cat.name),
                    selected: selected,
                    avatar: selected
                        ? null
                        : CircleAvatar(
                            radius: 8,
                            backgroundColor: color,
                          ),
                    selectedColor: color.withValues(alpha: 0.25),
                    checkmarkColor: color,
                    onSelected: (v) => setState(() {
                      if (v) {
                        _selectedCategoryIds.add(cat.id);
                      } else {
                        _selectedCategoryIds.remove(cat.id);
                      }
                    }),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
            ],

            // Notes
            TextFormField(
              controller: _notesCtrl,
              decoration: const InputDecoration(
                labelText: 'Notes (optional)',
                border: OutlineInputBorder(),
              ),
              maxLines: 2,
            ),
            const SizedBox(height: 16),

            // Reminder — per payment
            DropdownButtonFormField<int?>(
              // ignore: deprecated_member_use
              value: _reminderLeadDays,
              decoration: InputDecoration(
                labelText: 'Renewal reminder',
                border: const OutlineInputBorder(),
                prefixIcon: const Icon(Icons.notifications_outlined),
                helperText: NotificationService.isSupported
                    ? null
                    : 'Not available on this platform',
              ),
              items: _kReminderOptions.entries
                  .map((e) =>
                      DropdownMenuItem(value: e.key, child: Text(e.value)))
                  .toList(),
              onChanged: NotificationService.isSupported
                  ? (v) => _onReminderChanged(v)
                  : null,
            ),

            // Reminder time (only when reminder is active)
            if (_reminderLeadDays != null) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                leading: const Icon(Icons.access_time),
                title: const Text('Reminder time'),
                subtitle: Text(_reminderTime.format(context)),
                trailing: const Icon(Icons.chevron_right),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                tileColor: Theme.of(context)
                    .colorScheme
                    .surfaceContainerHighest
                    .withValues(alpha: 0.5),
                onTap: _pickTime,
              ),
            ],

            const SizedBox(height: 32),
            FilledButton(
              onPressed: _isSubmitting ? null : _submit,
              child: _isSubmitting
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(isEditing ? 'Save Changes' : 'Add Payment'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickIcon() async {
    final result = await showIconPicker(
      context,
      paymentName: _nameCtrl.text,
      current: IconPickerResult(
        iconType: _iconType,
        iconIdentifier: _iconIdentifier,
        colorHex: _iconColorHex,
      ),
    );
    if (result != null) {
      setState(() {
        _iconType = result.iconType;
        _iconIdentifier = result.iconIdentifier;
        _iconColorHex = result.colorHex;
      });
    }
  }

  Future<void> _pickCurrency() async {
    final result = await showCurrencyPicker(context, current: _currencyCode);
    if (result != null) setState(() => _currencyCode = result);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _reminderTime,
    );
    if (picked != null) setState(() => _reminderTime = picked);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) setState(() => _startDate = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSubmitting = true);

    try {
      final id = widget.payment?.id ?? const Uuid().v4();
      final now = DateTime.now().millisecondsSinceEpoch;
      final interval = int.parse(_intervalCtrl.text);

      final entry = PaymentsCompanion(
        id: Value(id),
        name: Value(_nameCtrl.text.trim()),
        price: Value(double.parse(_priceCtrl.text)),
        currencyCode: Value(_currencyCode),
        billingCycle: Value(_billingCycle.name),
        periodInterval: Value(interval),
        startDate: Value(_startDate.millisecondsSinceEpoch),
        iconType: Value(_iconType),
        iconIdentifier: Value(_iconIdentifier),
        iconColorHex: Value(_iconColorHex),
        notes: Value(
            _notesCtrl.text.trim().isEmpty ? null : _notesCtrl.text.trim()),
        isActive: const Value(1),
        reminderLeadDays: Value(_reminderLeadDays),
        reminderHour: Value(_reminderLeadDays != null ? _reminderTime.hour : null),
        reminderMinute:
            Value(_reminderLeadDays != null ? _reminderTime.minute : null),
        createdAt: Value(widget.payment?.createdAt ?? now),
        updatedAt: Value(now),
      );

      final db = ref.read(appDatabaseProvider);
      if (widget.payment == null) {
        await db.paymentsDao.insertOne(entry);
      } else {
        await db.paymentsDao.updateOne(entry);
      }

      // Save category assignments
      await db.paymentCategoriesDao
          .setCategories(id, _selectedCategoryIds.toList());

      // Notifications are best-effort — never block navigation on failure
      try {
        await NotificationService.cancelReminder(id);
        if (_reminderLeadDays != null) {
          final renewal = nextRenewalDate(
            _startDate,
            _billingCycle,
            periodInterval: interval,
          );
          await NotificationService.scheduleRenewalReminder(
            paymentId: id,
            name: _nameCtrl.text.trim(),
            renewalDate: renewal,
            leadDays: _reminderLeadDays!,
            price: double.parse(_priceCtrl.text),
            currencyCode: _currencyCode,
            reminderHour: _reminderTime.hour,
            reminderMinute: _reminderTime.minute,
          );
        }
      } catch (_) {
        // Non-fatal
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Save failed: $e')),
        );
        setState(() => _isSubmitting = false);
      }
      return;
    }

    if (mounted) Navigator.pop(context);
  }
}
