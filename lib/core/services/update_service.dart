import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import 'package:open_filex/open_filex.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../models/app_release.dart';

/// Returns true if [remote] is a strictly newer version than [local].
///
/// Both are expected to be plain "major.minor.patch" semver strings. Any
/// version that fails to parse is treated as not-newer (fail-safe: better to
/// silently skip an update prompt than to show one based on bad data).
bool isNewerVersion(String remote, String local) {
  final remoteParts = _parseVersion(remote);
  final localParts = _parseVersion(local);
  if (remoteParts == null || localParts == null) return false;

  for (var i = 0; i < 3; i++) {
    if (remoteParts[i] != localParts[i]) {
      return remoteParts[i] > localParts[i];
    }
  }
  return false;
}

List<int>? _parseVersion(String version) {
  final parts = version.split('.');
  if (parts.length < 3) return null;
  final numbers = <int>[];
  for (var i = 0; i < 3; i++) {
    final n = int.tryParse(parts[i]);
    if (n == null) return null;
    numbers.add(n);
  }
  return numbers;
}

class UpdateService {
  UpdateService(this._client);

  final http.Client _client;

  static const _apiUrl =
      'https://api.github.com/repos/ak1m1tsu/cadence/releases/latest';

  Future<AppRelease?> fetchLatestRelease() async {
    try {
      final response = await _client.get(
        Uri.parse(_apiUrl),
        headers: const {'Accept': 'application/vnd.github+json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode != 200) return null;

      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return AppRelease.fromJson(json);
    } catch (e) {
      debugPrint('UpdateService.fetchLatestRelease failed: $e');
      return null;
    }
  }

  /// Downloads [url] into the app's temporary directory as [fileName],
  /// reporting progress in [0, 1] via [onProgress]. Returns the local path.
  Future<String> downloadApk(
    String url,
    String fileName, {
    void Function(double progress)? onProgress,
  }) async {
    final request = http.Request('GET', Uri.parse(url));
    final response = await _client.send(request);

    if (response.statusCode != 200) {
      throw Exception('Download failed with status ${response.statusCode}');
    }

    final total = response.contentLength ?? 0;
    var received = 0;

    final tempDir = await getTemporaryDirectory();
    final file = File(p.join(tempDir.path, fileName));
    final sink = file.openWrite();

    try {
      await for (final chunk in response.stream) {
        sink.add(chunk);
        received += chunk.length;
        if (total > 0) onProgress?.call(received / total);
      }
    } finally {
      await sink.close();
    }

    return file.path;
  }

  /// Opens the downloaded APK, launching Android's system installer.
  Future<void> installApk(String filePath) async {
    final result = await OpenFilex.open(filePath);
    if (result.type != ResultType.done) {
      throw Exception('Failed to open installer: ${result.message}');
    }
  }
}

final updateServiceProvider = Provider<UpdateService>((ref) {
  return UpdateService(http.Client());
});
