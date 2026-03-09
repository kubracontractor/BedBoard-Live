import 'package:flutter_test/flutter_test.dart';
import 'package:app/utils/validation.dart';

void main() {

  group('Hospital Number Validation Tests', () {

    test('Valid hospital number passes', () {
      expect(isValidHospitalNumber('12345678'), true);
    });

    test('Invalid hospital number fails', () {
      expect(isValidHospitalNumber('1234'), false);
      expect(isValidHospitalNumber('abcd1234'), false);
      expect(isValidHospitalNumber('123456789'), false);
    });

  });

}