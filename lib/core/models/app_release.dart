/// A GitHub release, as returned by the `/releases/latest` API endpoint.
class AppRelease {
  /// Semver without the leading 'v', e.g. "1.3.0".
  final String version;

  /// Raw tag name, e.g. "v1.3.0".
  final String tagName;

  /// Direct download URL of the `.apk` asset, if one was attached.
  final String? apkDownloadUrl;

  /// File name of the `.apk` asset, used as the local download file name.
  final String? apkAssetName;

  /// Release notes body (markdown), if any.
  final String? releaseNotes;

  /// Web URL of the release page.
  final String htmlUrl;

  const AppRelease({
    required this.version,
    required this.tagName,
    required this.htmlUrl,
    this.apkDownloadUrl,
    this.apkAssetName,
    this.releaseNotes,
  });

  factory AppRelease.fromJson(Map<String, dynamic> json) {
    final tagName = json['tag_name'] as String;
    final assets = (json['assets'] as List<dynamic>?) ?? const [];

    Map<String, dynamic>? apkAsset;
    for (final asset in assets) {
      final map = asset as Map<String, dynamic>;
      final name = map['name'] as String?;
      if (name != null && name.toLowerCase().endsWith('.apk')) {
        apkAsset = map;
        break;
      }
    }

    return AppRelease(
      version: tagName.startsWith('v') ? tagName.substring(1) : tagName,
      tagName: tagName,
      htmlUrl: json['html_url'] as String? ?? '',
      apkDownloadUrl: apkAsset?['browser_download_url'] as String?,
      apkAssetName: apkAsset?['name'] as String?,
      releaseNotes: json['body'] as String?,
    );
  }
}
