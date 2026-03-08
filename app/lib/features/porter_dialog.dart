
import 'package:flutter/material.dart';
import '../models.dart';
import '../firestore_service.dart';

void showPorterDialog(
  BuildContext context,
  Ward currentWard,
  List<Bed> currentWardBeds,
  List<Ward> allWards,
  FirestoreService fs,
) {
  final occupiedBeds =
      currentWardBeds.where((b) => b.status == BedStatus.occupied).toList();

  if (occupiedBeds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No occupied beds to move')),
    );
    return;
  }

  String? selectedBedId;
  String? selectedMobility;
  String? selectedDestination;
  String? selectedTargetWardId;
  String? selectedTargetBedId;
  String? selectedTest;
  String? hospitalNumber;
  String? errorText;

  final notesController = TextEditingController();

  final List<String> tests = [
    'MRI',
    'CT Scan',
    'X-Ray',
    'Theatre',
    'Ultrasound',
  ];

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Book Porter'),
            content: SizedBox(
              width: 480,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Patient',
                        border: OutlineInputBorder(),
                      ),
                      items: occupiedBeds.map((bed) {
                        return DropdownMenuItem<String>(
                          value: bed.id,
                          child: Text(
                              '${bed.hospitalNumber ?? ''} (${bed.code})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        final bed =
                            occupiedBeds.firstWhere((b) => b.id == value);
                        setState(() {
                          selectedBedId = value;
                          hospitalNumber = bed.hospitalNumber;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Mobility',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'Wheelchair',
                            child: Text('Wheelchair')),
                        DropdownMenuItem(
                            value: 'Trolley',
                            child: Text('Trolley')),
                        DropdownMenuItem(
                            value: 'Hospital Bed',
                            child: Text('Hospital Bed')),
                      ],
                      onChanged: (value) {
                        selectedMobility = value;
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Move To',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                            value: 'ward',
                            child: Text('Another Ward')),
                        DropdownMenuItem(
                            value: 'test',
                            child: Text('Test / Scan')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          selectedDestination = value;
                          selectedTargetWardId = null;
                          selectedTargetBedId = null;
                          selectedTest = null;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    if (selectedDestination == 'ward') ...[

                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Destination Ward',
                          border: OutlineInputBorder(),
                        ),
                        items: allWards
                            .where((w) => w.id != currentWard.id)
                            .map((ward) => DropdownMenuItem<String>(
                                  value: ward.id,
                                  child: Text(ward.wardname),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedTargetWardId = value;
                            selectedTargetBedId = null;
                          });
                        },
                      ),

                      const SizedBox(height: 16),

                      if (selectedTargetWardId != null)
                        StreamBuilder<List<Bed>>(
                          stream: fs.watchBedsForWard(
                              selectedTargetWardId!),
                          builder: (context, snapshot) {

                            if (!snapshot.hasData) {
                              return const SizedBox();
                            }

                            final freeBeds = snapshot.data!
                                .where((b) =>
                                    b.status == BedStatus.free)
                                .toList();

                            if (freeBeds.isEmpty) {
                              return const Text(
                                'No free beds available in this ward.',
                                style:
                                    TextStyle(color: Colors.red),
                              );
                            }

                            return DropdownButtonFormField<String>(
                              value: freeBeds.any((b) =>
                                      b.id ==
                                      selectedTargetBedId)
                                  ? selectedTargetBedId
                                  : null,
                              decoration:
                                  const InputDecoration(
                                labelText: 'Select Free Bed',
                                border:
                                    OutlineInputBorder(),
                              ),
                              items: freeBeds.map((bed) {
                                return DropdownMenuItem<String>(
                                  value: bed.id,
                                  child: Text(bed.code),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTargetBedId = value;
                                });
                              },
                            );
                          },
                        ),

                      const SizedBox(height: 16),
                    ],

                    if (selectedDestination == 'test') ...[
                      DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Select Test',
                          border: OutlineInputBorder(),
                        ),
                        items: tests
                            .map((test) =>
                                DropdownMenuItem<String>(
                                  value: test,
                                  child: Text(test),
                                ))
                            .toList(),
                        onChanged: (value) {
                          selectedTest = value;
                        },
                      ),
                      const SizedBox(height: 16),
                    ],

                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'Additional Notes',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 12),
                      Text(
                        errorText!,
                        style:
                            const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),

              ElevatedButton(
                onPressed: () async {

                  if (selectedBedId == null ||
                      selectedMobility == null ||
                      selectedDestination == null) {
                    setState(() {
                      errorText =
                          'All required fields must be selected.';
                    });
                    return;
                  }

                  final selectedBed = occupiedBeds
                      .firstWhere((b) =>
                          b.id == selectedBedId);

                  if (selectedDestination == 'test') {

                    if (selectedTest == null) {
                      setState(() {
                        errorText =
                            'Select a test.';
                      });
                      return;
                    }

                    await fs.updateBedStatus(
                      bedId: selectedBed.id,
                      status:
                          BedStatus.awaiting_test,
                      hospitalNumber:
                          hospitalNumber,
                    );

                    Navigator.pop(dialogContext);
                    return;
                  }

                  if (selectedDestination == 'ward') {

                    if (selectedTargetWardId ==
                            null ||
                        selectedTargetBedId ==
                            null) {
                      setState(() {
                        errorText =
                            'Select destination ward and bed.';
                      });
                      return;
                    }

                    await fs.updateBedStatus(
                      bedId: selectedBed.id,
                      status: BedStatus.free,
                      hospitalNumber: null,
                    );

                    await fs.updateBedStatus(
                      bedId: selectedTargetBedId!,
                      status:
                          BedStatus.occupied,
                      hospitalNumber:
                          hospitalNumber,
                    );

                    Navigator.pop(dialogContext);
                  }
                },
                child:
                    const Text('Confirm Transfer'),
              ),
            ],
          );
        },
      );
    },
  );
}
