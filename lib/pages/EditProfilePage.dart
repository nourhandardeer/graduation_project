import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class EditProfilePage extends StatefulWidget {
  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  String _profileImageUrl = "images/user.png";


  // Controllers for user input
  TextEditingController _firstNameController = TextEditingController();
  TextEditingController _lastNameController = TextEditingController();
  TextEditingController _phoneController = TextEditingController();
  TextEditingController _ageController = TextEditingController();
  TextEditingController _illnesses = TextEditingController();


  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Load existing user data
  void _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>;
        setState(() {
          _profileImageUrl = data['profileImage']?.isNotEmpty == true ? data['profileImage'] : "images/user.png";
          _firstNameController.text = data['firstName'] ?? "";
          _lastNameController.text = data['lastName'] ?? "";
          _phoneController.text = data['phone'] ?? "";
          _ageController.text = data['age'] ?? "Unknown";
          _illnesses.text = data['illnesses'] ?? "No illnesses specified";
        });
      }
    }
  }

  // Update user details in Firestore (UID remains unchanged)
  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      User? user = _auth.currentUser;
      if (user != null) {
        await _firestore.collection('users').doc(user.uid).update({
          'profileImage': _profileImageUrl,
          'firstName': _firstNameController.text,
          'lastName': _lastNameController.text,
          'phone': _phoneController.text,
          'age': _ageController.text , // Convert age to integer
          'illnesses': _illnesses.text,
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Profile updated successfully!")),
        );
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Edit Profile")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Center(
            child: Column(
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundImage: _profileImageUrl.startsWith('http') ? NetworkImage(_profileImageUrl) : AssetImage("images/user.png") as ImageProvider,
                  backgroundColor: Colors.transparent,
                ),
                TextFormField(
                  controller: _firstNameController,
                  decoration: InputDecoration(labelText: "First Name"),
                  validator: (value) => value!.isEmpty ? "Enter your first name" : null,
                ),
                TextFormField(
                  controller: _lastNameController,
                  decoration: InputDecoration(labelText: "Last Name"),
                  validator: (value) => value!.isEmpty ? "Enter your last name" : null,
                ),
                TextFormField(
                  controller: _phoneController,
                  decoration: InputDecoration(labelText: "Phone"),
                  validator: (value) => value!.isEmpty ? "Enter your phone number" : null,
                ),
                TextFormField(
                  controller: _ageController,
                  decoration: InputDecoration(labelText: "Age"),
                //  validator: (value) => value!.isEmpty ? "Enter your age" : null,
                ),
                TextFormField(
                  controller: _illnesses,
                  decoration: InputDecoration(labelText: "Illnesses"),
                  keyboardType: TextInputType.number,
                  //  validator: (value) => value!.isEmpty ? "Enter your illnesses" : null,
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: Text("Save Changes"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
