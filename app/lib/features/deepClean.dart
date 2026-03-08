
import 'package:flutter/material.dart';
import '../models.dart';
import '../firestore_service.dart';

void showDeepCleanDialog(
  BuildContext context,
  Ward ward,
  List<Bed> beds,
  FirestoreService fs,
) {
  String? selectedBedId;
  String? selectedCleanType;
  String? errorText;

  final eligibleBeds = beds.where((b) =>
      b.status == BedStatus.free ||
      b.status == BedStatus.occupied).toList();

  showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text('Book Deep Clean'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Bed',
                    border: OutlineInputBorder(),
                  ),
                  items: eligibleBeds.map((bed) {
                    return DropdownMenuItem(
                      value: bed.id,
                      child: Text(bed.code),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => selectedBedId = value);
                  },
                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Clean Type',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'discharge',
                      child: Text('Discharge Deep Clean'),
                    ),
                    DropdownMenuItem(
                      value: 'amber',
                      child: Text('Amber Clean (Infection)'),
                    ),
                    DropdownMenuItem(
                      value: 'fogging',
                      child: Text('Fogging (High Risk)'),
                    ),
                  ],
                  onChanged: (value) {
                    setState(() => selectedCleanType = value);
                  },
                ),

                if (errorText != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    errorText!,
                    style: const TextStyle(color: Colors.red),
                  )
                ]
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {
                  if (selectedBedId == null ||
                      selectedCleanType == null) {
                    setState(() {
                      errorText = 'Please complete all fields';
                    });
                    return;
                  }

                  final selectedBed = beds
                      .firstWhere((b) => b.id == selectedBedId);

                  String? hospitalNumber =
                      selectedBed.hospitalNumber;

                  if (selectedCleanType == 'discharge' ||
                      selectedCleanType == 'fogging') {
                    hospitalNumber = null;
                  }

                  await fs.updateBedStatus(
                    bedId: selectedBedId!,
                    status: BedStatus.cleaning,
                    hospitalNumber: hospitalNumber,
                  );

                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        },
      );
    },
  );
}

