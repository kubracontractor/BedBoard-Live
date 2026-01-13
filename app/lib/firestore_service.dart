import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // --- Streams ---
  Stream<List<Ward>> watchWards() => _db.collection('wards')
    .snapshots()
    .map((s) => s.docs.map((d) => Ward.fromMap(d.id, d.data())).toList());

  Stream<List<Bed>> watchBedsForWard(String wardId) => _db.collection('beds')
    .where('wardId', isEqualTo: wardId)
    .snapshots()
    .map((s) => s.docs.map((d) => Bed.fromMap(d.id, d.data())).toList());

  Stream<List<Bed>> watchAllBeds() => _db.collection('beds')
    .snapshots()
    .map((s) => s.docs.map((d) => Bed.fromMap(d.id, d.data())).toList());

  // --- Mutations ---
  Future<void> seedSample() async {
    // idempotent-ish: only seed if empty
    final wardsSnap = await _db.collection('wards').limit(1).get();
    if (wardsSnap.docs.isNotEmpty) return;

    final edRef = _db.collection('wards').doc();
    final surgRef = _db.collection('wards').doc();

    await edRef.set({'name': 'ED Blue', 'capacity': 6});
    await surgRef.set({'name': 'Surgical A', 'capacity': 6});

    Future<void> addBeds(String wardId, String prefix) async {
      for (var i = 1; i <= 6; i++) {
        final bedRef = _db.collection('beds').doc();
        await bedRef.set({
          'wardId': wardId,
          'code': '$prefix-${i.toString().padLeft(2, '0')}',
          'status': 'free',
        });
      }
    }

    await addBeds(edRef.id, 'B');
    await addBeds(surgRef.id, 'S');
  }

  Future<void> updateBedStatus({
    required String bedId,
    required BedStatus status,
    String? patientAnonId,
  }) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    final bedRef = _db.collection('beds').doc(bedId);
    final bedSnap = await bedRef.get();
    final bed = Bed.fromMap(bedSnap.id, bedSnap.data()!);

    // write bed change
    await bedRef.update({
      'status': bedStatusToString(status),
      'currentPatientAnonId': patientAnonId,
    });

    // append event
    await _db.collection('occupancy_events').add({
      'timestamp': FieldValue.serverTimestamp(),
      'bedId': bedId,
      'wardId': bed.wardId,
      'action': status == BedStatus.occupied
          ? 'allocate'
          : status == BedStatus.cleaning
            ? 'mark_cleaning'
            : status == BedStatus.free
              ? 'discharge'
              : 'maintenance',
      'actorUid': uid,
    });
  }
}
