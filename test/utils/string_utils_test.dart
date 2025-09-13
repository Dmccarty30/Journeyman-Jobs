import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/utils/string_utils.dart';

void main() {
  group('StringUtils.normalizeJobTitle', () {
    test('should normalize hyphenated titles', () {
      expect(StringUtils.normalizeJobTitle('journeyman-lineman'), 'Journeyman Lineman');
      expect(StringUtils.normalizeJobTitle('JOURNEYMAN-LINEMAN'), 'Journeyman Lineman');
      expect(StringUtils.normalizeJobTitle('senior-electrician'), 'Senior Electrician');
    });

    test('should normalize underscored titles', () {
      expect(StringUtils.normalizeJobTitle('journeyman_lineman'), 'Journeyman Lineman');
      expect(StringUtils.normalizeJobTitle('SENIOR_ELECTRICIAN'), 'Senior Electrician');
    });

    test('should normalize mixed separators', () {
      expect(StringUtils.normalizeJobTitle('journeyman-lineman_electrician'), 'Journeyman Lineman Electrician');
    });

    test('should handle already normalized titles', () {
      expect(StringUtils.normalizeJobTitle('Journeyman Lineman'), 'Journeyman Lineman');
      expect(StringUtils.normalizeJobTitle('Senior Electrician'), 'Senior Electrician');
    });

    test('should handle acronyms correctly', () {
      expect(StringUtils.normalizeJobTitle('cdl driver'), 'CDL Driver');
      expect(StringUtils.normalizeJobTitle('fa/cpr certified'), 'FA CPR Certified');
    });

    test('should handle null and empty values', () {
      expect(StringUtils.normalizeJobTitle(null), '');
      expect(StringUtils.normalizeJobTitle(''), '');
      expect(StringUtils.normalizeJobTitle('   '), '');
    });

    test('should handle single words', () {
      expect(StringUtils.normalizeJobTitle('electrician'), 'Electrician');
      expect(StringUtils.normalizeJobTitle('LINEMAN'), 'Lineman');
    });

    test('should handle multiple spaces and cleanup', () {
      expect(StringUtils.normalizeJobTitle('journeyman   lineman'), 'Journeyman Lineman');
      expect(StringUtils.normalizeJobTitle('  senior  electrician  '), 'Senior Electrician');
    });
  });

  group('StringUtils.needsNormalization', () {
    test('should detect titles needing normalization', () {
      expect(StringUtils.needsNormalization('journeyman-lineman'), true);
      expect(StringUtils.needsNormalization('JOURNEYMAN_LINEMAN'), true);
      expect(StringUtils.needsNormalization('journeyman lineman'), false);
      expect(StringUtils.needsNormalization('Journeyman Lineman'), false);
      expect(StringUtils.needsNormalization(null), false);
      expect(StringUtils.needsNormalization(''), false);
    });
  });
}
