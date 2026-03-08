
//file for data management
//middleman between app and firestore database - like a service layer
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'models.dart';

class FirestoreService {
  final _db = FirebaseFirestore.instance;

  // Streams - live pipe of data-  no refresh needed, automatic stream updates
  Stream<List<Ward>> watchWards() => _db
      .collection('wards')
      .snapshots()
      .map((s) => s.docs.map((d) => Ward.fromMap(d.id, d.data())).toList());

  //to filter bed data per ward in realtime
  Stream<List<Bed>> watchBedsForWard(String wardId) => _db
      .collection('beds')
      .where('wardId', isEqualTo: wardId)
      .snapshots() //listen to real time changes
      .map((s) => s.docs.map((d) => Bed.fromMap(d.id, d.data())).toList());

  //future use- to make admin dashboard,, wide metrics
  Stream<List<Bed>> watchAllBeds() => _db
      .collection('beds')
      .snapshots()
      .map((s) => s.docs.map((d) => Bed.fromMap(d.id, d.data())).toList());

  // Mutations
  Future<void> seedSample() async {
    // idempotent-ish only seed if empty, if data exists, do nothing, no duplicates
    final wardsSnap = await _db.collection('wards').limit(1).get();
    if (wardsSnap.docs.isNotEmpty) return;

    final edRef = _db.collection('wards').doc();
    final surgRef = _db.collection('wards').doc();

    await edRef.set({'name': 'ED Majors-1', 'capacity': 6});
    await surgRef.set({'name': 'Surgical A', 'capacity': 6});

    //adding beds to ward using for loop to genrate the bed codes like M1-01
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
    String? hospitalNumber,
    Map<String, dynamic>? additionalData,
  }) async {

    final user = FirebaseAuth.instance.currentUser;

    //data-integreity - no duplicates
    if (status == BedStatus.occupied && hospitalNumber != null) {

      final existing = await _db
          .collection('beds')
          .where('hospitalNumber', isEqualTo: hospitalNumber)
          .where('status', isEqualTo: 'occupied')
          .get();

      //  if this hospital number exist
      if (existing.docs.any((doc) => doc.id != bedId)) {
        throw Exception('Hospital number already assigned to another bed');
      }
    }

    await _db.collection('beds').doc(bedId).update({
      'status': bedStatusToString(status),
      'hospitalNumber': hospitalNumber,
      'updatedBy': user?.email,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    await _db.collection('occupancy_events').add({
      'bedId': bedId,
      'status': bedStatusToString(status),
      'hospitalNumber': hospitalNumber,
      'updatedBy': user?.email,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

  Future<void> transferPatientToWard({
    required String sourceBedId,
    required String destinationBedId,
    required String hospitalNumber,
  }) async {

    final user = FirebaseAuth.instance.currentUser;
    final db = FirebaseFirestore.instance;

    await db.runTransaction((transaction) async {

      final sourceRef = db.collection('beds').doc(sourceBedId);
      final destRef = db.collection('beds').doc(destinationBedId);

      final sourceSnap = await transaction.get(sourceRef);
      final destSnap = await transaction.get(destRef);

      if (!destSnap.exists) {
        throw Exception("Destination bed does not exist");
      }

      if (destSnap['status'] != 'free') {
        throw Exception("Destination bed not free");
      }

      // free source bed
      transaction.update(sourceRef, {
        'status': 'free',
        'hospitalNumber': null,
        'updatedBy': user?.email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // occupy destination bed
      transaction.update(destRef, {
        'status': 'occupied',
        'hospitalNumber': hospitalNumber,
        'updatedBy': user?.email,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // log transfer event
      final eventRef = db.collection('occupancy_events').doc();
      transaction.set(eventRef, {
        'type': 'transfer',
        'fromBed': sourceBedId,
        'toBed': destinationBedId,
        'hospitalNumber': hospitalNumber,
        'performedBy': user?.email,
        'timestamp': FieldValue.serverTimestamp(),
      });

    });
  }
}

