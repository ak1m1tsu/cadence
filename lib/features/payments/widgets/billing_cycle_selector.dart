import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/models/billing_cycle.dart';

class BillingCycleSelector extends StatelessWidget {
  final BillingCycle cycle;
  final TextEditingController intervalController;
  final ValueChanged<BillingCycle> onCycleChanged;

  const BillingCycleSelector({
    super.key,
    required this.cycle,
    required this.intervalController,
    required this.onCycleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 88,
          child: TextFormField(
            controller: intervalController,
            decoration: const InputDecoration(
              labelText: 'Every',
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
          child: DropdownButtonFormField<BillingCycle>(
            // ignore: deprecated_member_use
            value: cycle,
            decoration: const InputDecoration(
              labelText: 'Period',
              border: OutlineInputBorder(),
            ),
            items: BillingCycle.values
                .map((c) => DropdownMenuItem(value: c, child: Text(c.label)))
                .toList(),
            onChanged: (v) {
              if (v != null) onCycleChanged(v);
            },
          ),
        ),
      ],
    );
  }
}
