
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models.dart';
import '../firestore_service.dart';

void showEstatesDialog(
  BuildContext context,
  Ward ward,
  List<Bed> beds,
  FirestoreService fs,
) {
  final allowedBeds = beds.where((b) =>
      b.status == BedStatus.free ||
      b.status == BedStatus.occupied ||
      b.status == BedStatus.cleaning).toList();

  if (allowedBeds.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('No beds available to report')),
    );
    return;
  }

  String? selectedBedId;
  final issueController = TextEditingController();
  final nameController = TextEditingController();
  String? errorText;

  showDialog(
    context: context,
    builder: (dialogContext) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text('Report Estates Issue'),
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
                      items: allowedBeds.map((bed) {
                        return DropdownMenuItem(
                          value: bed.id,
                          child: Text(bed.code),
                        );
                      }).toList(),
                      onChanged: (value) {
                        selectedBedId = value;
                      },
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: issueController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Describe Issue (Required)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 16),

                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Reported By (Required)',
                        border: OutlineInputBorder(),
                      ),
                    ),

                    if (errorText != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        errorText!,
                        style: const TextStyle(color: Colors.red),
                      ),
                    ],
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(dialogContext),
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () async {

                  if (selectedBedId == null ||
                      issueController.text.trim().isEmpty ||
                      nameController.text.trim().isEmpty) {
                    setState(() {
                      errorText = 'All fields are required.';
                    });
                    return;
                  }

                  final db = FirebaseFirestore.instance;

                  final ticketNumber =
                      await db.runTransaction<int>((transaction) async {

                    final counterRef =
                        db.collection('counters').doc('estates');

                    final snap = await transaction.get(counterRef);

                    int current = 10000;

                    if (snap.exists &&
                        snap.data()!.containsKey('lastTicketNumber')) {
                      current = snap['lastTicketNumber'];
                    }

                    int newTicket = current + 1;

                    transaction.set(counterRef, {
                      'lastTicketNumber': newTicket,
                    });

                    return newTicket;
                  });

                  await db.collection('estates_requests').add({
                    'ticketNumber': ticketNumber,
                    'bedId': selectedBedId,
                    'wardId': ward.id,
                    'issue': issueController.text.trim(),
                    'reportedBy': nameController.text.trim(),
                    'status': 'open',
                    'timestamp': FieldValue.serverTimestamp(),
                  });

                  await fs.updateBedStatus(
                    bedId: selectedBedId!,
                    status: BedStatus.maintenance,
                    hospitalNumber: null,
                  );

                  Navigator.pop(dialogContext);

                  showDialog(
                    context: context,
                    builder: (confirmContext) => AlertDialog(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      content: SizedBox(
                        width: 350,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Text(
                              'Request Submitted',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text('Ticket Number: $ticketNumber'),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                Navigator.pop(confirmContext);
                              },
                              child: const Text('Continue'),
                            )
                          ],
                        ),
                      ),
                    ),
                  );
                },
                child: const Text('Submit Report'),
              ),
            ],
          );
        },
      );
    },
  );
}

