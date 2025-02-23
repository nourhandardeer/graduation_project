import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String _fullName = "Loading...";
  String _profileImageUrl = "images/user.png"; // Default image
  String _age = "Unknown";
  String _illnesses = "No illnesses specified";
  String? _linkedPatientName; // Stores the linked patient's name
  String? _userId; // Stores the logged-in user's ID

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
  }

  Future<void> _fetchUserProfile() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (userDoc.exists) {
        final data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _userId = user.uid;
          _fullName = "${data['firstName']} ${data['lastName']}";
          _profileImageUrl = data['profileImage'] ?? "images/user.png";
          _age = data['age'] ?? "Unknown";
          _illnesses = data['illnesses'] ?? "No illnesses specified";
        });
        _checkIfEmergencyContact(user.email!);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    }
  }

  Future<void> _checkIfEmergencyContact(String userEmail) async {
    try {
      QuerySnapshot usersSnapshot =
          await FirebaseFirestore.instance.collection('users').get();

      for (var doc in usersSnapshot.docs) {
        String userId = doc.id;

        QuerySnapshot emergencyContactsSnapshot = await FirebaseFirestore
            .instance
            .collection('users')
            .doc(userId)
            .collection('emergencyContacts')
            .get();

        for (var contactDoc in emergencyContactsSnapshot.docs) {
          var contactData = contactDoc.data() as Map<String, dynamic>;

          if (contactData['mail'] == userEmail) {
            setState(() {
              _linkedPatientName = "${doc['firstName']} ${doc['lastName']}";
            });
            return;
          }
        }
      }
    } catch (e) {
      print("Error checking emergency contact status: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profile'),
        centerTitle: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: _profileImageUrl.startsWith('http')
                    ? NetworkImage(_profileImageUrl)
                    : AssetImage("images/user.png"),
                backgroundColor: Colors.transparent,
              ),
              SizedBox(height: 16),
              Text(
                _fullName,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                'Age: $_age | $_illnesses',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              SizedBox(height: 16),
              if (_linkedPatientName != null)
                Container(
                  padding: EdgeInsets.all(12),
                  margin: EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    "You are an emergency contact for **$_linkedPatientName**.",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue[900],
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              Text(
                'Emergency Contacts',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Live updates for emergency contacts
              _userId == null
                  ? CircularProgressIndicator()
                  : Expanded(
                      child: StreamBuilder<QuerySnapshot>(
                        stream: FirebaseFirestore.instance
                            .collection('users')
                            .doc(_userId)
                            .collection('emergencyContacts')
                            .snapshots(),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState ==
                              ConnectionState.waiting) {
                            return Center(child: CircularProgressIndicator());
                          }
                          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                            return Text("No emergency contacts available.");
                          }

                          var contacts = snapshot.data!.docs.map((doc) {
                            return doc.data() as Map<String, dynamic>;
                          }).toList();

                          return ListView.builder(
                            itemCount: contacts.length,
                            itemBuilder: (context, index) {
                              var contact = contacts[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: ListTile(
                                  leading: Icon(Icons.phone, color: Colors.red),
                                  title: Text(
                                    contact["name"],
                                    style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  subtitle: Text(
                                      '${contact["relation"]} - ${contact["phone"]}'),
                                  trailing: IconButton(
                                    icon: Icon(Icons.call, color: Colors.green),
                                    onPressed: () {
                                      // Add phone call functionality here
                                    },
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      ),
                    ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // SOS Alert Logic
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 32),
                ),
                child: Text(
                  'Emergency Alert',
                  style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
