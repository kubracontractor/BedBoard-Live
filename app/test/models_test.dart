import 'package:flutter_test/flutter_test.dart';
import 'package:app/models.dart';

void main() {

  group('BedStatus Conversion Tests', () {

    test('String to BedStatus conversion works', () {
      expect(bedStatusFromString('occupied'), BedStatus.occupied);
      expect(bedStatusFromString('cleaning'), BedStatus.cleaning);
      expect(bedStatusFromString('maintenance'), BedStatus.maintenance);
      expect(bedStatusFromString('awaiting_test'), BedStatus.awaiting_test);
      expect(bedStatusFromString('unknown'), BedStatus.free);
    });

    test('BedStatus to String conversion works', () {
      expect(bedStatusToString(BedStatus.occupied), 'occupied');
      expect(bedStatusToString(BedStatus.cleaning), 'cleaning');
      expect(bedStatusToString(BedStatus.free), 'free');
    });

  });

}