

//file to represent hospital wards, beds, bed-status
import 'package:cloud_firestore/cloud_firestore.dart';

class Ward {
  final String id;
  final String wardname;
  final int WardCapacity;

  Ward({required this.id, 
        required this.wardname, 
        required this.WardCapacity
        });

//constructor to create dart object from firestore data
  factory Ward.fromMap(String id, Map<String, dynamic> data) {
  return Ward(
    id: id,
    wardname: data['wardname'] ?? data['name'] ?? 'Unnamed',
    WardCapacity:
        ((data['WardCapacity'] ?? data['capacity']) as num?)?.toInt() ?? 0,
  );
}

  Map<String, dynamic> toMap() => {
    'name': wardname,
    'capacity': WardCapacity,
  };
}

enum BedStatus { free, occupied, cleaning, maintenance, awaiting_test }

BedStatus bedStatusFromString(String s) {
  switch (s) {
    case 'occupied': return BedStatus.occupied;
    case 'cleaning': return BedStatus.cleaning;
    case 'maintenance': return BedStatus.maintenance;
    case 'awaiting_test': return BedStatus.awaiting_test;
    default: return BedStatus.free;
  }
}

String bedStatusToString(BedStatus s) {
  switch (s) {
    case BedStatus.occupied: return 'occupied';
    case BedStatus.cleaning: return 'cleaning';
    case BedStatus.maintenance: return 'maintenance';
    case BedStatus.awaiting_test: return 'awaiting_test';
    case BedStatus.free: default: return 'free';
  }
}

class Bed {
  final String id;
  final String wardId;
  final String code;
  final BedStatus status;
  //change the currentPatientAnonId to hospitalNumber
  final String? hospitalNumber;  
  
  final String? updatedBy;
  final DateTime? updatedAt;


  Bed({
    required this.id,
    required this.wardId,
    required this.code,
    required this.status,
    this.hospitalNumber,
    this.updatedBy,
    this.updatedAt,
  });

  factory Bed.fromMap(String id, Map<String, dynamic> data) {
    return Bed(
      id: id,
      wardId: data['wardId'] as String,
      code: data['code'] as String? ?? id,
      status: bedStatusFromString(data['status'] as String? ?? 'free'),
      hospitalNumber: data['hospitalNumber'] as String?,  
      updatedBy: data['updatedBy'] as String?,
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),   //kept it optional
    );
  }

  Map<String, dynamic> toMap() => {
    'wardId': wardId,
    'code': code,
    'status': bedStatusToString(status),
    if (hospitalNumber != null) 'hospitalNumber': hospitalNumber,
  };
}



