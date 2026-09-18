import 'package:flutter_test/flutter_test.dart';
import 'package:tracer/core/services/update_service.dart';

void main() {
  group('isNewerVersion', () {
    test('returns false when versions are equal', () {
      expect(isNewerVersion('1.2.3', '1.2.3'), isFalse);
    });

    test('returns true when remote patch is newer', () {
      expect(isNewerVersion('1.2.4', '1.2.3'), isTrue);
    });

    test('returns true when remote minor is newer', () {
      expect(isNewerVersion('1.3.0', '1.2.9'), isTrue);
    });

    test('returns true when remote major is newer', () {
      expect(isNewerVersion('2.0.0', '1.9.9'), isTrue);
    });

    test('returns false when remote is older', () {
      expect(isNewerVersion('1.2.2', '1.2.3'), isFalse);
    });

    test('returns false when remote version is malformed', () {
      expect(isNewerVersion('not-a-version', '1.2.3'), isFalse);
    });

    test('returns false when local version is malformed', () {
      expect(isNewerVersion('1.2.4', 'dev'), isFalse);
    });
  });
}
