import 'package:flutter/material.dart';
import 'models.dart';
import 'firestore_service.dart';

class BedBoardScreen extends StatefulWidget {
  const BedBoardScreen({super.key});
  @override
  State<BedBoardScreen> createState() => _BedBoardScreenState();
}

class _BedBoardScreenState extends State<BedBoardScreen> {
  final _fs = FirestoreService();

  @override
  void initState() {
    super.initState();
    // seed the first time you open the screen (safe: it checks emptiness)
    _fs.seedSample();
  }

  Color _statusColor(BedStatus s) {
    switch (s) {
      case BedStatus.occupied:
        return Colors.red;
      case BedStatus.cleaning:
        return Colors.orange;
      case BedStatus.maintenance:
        return Colors.grey;
      case BedStatus.free:
      default:
        return Colors.green;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Ward>>(
      stream: _fs.watchWards(),
      builder: (context, wardsSnap) {
        if (wardsSnap.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (wardsSnap.hasError) {
          return Scaffold(
            body: Center(child: Text('Error: ${wardsSnap.error}')),
          );
        }
        final wards = wardsSnap.data ?? [];
        return Scaffold(
          appBar: AppBar(title: const Text('Bed Board (Realtime)')),
          body: ListView.builder(
            itemCount: wards.length,
            itemBuilder: (context, idx) {
              final ward = wards[idx];
              return Card(
                margin: const EdgeInsets.all(12),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${ward.name} (cap ${ward.capacity})',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      StreamBuilder<List<Bed>>(
                        stream: _fs.watchBedsForWard(ward.id),
                        builder: (context, bedsSnap) {
                          final beds = bedsSnap.data ?? [];
                          if (bedsSnap.connectionState ==
                              ConnectionState.waiting) {
                            return const Padding(
                              padding: EdgeInsets.all(8),
                              child: LinearProgressIndicator(),
                            );
                          }
                          return Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: beds.map((b) {
                              return GestureDetector(
                                onTap: () => _showBedActions(context, b),
                                child: Container(
                                  width: 120,
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.black12),
                                  ),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        b.code,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: _statusColor(
                                            b.status,
                                          ).withOpacity(0.15),
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                        ),
                                        child: Text(
                                          b.status.name,
                                          style: TextStyle(
                                            color: _statusColor(b.status),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }).toList(),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  void _showBedActions(BuildContext context, Bed bed) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              title: const Text('Mark as Occupied'),
              onTap: () async {
                Navigator.pop(context);
                await FirestoreService().updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.occupied,
                  patientAnonId:
                      'P${DateTime.now().millisecondsSinceEpoch % 100000}',
                );
              },
            ),
            ListTile(
              title: const Text('Mark as Cleaning'),
              onTap: () async {
                Navigator.pop(context);
                await FirestoreService().updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.cleaning,
                );
              },
            ),
            ListTile(
              title: const Text('Mark as Free'),
              onTap: () async {
                Navigator.pop(context);
                await FirestoreService().updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.free,
                  patientAnonId: null,
                );
              },
            ),
            ListTile(
              title: const Text('Mark as Maintenance'),
              onTap: () async {
                Navigator.pop(context);
                await FirestoreService().updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.maintenance,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
