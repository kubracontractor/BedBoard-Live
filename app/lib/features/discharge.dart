
import 'package:flutter/material.dart';
import '../models.dart';
import '../firestore_service.dart';

void showDischargeDialog(
  BuildContext context,
  Ward ward,
  List<Bed> beds,
  FirestoreService fs,
) {
  final occupiedBeds =
      beds.where((b) => b.status == BedStatus.occupied).toList();

  if (occupiedBeds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No occupied beds to discharge')),
    );
    return;
  }

  String? selectedBedId;
  String dischargeType = 'Self-Discharge';
  String? errorText;

  final TextEditingController commentController =
      TextEditingController();

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Discharge Patient'),
            content: SizedBox(
              width: 420,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [

                    DropdownButtonFormField<String>(
                      decoration: const InputDecoration(
                        labelText: 'Select Bed',
                        border: OutlineInputBorder(),
                      ),
                      items: occupiedBeds.map((bed) {
                        return DropdownMenuItem<String>(
                          value: bed.id,
                          child: Text(
                              '${bed.code} (${bed.hospitalNumber ?? ''})'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          selectedBedId = value;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    DropdownButtonFormField<String>(
                      value: dischargeType,
                      decoration: const InputDecoration(
                        labelText: 'Discharge Type',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(
                          value: 'Self-Discharge',
                          child: Text('Self-Discharge'),
                        ),
                        DropdownMenuItem(
                          value: 'Follow-Up Needed',
                          child: Text(
                              'Normal Discharge - Follow-Up Needed'),
                        ),
                        DropdownMenuItem(
                          value: 'No Follow-Up',
                          child: Text(
                              'Normal Discharge - No Follow-Up'),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          dischargeType = value!;
                        });
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: commentController,
                      maxLines: 2,
                      decoration: const InputDecoration(
                        labelText:
                            'Additional Comments (Optional)',
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

                  if (selectedBedId == null) {
                    setState(() {
                      errorText = 'Please select a bed.';
                    });
                    return;
                  }

                  await fs.updateBedStatus(
                    bedId: selectedBedId!,
                    status: BedStatus.free,
                    hospitalNumber: null,
                    additionalData: {
                      'dischargeType': dischargeType,
                      'comments':
                          commentController.text.trim(),
                    },
                  );

                  Navigator.pop(dialogContext);
                },
                child:
                    const Text('Confirm Discharge'),
              ),
            ],
          );
        },
      );
    },
  );
}
