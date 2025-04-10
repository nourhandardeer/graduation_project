import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:graduation_project/NavigationBar/manage_page.dart';
import 'package:intl/intl.dart';
import 'package:graduation_project/home.dart';

import '../services/firestore_service.dart';

class AddAppointment extends StatefulWidget {
  const AddAppointment({super.key});

  @override
  State<AddAppointment> createState() => _AddAppointmentState();
}

class _AddAppointmentState extends State<AddAppointment> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  final TextEditingController doctorNameController = TextEditingController();
  final TextEditingController doctorPhoneController = TextEditingController();
  final TextEditingController specialtyController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController notesController = TextEditingController();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (pickedDate != null) {
      setState(() => selectedDate = pickedDate);
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (pickedTime != null) {
      setState(() => selectedTime = pickedTime);
    }
  }

  Future<void> _saveAppointment() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (selectedDate == null ||
        selectedTime == null ||
        doctorNameController.text.isEmpty ||
        doctorPhoneController.text.isEmpty ||
        specialtyController.text.isEmpty ||
        locationController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields')),
      );
      return;
    }
    String uid = user!.uid;

    try {
      // Fetch the current user's document
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection(
          'users').doc(uid).get();
      String? phoneNumber = userDoc['phone']; // Fetch user's phone number

      if (phoneNumber == null) {
        print("DEBUG: No phone number found for the current user.");
        return;
      }
      _firestoreService.saveData(
        collection: 'appointments',
        context: context,
        data: {
          'userId': FirebaseAuth.instance.currentUser?.uid,
          'doctorName': doctorNameController.text,
          'doctorPhone': doctorPhoneController.text,
          'specialty': specialtyController.text,
          'location': locationController.text,
          'notes': notesController.text,
          'appointmentDate': DateFormat('yyyy-MM-dd').format(selectedDate!),
          'appointmentTime': selectedTime!.format(context),
          'createdAt': FieldValue.serverTimestamp(),
          //'linkedUserIds': linkedUsers,

        },
      );
      Navigator.pop(context);
    }
    catch (e) {
      print("Error saving medication: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving data: $e'),
            backgroundColor: Colors.red),
      );
    }
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Appointment')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Doctor Name', doctorNameController),
              _buildTextField('Doctor Phone', doctorPhoneController),
              _buildTextField('Specialty', specialtyController),
              _buildTextField('Location', locationController),
              _buildTextField('Notes (Optional)', notesController),
              const Text('Date',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectDate(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedDate != null
                        ? DateFormat('EEE, dd MMM yyyy').format(selectedDate!)
                        : 'Select a date',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text('Time',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () => _selectTime(context),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    selectedTime != null
                        ? selectedTime!.format(context)
                        : 'Select a time',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _saveAppointment,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.blue,
                ),
                child: const Text('Save Appointment',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
