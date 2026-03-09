
import 'package:flutter/material.dart';

void showUserGuide(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) {
      return Dialog(
        insetPadding: const EdgeInsets.all(24),
        child: Container(
          width: 700,
          height: 600,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [

              /// TITLE
              Row(
                children: [
                  const Icon(Icons.menu_book, color: Colors.blue, size: 28),
                  const SizedBox(width: 10),
                  const Text(
                    "BedBoard Live - User Guide",
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  )
                ],
              ),

              const Divider(),

              /// CONTENT
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// SECTION 1
                      const Text(
                        "1. System Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "BedBoard Live is a hospital bed management dashboard that provides real-time visibility of ward capacity and bed occupancy. Staff can monitor bed availability, allocate patients, and manage operational requests.",
                      ),

                      const SizedBox(height: 18),

                      /// SECTION 2
                      const Text(
                        "2. Dashboard Overview",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "The dashboard displays ward occupancy using pie charts. Each chart represents the status of beds in a ward.",
                      ),

                      const SizedBox(height: 8),

                      const Text("Bed Status Legend:"),
                      const SizedBox(height: 6),

                      _statusRow(Colors.green, "Free Bed"),
                      _statusRow(Colors.red, "Occupied Bed"),
                      _statusRow(Colors.orange, "Cleaning"),
                      _statusRow(Colors.grey, "Maintenance"),
                      _statusRow(Color.fromARGB(255, 171, 113, 181), "Awaiting Test"),

                      const SizedBox(height: 18),

                      /// SECTION 3
                      const Text(
                        "3. Viewing Ward Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Click on a ward chart or select a ward from the right-side list to open the ward detail view. The ward screen shows all beds in that ward.",
                      ),

                      const SizedBox(height: 18),

                      /// SECTION 4
                      const Text(
                        "4. Updating Bed Status",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Click on a bed card to open bed actions. Staff can update the bed status such as Occupied, Cleaning, Free, or Maintenance.",
                      ),

                      const SizedBox(height: 18),

                      /// SECTION 5
                     

                        const Text(
                          "5. Operational Tools",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 6),

                        const Text(
                          "The ward screen provides operational tools to support patient movement and hospital workflow.",
                        ),

                        const SizedBox(height: 16),

                        /// PORTER TRANSFER
                        const Text(
                          "Book Porter – Transfer Patient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        const Text("Steps:"),
                        const Text("1. Click 'Book Porter' on the ward toolbar."),
                        const Text("2. Select the patient from the occupied bed list."),
                        const Text("3. Choose mobility type (Wheelchair, Trolley, or Hospital Bed)."),
                        const Text("4. Select destination:"),
                        const Text("   • Another Ward – choose ward and available bed."),
                        const Text("   • Test/Scan – select the test type."),
                        const Text("5. Confirm the transfer request."),

                        const SizedBox(height: 10),

                        
                        /*ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.asset(
                              "assets/BookPorter.png",
                              height: 180,
                              fit: BoxFit.contain,
                            ),
                          ),*/

                          
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/BookPorter.png",
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),


                       

                        const SizedBox(height: 18),

                        /// DEEP CLEAN
                        const Text(
                          "Book Deep Clean",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        const Text("Steps:"),
                        const Text("1. Click 'Book Deep-Clean' from the ward toolbar."),
                        const Text("2. Select the bed that requires cleaning."),
                        const Text("3. Choose the clean type (Discharge, Amber Clean, or Fogging)."),
                        const Text("4. Submit the cleaning request."),

                        const SizedBox(height: 10),

                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/DeepClean.png",
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                        const SizedBox(height: 18),

                        /// ESTATES REPORT
                        const Text(
                          "Report Estates Issue",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        const Text("Steps:"),
                        const Text("1. Click 'Report Estates' on the ward toolbar."),
                        const Text("2. Select the bed where the issue occurred."),
                        const Text("3. Enter a description of the issue."),
                        const Text("4. Enter the name of the staff member reporting."),
                        const Text("5. Submit the request to generate a ticket number."),

                        const SizedBox(height: 10),

                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/EstatesReport.png",
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),


                        const SizedBox(height: 18),

                        /// DISCHARGE
                        const Text(
                          "Discharge Patient",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),

                        const SizedBox(height: 6),

                        const Text("Steps:"),
                        const Text("1. Click 'Discharge' from the ward toolbar."),
                        const Text("2. Select the occupied bed."),
                        const Text("3. Choose discharge type."),
                        const Text("4. Optionally add comments."),
                        const Text("5. Confirm discharge to free the bed."),

                        const SizedBox(height: 10),

                        Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.asset(
                                "assets/DischargePatient.png",
                                width: double.infinity,
                                height: 280,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),

                      /// SECTION 6
                      const Text(
                        "6. User Roles",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Different users have different permissions:",
                      ),

                      const SizedBox(height: 6),

                      const Text("Admin – Full access"),
                      const Text("Clinical Staff – Update bed status"),
                      const Text("Read-only Users – View dashboard only"),

                      const SizedBox(height: 18),

                      /// SECTION 7
                      const Text(
                        "7. Login Instructions",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      const Text(
                        "Users must log in using their registered email and password. New users may register but will initially have read-only access until permissions are assigned.",
                      ),

                      const SizedBox(height: 20),

                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

Widget _statusRow(Color color, String label) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 3),
    child: Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(width: 8),
        Text(label),
      ],
    ),
  );
}
