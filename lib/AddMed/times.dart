import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'date.dart';

class TimesPage extends StatefulWidget {
  final String medicationName;
  final String selectedUnit;
  final String documentId; // Document ID for the existing document

  const TimesPage({
    Key? key,
    required this.medicationName,
    required this.selectedUnit,
    required this.documentId,
  }) : super(key: key);

  @override
  _TimesPageState createState() => _TimesPageState();
}

class _TimesPageState extends State<TimesPage> {
  String? selectedFrequency;
  final Map<String, String> customDetails = {};

  final List<String> commonFrequencies = ["Once a day", "Twice a day"];
  final List<String> additionalFrequencies = [
    "Specific days of the week",
    "Every X days",
    "Every X weeks",
    "Every X months",
    "On demand"
  ];
  bool showMoreOptions = false;

  /// Prompts the user to enter custom details for a given frequency.
  void _askForDetails(String frequency) {
    final TextEditingController controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Enter details for $frequency"),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(hintText: "Enter details"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  if (frequency.isNotEmpty) {
                    customDetails[frequency] = controller.text;
                    selectedFrequency = "$frequency - ${controller.text}";
                  }
                });
                Navigator.pop(context);
              },
              child: const Text("OK"),
            ),
          ],
        );
      },
    );
  }

  /// Updates the existing document with the selected frequency data and navigates to DatePage.
  Future<void> saveFrequency() async {
  if (selectedFrequency != null) {
    try {
      await FirebaseFirestore.instance
          .collection('meds')
          .doc(widget.documentId)
          .update({
        'frequency': selectedFrequency,
        'timestamp': FieldValue.serverTimestamp(),
      });

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DatePage(
              medicationName: widget.medicationName,
              selectedUnit: widget.selectedUnit,
              selectedFrequency: selectedFrequency!,
              documentId: widget.documentId, // تمرير نفس الـ documentId
            ),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving frequency: $e'), backgroundColor: Colors.red),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please select a frequency before proceeding'),
        backgroundColor: Colors.red,
      ),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: Colors.white),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "How often do you take this med?",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  // Display common frequency options.
                  ...commonFrequencies.map(
                    (frequency) => RadioListTile<String>(
                      title: Text(frequency),
                      value: frequency,
                      groupValue: selectedFrequency,
                      onChanged: (value) =>
                          setState(() => selectedFrequency = value),
                    ),
                  ),
                  // Button to toggle additional frequency options.
                  ListTile(
                    title: const Text("I need more options",
                        style: TextStyle(color: Colors.blue)),
                    trailing: Icon(
                      showMoreOptions
                          ? Icons.expand_less
                          : Icons.expand_more,
                      color: Colors.blue,
                    ),
                    onTap: () =>
                        setState(() => showMoreOptions = !showMoreOptions),
                  ),
                  // Display additional frequency options when expanded.
                  if (showMoreOptions)
                    ...additionalFrequencies.map(
                      (frequency) => RadioListTile<String>(
                        title: Text(customDetails[frequency] ?? frequency),
                        value: customDetails[frequency] ?? frequency,
                        groupValue: selectedFrequency,
                        onChanged: (value) {
                          if (value != null &&
                              additionalFrequencies.contains(value)) {
                            _askForDetails(value);
                          } else {
                            setState(() => selectedFrequency = value);
                          }
                        },
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: saveFrequency,
          child: const Text("Next"),
        ),
      ),
    );
  }
}
