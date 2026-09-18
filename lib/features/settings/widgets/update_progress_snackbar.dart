import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/update_provider.dart';

/// SnackBar content that reactively shows the current download progress.
class UpdateProgressSnackbarContent extends ConsumerWidget {
  const UpdateProgressSnackbarContent({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final progress = ref.watch(
      updateStatusProvider.select((s) => s.downloadProgress),
    );

    return Row(
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            value: progress > 0 ? progress : null,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text('Downloading update… ${(progress * 100).round()}%'),
        ),
      ],
    );
  }
}
