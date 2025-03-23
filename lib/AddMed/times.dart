import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date.dart';
import 'refillrequest.dart';

class TimesPage extends StatefulWidget {
  final String medicationName;
  final String selectedUnit;
  final String documentId;
  final String startDate;

  const TimesPage({
    Key? key,
    required this.medicationName,
    required this.selectedUnit,
    required this.documentId,
    required this.startDate,
  }) : super(key: key);

  @override
  _TimesPageState createState() => _TimesPageState();
}

class _TimesPageState extends State<TimesPage> {
  String? selectedFrequency;
  bool showOtherOptions = false;


  final List<String> frequencyOptions = [
    "Once a day",
    "Twice a day",
    "3 times a day",
    "Every other day",
    "Once a week",
    "Only as needed",
    "Other",
  ];

  final List<String> otherOptions = [
    "Specific days of the week",
    "Every X days",
    "Every X weeks",
    "Every X months",
  ];

  Future<void> saveFrequency() async {
    if (selectedFrequency == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a frequency')),
      );
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('meds')
          .doc(widget.documentId)
          .update({
        'frequency': selectedFrequency,
        'isAsNeeded': selectedFrequency == "Only as needed",
        'timestamp': FieldValue.serverTimestamp(),
        'startDate':'Saturday',
      });

      if (mounted) {
        // Only as needed ➡ RefillRequest
        if (selectedFrequency == "Only as needed") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => RefillRequest(
                medicationName: widget.medicationName,
                selectedUnit: widget.selectedUnit,
                selectedFrequency: selectedFrequency!,
                reminderTime: "As Needed",
                documentId: widget.documentId,
                
              ),
            ),
          );
        }

        // Specific days or recurring ➡ DatePage
        else if (selectedFrequency == "Specific days of the week" ||
            selectedFrequency == "Every X days" ||
            selectedFrequency == "Every X weeks" ||
            selectedFrequency == "Every X months") {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DatePage(
                medicationName: widget.medicationName,
                selectedUnit: widget.selectedUnit,
                selectedFrequency: selectedFrequency!,
                documentId: widget.documentId,
              ),
            ),
          );
        }

        // باقي التكرارات ➡ DatePage
        else {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DatePage(
                medicationName: widget.medicationName,
                selectedUnit: widget.selectedUnit,
                selectedFrequency: selectedFrequency!,
                documentId: widget.documentId,
              ),
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving frequency: $e')),
      );
    }
  }

  // فتح قائمة Other Options
  void _toggleOtherOptions() {
    setState(() {
      showOtherOptions = !showOtherOptions;
      selectedFrequency = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text("Select Frequency", style: TextStyle(color: Colors.black)),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How often do you take this medication?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // خيارات التكرار الأساسية
                  ...frequencyOptions.map((frequency) {
                    return RadioListTile<String>(
                      title: Text(frequency),
                      value: frequency,
                      groupValue: selectedFrequency,
                      onChanged: (value) {
                        if (value == "Other") {
                          _toggleOtherOptions();
                        } else {
                          setState(() {
                            selectedFrequency = value;
                            showOtherOptions = false;
                          });
                        }
                      },
                    );
                  }).toList(),

                  // لو "Other" ظاهر
                  if (showOtherOptions) ...[
                    const Divider(),
                    const Text(
                      "Other Options",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    ...otherOptions.map((option) {
                      return ListTile(
                        title: Text(option),
                        trailing: selectedFrequency == option
                            ? const Icon(Icons.check_circle, color: Colors.blue)
                            : null,
                        onTap: () {
                          // لما يدوس على Every X ➡ يروح مباشرة على DatePage
                          if (option == "Every X days" ||
                              option == "Every X weeks" ||
                              option == "Every X months") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DatePage(
                                  medicationName: widget.medicationName,
                                  selectedUnit: widget.selectedUnit,
                                  selectedFrequency: option,
                                  documentId: widget.documentId,
                                ),
                              ),
                            );
                          }

                          // Specific days of the week ➡ يروح مباشرة على DatePage
                          else if (option == "Specific days of the week") {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DatePage(
                                  medicationName: widget.medicationName,
                                  selectedUnit: widget.selectedUnit,
                                  selectedFrequency: option,
                                  documentId: widget.documentId,
                                ),
                              ),
                            );
                          }

                          // اختيار بسيط ➡ حدده عادي
                          else {
                            setState(() {
                              selectedFrequency = option;
                              showOtherOptions = false;
                            });
                          }
                        },
                      );
                    }).toList(),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: selectedFrequency != null ? saveFrequency : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text(
            "Next",
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ),
    );
  }
}
