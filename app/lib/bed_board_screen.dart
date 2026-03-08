

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'features/deepClean.dart';
import 'features/discharge.dart';
import 'features/estates_dialog.dart';
import 'features/porter_dialog.dart';

import 'models.dart';
import 'firestore_service.dart';
import 'userService.dart';

class BedBoardScreen extends StatefulWidget {
  const BedBoardScreen({super.key});

  @override
  State<BedBoardScreen> createState() => _BedBoardScreenState();
}

class _BedBoardScreenState extends State<BedBoardScreen> {
  final FirestoreService _fs = FirestoreService();

  String? selectedWardId;
  BedStatus? selectedFilter;

  @override
  void initState() {
    super.initState();
    _fs.seedSample();
  }

  // UI HELPERS

  Color _statusColor(BedStatus s) {
    switch (s) {
      case BedStatus.occupied:
        return Colors.red;
      case BedStatus.cleaning:
        return Colors.orange;
      case BedStatus.maintenance:
        return Colors.grey;
      case BedStatus.free:
        return Colors.green;
      case BedStatus.awaiting_test:
        return const Color.fromARGB(255, 171, 113, 181);
      default:
        return Colors.green;
    }
  }

  Widget _buildStatusList() {
    Widget legendItem(Color color, String label) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 16,
            height: 16,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 14)),
        ],
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Wrap(
        spacing: 16,
        runSpacing: 8,
        alignment: WrapAlignment.center,
        children: [
          legendItem(Colors.green, 'Free'),
          legendItem(Colors.red, 'Occupied'),
          legendItem(Colors.orange, 'Cleaning'),
          legendItem(Colors.grey, 'Maintenance'),
          legendItem(Color.fromARGB(255, 171, 113, 181), 'Awaiting Test'),
        ],
      ),
    );
  }

  // MAIN BUILD
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<userProfile>(
      stream: userService().watchProfile(),
      builder: (context, userSnap) {
        if (!userSnap.hasData) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = userSnap.data!;

        return StreamBuilder<List<Ward>>(
          stream: _fs.watchWards(),
          builder: (context, wardsSnap) {
            if (!wardsSnap.hasData) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final wards = wardsSnap.data!;

            return Scaffold(
              appBar: AppBar(
                title: Text(
                  selectedWardId == null
                      ? 'BedBoard Live — Overview'
                      : 'Ward Details',
                ),

                //BACK BUTTON (only on ward screen)
                leading: selectedWardId != null
                    ? IconButton(
                        icon: const Icon(Icons.arrow_back),
                        //label: const Text('Back to Overview'),
                        onPressed: () {
                          setState(() {
                            selectedWardId = null;
                          });
                        },
                      )
                    : null,

                //TOP-RIGHT LOGOUT (ONLY on overview)
                actions: [
                  if (selectedWardId == null)
                    Padding(
                      padding: const EdgeInsets.only(right: 16),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () async {
                              await FirebaseAuth.instance.signOut();
                            },
                            icon: const Icon(Icons.logout, color: Colors.blue),
                            label: const Text(
                              'Logout',
                              style: TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),

                          // ROLE + POSITION DISPLAY
                          Text(
                            '${user.role.toUpperCase()} • ${user.position}',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              body: selectedWardId == null
                  ? _buildOverviewScreen(wards)
                  : StreamBuilder<List<Bed>>(
                      stream: _fs.watchBedsForWard(selectedWardId!),
                      builder: (context, bedsSnap) {
                        if (!bedsSnap.hasData) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }

                        final selectedWard = wards.firstWhere(
                          (w) => w.id == selectedWardId,
                        );

                        final beds = bedsSnap.data!;

                        return _buildWardDetailScreen(
                          selectedWard,
                          user,
                          beds,
                          wards,
                        );
                      },
                    ),
            );
          },
        );
      },
    );
  }

  // ---------- OVERVIEW SCREEN ----------

  /*Widget _buildOverviewScreen(List<Ward> wards) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildStatusList(),
        const SizedBox(height:12),
        //const Divider(),
        // ================= LEFT: PIE CHARTS =================
        Expanded(
          flex: 3,
          child: ListView(
            children: wards.map((ward) {
              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        ward.wardname,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),

                      SizedBox(
                        height: 200,
                        child: GestureDetector(
                          onTap: () {
                            setState(() {
                              selectedWardId = ward.id;
                            });
                          },
                          child: _buildWardPieChart(ward),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),

        const SizedBox(width: 16),

        // RIGHT: WARD LIST
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Wards',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),

              Expanded(
                child: ListView(
                  children: wards.map((ward) {
                    return Card(
                      child: ListTile(
                        title: Text(ward.wardname),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          setState(() {
                            selectedWardId = ward.id;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}*/


Widget _buildOverviewScreen(List<Ward> wards) {
  return Padding(
    padding: const EdgeInsets.all(12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        // STATUS LEGEND
        _buildStatusList(),

        const SizedBox(height: 16),

        // SPLIT SCREEN (LEFT + RIGHT)
        Expanded(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // LEFT: CHARTS =================
              Expanded(
                flex: 3,
                child: GridView.builder(
                  itemCount: wards.length,
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 20,
                    mainAxisSpacing: 20,
                    childAspectRatio: 1.05,
                  ),
                  itemBuilder: (context, index) {
                    final ward = wards[index];

                    return MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            selectedWardId = ward.id;
                          });
                        },
                        child: Card(
                          elevation: 8,
                          color: Colors.blue.shade50,
                          //color: const Color(0xFFEAF4FB),
                          shadowColor: Colors.black26,
                          shape: RoundedRectangleBorder
                          (
                            borderRadius: BorderRadius.circular(20),
                              side: BorderSide(
                                color: Colors.blue.shade100,
                                width: 1.2,
                              ),
                          ),
                          
    
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ward.wardname,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 18),

                                Expanded(
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      _buildWardPieChart(ward),
                                      Positioned(
                                        bottom: 4,
                                        child: Text(
                                          'Click to view details',
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: Colors.grey.shade600,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(width: 20),

              // RIGHT: WARD LIST
              SizedBox(
                width: 260,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Wards',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: wards.map((ward) {
                          return Card(
                            //color: Colors.blue.shade50,
                            //border: Border.all(color: Colors.blue.shade100),
                            
                              elevation: 2,
                              color: Colors.blue.shade50,
                              shadowColor: Colors.black12,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                                side: BorderSide(
                                  color: Colors.blue.shade100,
                                  width: 1,
                                ),
                              ),
  
                            child: ListTile(
                              
                              title: Text(ward.wardname),
                              trailing:
                                  const Icon(Icons.chevron_right),
                              onTap: () {
                                setState(() {
                                  selectedWardId = ward.id;
                                });
                              },
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

 Widget _buildWardPieChart(Ward ward) {
  return StreamBuilder<List<Bed>>(
    stream: _fs.watchBedsForWard(ward.id),
    builder: (context, snapshot) {
      if (!snapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }

      final beds = snapshot.data!;

      final free =
          beds.where((b) => b.status == BedStatus.free).length;
      final occupied =
          beds.where((b) => b.status == BedStatus.occupied).length;
      final cleaning =
          beds.where((b) => b.status == BedStatus.cleaning).length;
      final maintenance =
          beds.where((b) => b.status == BedStatus.maintenance).length;
      final awaitingTest =
          beds.where((b) => b.status == BedStatus.awaiting_test).length;

      final total = beds.isEmpty ? 1 : beds.length;

      return LayoutBuilder(
        builder: (context, constraints) {
          final size = constraints.maxWidth;

          // Clamp max size so charts don’t become huge
          
          final effectiveSize = size.clamp(0.0, 350.0);

          final sectionRadius = effectiveSize * 0.30;
          final centerRadius = effectiveSize * 0.22;

          return Stack(
            alignment: Alignment.center,
            children: [
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: centerRadius,
                  borderData: FlBorderData(show: false),
                  sections: [
                    _doughnutSection(
                        free, total, Colors.green, sectionRadius),
                    _doughnutSection(
                        occupied, total, Colors.red, sectionRadius),
                    _doughnutSection(
                        cleaning, total, Colors.orange, sectionRadius),
                    _doughnutSection(
                        maintenance, total, Colors.grey, sectionRadius),
                    _doughnutSection(
                        awaitingTest,
                        total,
                        const Color.fromARGB(255, 171, 113, 181),
                        sectionRadius),
                  ],
                ),
              ),

              // Center text
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "$total",
                    style: TextStyle(
                      fontSize: size * 0.12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "Total Beds",
                    style: TextStyle(
                      fontSize: size * 0.03,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      );
    },
  );
}

  PieChartSectionData _doughnutSection(
    int value,
    int total,
    Color color,
    double radius,
) {
  if (value == 0) {
    return PieChartSectionData(
      value: 0,
      color: Colors.transparent,
      radius: radius,
    );
  }

  final percentage =
      ((value / total) * 100).toStringAsFixed(0);

  return PieChartSectionData(
    value: value.toDouble(),
    title: "$percentage%",
    color: color,
    radius: radius,
    titleStyle: const TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  );
}
  

  Widget _buildWardToolbar(Ward ward, List<Bed> beds, List<Ward> wards) {
    Widget actionButton(IconData icon, String label, VoidCallback onTap) {
      return Expanded(
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            height: 70,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: Colors.blue.shade50,
              border: Border.all(color: Colors.blue.shade100),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: Colors.blue.shade700, size: 22),
                const SizedBox(height: 6),
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Card(
      elevation: 2,
     
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            actionButton(Icons.accessible, 'Book Porter', () {
              showPorterDialog(context, ward, beds, wards, _fs);
            }),
            const SizedBox(width: 12),
            actionButton(Icons.cleaning_services, 'Book Deep-Clean', () async {
              final beds = await _fs.watchBedsForWard(ward.id).first;

              showDeepCleanDialog(context, ward, beds, _fs);
            }),
            const SizedBox(width: 12),
            actionButton(Icons.build, 'Report Estates', () async {
              final beds = await _fs.watchBedsForWard(ward.id).first;

              showEstatesDialog(context, ward, beds, _fs);
            }),
            const SizedBox(width: 12),
            actionButton(Icons.home, 'Discharge', () async {
              final beds = await _fs.watchBedsForWard(ward.id).first;

              showDischargeDialog(context, ward, beds, _fs);
            }),
          ],
        ),
      ),
    );
  }

  // WARD DETAIL SCREEN

  Widget _buildWardDetailScreen(
    Ward ward,
    userProfile user,
    List<Bed> beds,
    List<Ward> wards,
  ) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            ward.wardname,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Capacity: ${ward.WardCapacity}',
            style: const TextStyle(fontSize: 13),
          ),
          const SizedBox(height: 16),
          _buildWardToolbar(ward, beds, wards),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
              children:[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  
                  decoration: BoxDecoration(
                    
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.blue.shade50,
                  border: Border.all(color: Colors.blue.shade100),
            
                  ),
                  child: DropdownButton<BedStatus?>(
                    value: selectedFilter,
                    underline: const SizedBox(),
                    icon: const Icon(Icons.filter_list, size: 18),
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                    items: [
                      const DropdownMenuItem<BedStatus?>(
                        value: null,
                        child: Text("View All    "),
                      ),
                      ...BedStatus.values.map(
                        (status) => DropdownMenuItem<BedStatus?>(
                          value: status,
                          child: Text(status.name.toUpperCase()),
                        ),
                      )
                    ],
                    onChanged: (value) {
                      setState(() {
                        selectedFilter = value;
                      });
                    },
                    selectedItemBuilder: (context) {
                      return [
                        const Text("Filter Beds    "),
                        ...BedStatus.values.map(
                          (status) => const Text("Filter Beds    "),
                        ),
                      ];
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

          Expanded(
            child: StreamBuilder<List<Bed>>(
              stream: _fs.watchBedsForWard(ward.id),
              builder: (context, bedsSnap) {
                if (!bedsSnap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final allBeds = bedsSnap.data!;

                final beds = selectedFilter == null
                    ? allBeds
                    : allBeds.where((b) => b.status == selectedFilter).toList();

                return SingleChildScrollView(
                child: Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: beds.map((b) {
                    final bool allowEdit =
                        user.role == 'admin' ||
                        (user.role == 'clinical' &&
                            (user.position == 'nurse' ||
                                user.position == 'sister'));

                    return GestureDetector(
                      onTap: allowEdit
                          ? () => _showBedActions(context, b)
                          : () {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Read-only access: editing not permitted',
                                  ),
                                ),
                              );
                            },
                      child: SizedBox(
                        width: 180,
                        height: 190, // FIXED HEIGHT (important)
                        child: Card(
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Bed Code
                                Text(
                                  b.code,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                // Status
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: _statusColor(
                                      b.status,
                                    ).withOpacity(0.15),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    b.status.name.toUpperCase(),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: _statusColor(b.status),
                                    ),
                                  ),
                                ),

                                // Patient ID (reserve space always)
                                SizedBox(
                                  height: 18,
                                  child: Text(
                                    (b.status == BedStatus.occupied ||
                                                b.status ==
                                                    BedStatus.awaiting_test) &&
                                            b.hospitalNumber != null
                                        ? 'Patient: ${b.hospitalNumber}'
                                        : '',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ),

                                // Updated By (reserve space always)
                                SizedBox(
                                  height: 16,
                                  child: Text(
                                    b.updatedBy ?? '',
                                    style: const TextStyle(fontSize: 11),
                                  ),
                                ),

                                // Timestamp (formatted)
                                SizedBox(
                                  height: 16,
                                  child: Text(
                                    b.updatedAt != null
                                        ? '${b.updatedAt!.day}/${b.updatedAt!.month}/${b.updatedAt!.year} '
                                              '${b.updatedAt!.hour}:${b.updatedAt!.minute.toString().padLeft(2, '0')}'
                                        : '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                )
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showBedActions(BuildContext context, Bed bed) {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Wrap(
          children: [
            // OCCUPIED
            ListTile(
              title: const Text('Mark as Occupied'),
              onTap: () async {
                Navigator.pop(context);

                //if the card is purple(awaiting_test) should not ask the hospitalNuber
                if (bed.status == BedStatus.awaiting_test &&
                    bed.hospitalNumber != null) {
                  await _fs.updateBedStatus(
                    bedId: bed.id,
                    status: BedStatus.occupied,
                    hospitalNumber: bed.hospitalNumber,
                  );
                } else {
                  _showHospitalNumberDialog(context, bed);
                }
              },
            ),

            // CLEANING
            ListTile(
              title: const Text('Mark as Cleaning'),
              onTap: () async {
                Navigator.pop(context);

                await _fs.updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.cleaning,
                  hospitalNumber: null,
                );
              },
            ),

            // FREE
            ListTile(
              title: const Text('Mark as Free'),
              onTap: () async {
                Navigator.pop(context);

                await _fs.updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.free,
                  hospitalNumber: null,
                );
              },
            ),

            // MAINTENANCE
            ListTile(
              title: const Text('Mark as Maintenance'),
              onTap: () async {
                Navigator.pop(context);

                await _fs.updateBedStatus(
                  bedId: bed.id,
                  status: BedStatus.maintenance,
                  hospitalNumber: null,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showHospitalNumberDialog(BuildContext context, Bed bed) {
    final TextEditingController controller = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        String? errorText;
        //bool isLoading = false;

        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Enter 8-digit Hospital Number'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    keyboardType: TextInputType.number,
                    maxLength: 8,
                    decoration: InputDecoration(
                      hintText: 'e.g. 12345678',
                      errorText: errorText,
                      border: const OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    final input = controller.text.trim();

                    if (!RegExp(r'^\d{8}$').hasMatch(input)) {
                      setState(() {
                        errorText = 'Hospital number must be exactly 8 digits';
                      });
                      controller.clear();
                      return;
                    }

                    try {
                      setState(() {
                        //isLoading = true;
                        errorText = null;
                      });

                      await _fs.updateBedStatus(
                        bedId: bed.id,
                        status: BedStatus.occupied,
                        hospitalNumber: input,
                      );

                      Navigator.pop(context);
                    } catch (e) {
                      //  DUPLICATE OR OTHER FIRESTORE ERROR
                      setState(() {
                        //isLoading = false;
                        errorText = e.toString().replaceAll('Exception: ', '');
                        controller.clear();
                      });
                    }
                  },
                  child: const Text('Confirm'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
