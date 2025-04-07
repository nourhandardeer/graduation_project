import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:graduation_project/AddMed/addmed.dart';
import 'package:graduation_project/AddMed/medication_details_page.dart';

import '../services/firestore_service.dart';

class MedicationsPage extends StatefulWidget {
  const MedicationsPage({super.key});

  @override
  State<MedicationsPage> createState() => _MedicationsPageState();
}

class _MedicationsPageState extends State<MedicationsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
  backgroundColor: Theme.of(context).scaffoldBackgroundColor, // ✅ Dynamic
      body: _buildMedicationsList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddMedicationPage()),
          );
        },
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

    Widget _buildMedicationsList() {
  final user = _auth.currentUser;
  if (user == null) {
    return const Center(
      child: Text(
        "Please log in to view medications.",
        style: TextStyle(color: Colors.black),
      ),
    );
  }

  return FutureBuilder<List<String>>(
    future:  _firestoreService.getEmergencyUserIds(user.uid),
    builder: (context, userSnapshot) {
      if (userSnapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }
      if (userSnapshot.hasError || !userSnapshot.hasData) {
        return const Center(
          child: Text("Error loading user data", style: TextStyle(color: Colors.red)),
        );
      }

      return FutureBuilder<QuerySnapshot>(
        future: _firestoreService.getMedications(userSnapshot.data!),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(
              child: Text("Error loading medications", style: TextStyle(color: Colors.red)),
            );
          }

          List<QueryDocumentSnapshot> medications = snapshot.data!.docs;

          if (medications.isEmpty) {
            return _buildEmptyState();
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: medications.length,
            itemBuilder: (context, index) {
              var med = medications[index];
              var medData = med.data() as Map<String, dynamic>;

              return Card(
                color: Colors.grey[200],
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: ListTile(
                  leading: const Icon(Icons.medical_services, color: Colors.blue),
                  title: Text(
                    medData["name"] ?? "Unknown Medication",
                    style: const TextStyle(color: Colors.black, fontSize: 18),
                  ),
                  subtitle: Text(
                    " ${medData['frequency'] ?? 'Specific Days ' }",
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            MedicationDetailsPage(medId: med.id),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      );
    },
  );
}



  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset('images/syringe.png', width: 150, height: 150),
          const SizedBox(height: 50),
          Text(
            "Add your meds to be reminded on time and\ntrack your health",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, color: Colors.grey[700]),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}
