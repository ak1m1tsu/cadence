import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../app.dart';
import '../../../core/models/app_release.dart';
import '../../../core/services/update_service.dart';
import '../widgets/update_available_dialog.dart';
import '../widgets/update_progress_snackbar.dart';
import 'settings_provider.dart';

class UpdateStatus {
  final AppRelease? release;
  final bool isUpdateAvailable;
  final bool isDownloading;
  final double downloadProgress;

  const UpdateStatus({
    this.release,
    this.isUpdateAvailable = false,
    this.isDownloading = false,
    this.downloadProgress = 0,
  });

  UpdateStatus copyWith({
    AppRelease? release,
    bool? isUpdateAvailable,
    bool? isDownloading,
    double? downloadProgress,
  }) =>
      UpdateStatus(
        release: release ?? this.release,
        isUpdateAvailable: isUpdateAvailable ?? this.isUpdateAvailable,
        isDownloading: isDownloading ?? this.isDownloading,
        downloadProgress: downloadProgress ?? this.downloadProgress,
      );
}

class UpdateNotifier extends StateNotifier<UpdateStatus> {
  UpdateNotifier(this._service, this._ref) : super(const UpdateStatus());

  final UpdateService _service;
  final Ref _ref;

  /// Fetches the latest release and updates [state.isUpdateAvailable].
  /// Android-only; silently no-ops elsewhere and on network failure so it
  /// never blocks or disrupts app startup.
  Future<void> checkForUpdate() async {
    if (!Platform.isAndroid) return;

    final release = await _service.fetchLatestRelease();
    if (release == null) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final available = isNewerVersion(release.version, packageInfo.version);

    state = state.copyWith(release: release, isUpdateAvailable: available);
  }

  /// Called once on app startup: checks for an update and, if one is
  /// available and the user hasn't already dismissed this exact version,
  /// shows the update dialog.
  Future<void> checkAndPromptOnStartup() async {
    if (!Platform.isAndroid) return;

    await checkForUpdate();
    final release = state.release;
    if (release == null || !state.isUpdateAvailable) return;

    final settings = _ref.read(settingsProvider);
    if (release.version == settings.dismissedUpdateVersion) return;

    final shouldUpdate = await showUpdateAvailableDialog(release: release);
    if (shouldUpdate) {
      await downloadAndInstall(release);
    } else {
      await _ref
          .read(settingsProvider.notifier)
          .setDismissedUpdateVersion(release.version);
    }
  }

  /// Shared entry point for both the startup dialog's "Update" action and
  /// the Settings screen's "Update" button. Idempotent: a second call while
  /// already downloading is a no-op.
  Future<void> downloadAndInstall(AppRelease release) async {
    if (state.isDownloading) return;

    final apkUrl = release.apkDownloadUrl;
    if (apkUrl == null) {
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Update file not available yet')),
      );
      return;
    }

    state = state.copyWith(isDownloading: true, downloadProgress: 0);
    rootScaffoldMessengerKey.currentState?.showSnackBar(
      const SnackBar(
        content: UpdateProgressSnackbarContent(),
        duration: Duration(minutes: 5),
      ),
    );

    try {
      final fileName =
          release.apkAssetName ?? 'cadence-${release.version}.apk';
      final filePath = await _service.downloadApk(
        apkUrl,
        fileName,
        onProgress: (progress) => state = state.copyWith(
          isDownloading: true,
          downloadProgress: progress,
        ),
      );

      rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      await _service.installApk(filePath);
    } catch (e) {
      rootScaffoldMessengerKey.currentState?.hideCurrentSnackBar();
      rootScaffoldMessengerKey.currentState?.showSnackBar(
        const SnackBar(content: Text('Failed to download update')),
      );
    } finally {
      state = state.copyWith(isDownloading: false, downloadProgress: 0);
    }
  }
}

final updateStatusProvider =
    StateNotifierProvider<UpdateNotifier, UpdateStatus>((ref) {
  return UpdateNotifier(ref.watch(updateServiceProvider), ref);
});
