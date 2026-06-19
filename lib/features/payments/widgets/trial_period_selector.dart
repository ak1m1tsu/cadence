import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/trial_unit.dart';

class TrialPeriodSelector extends StatelessWidget {
  final bool enabled;
  final TextEditingController intervalController;
  final TrialUnit unit;
  final ValueChanged<bool> onEnabledChanged;
  final ValueChanged<TrialUnit> onUnitChanged;

  const TrialPeriodSelector({
    super.key,
    required this.enabled,
    required this.intervalController,
    required this.unit,
    required this.onEnabledChanged,
    required this.onUnitChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('Trial period'),
          value: enabled,
          onChanged: onEnabledChanged,
        ),
        if (enabled) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: TextFormField(
                  controller: intervalController,
                  decoration: const InputDecoration(
                    labelText: 'For',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  validator: (v) {
                    final n = int.tryParse(v ?? '');
                    if (n == null || n < 1) return '≥ 1';
                    return null;
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<TrialUnit>(
                  // ignore: deprecated_member_use
                  value: unit,
                  decoration: const InputDecoration(
                    labelText: 'Unit',
                    border: OutlineInputBorder(),
                  ),
                  items: TrialUnit.values
                      .map((u) => DropdownMenuItem(value: u, child: Text(u.label)))
                      .toList(),
                  onChanged: (v) {
                    if (v != null) onUnitChanged(v);
                  },
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}
