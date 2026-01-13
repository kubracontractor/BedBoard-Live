class Ward {
  final String id;
  final String name;
  final int capacity;

  Ward({required this.id, required this.name, required this.capacity});

  factory Ward.fromMap(String id, Map<String, dynamic> data) {
    return Ward(
      id: id,
      name: data['name'] as String? ?? 'Unnamed',
      capacity: (data['capacity'] as num?)?.toInt() ?? 0,
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'capacity': capacity,
  };
}

enum BedStatus { free, occupied, cleaning, maintenance }

BedStatus bedStatusFromString(String s) {
  switch (s) {
    case 'occupied': return BedStatus.occupied;
    case 'cleaning': return BedStatus.cleaning;
    case 'maintenance': return BedStatus.maintenance;
    default: return BedStatus.free;
  }
}

String bedStatusToString(BedStatus s) {
  switch (s) {
    case BedStatus.occupied: return 'occupied';
    case BedStatus.cleaning: return 'cleaning';
    case BedStatus.maintenance: return 'maintenance';
    case BedStatus.free: default: return 'free';
  }
}

class Bed {
  final String id;
  final String wardId;
  final String code;
  final BedStatus status;
  final String? currentPatientAnonId;

  Bed({
    required this.id,
    required this.wardId,
    required this.code,
    required this.status,
    this.currentPatientAnonId,
  });

  factory Bed.fromMap(String id, Map<String, dynamic> data) {
    return Bed(
      id: id,
      wardId: data['wardId'] as String,
      code: data['code'] as String? ?? id,
      status: bedStatusFromString(data['status'] as String? ?? 'free'),
      currentPatientAnonId: data['currentPatientAnonId'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
    'wardId': wardId,
    'code': code,
    'status': bedStatusToString(status),
    if (currentPatientAnonId != null) 'currentPatientAnonId': currentPatientAnonId,
  };
}
