import 'package:admin_panel/Teacher/Certificate_Screen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TeachersScreen extends StatefulWidget {
  @override
  _TeachersScreenState createState() => _TeachersScreenState();
}

class _TeachersScreenState extends State<TeachersScreen> {
  List<DataRow> teacherRows = [];

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  void fetchTeachers() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("teacher");
    DataSnapshot snapshot = await ref.get();

    List<DataRow> tempRows = [];
    if (snapshot.exists) {
      snapshot.children.forEach((teacherSnapshot) {
        // Accessing each field as a string
        String teacherId = teacherSnapshot.key ?? 'N/A';
        String name = teacherSnapshot.child('name').value as String? ?? 'N/A';
        String email = teacherSnapshot.child('email').value as String? ?? 'N/A';
        String education =
            teacherSnapshot.child('education').value as String? ?? 'N/A';
        String city = teacherSnapshot.child('city').value as String? ?? 'N/A';
        String stripeId =
            teacherSnapshot.child('stripeId').value as String? ?? 'N/A';
        String certificateUrl =
            teacherSnapshot.child('certificateUrl').value as String? ?? 'N/A';
        String profileImage =
            teacherSnapshot.child('profile').value as String? ?? 'N/A';

        // Default profile image if not available
        String defaultProfileImage = 'https://example.com/default-profile.jpg';

        // If no profile image, use the default image
        String imageToDisplay =
            profileImage.isEmpty ? defaultProfileImage : profileImage;

        // Debugging: Print the fetched data for each teacher
        print(
            "Teacher ID: $teacherId, Name: $name, Email: $email, Profile Image: $imageToDisplay");

        // Add data row for this teacher with profile image
        tempRows.add(
          DataRow(cells: [
            DataCell(Text(name)),
            DataCell(Text(email)),
            DataCell(Text(education)),
            DataCell(Text(city)),
            DataCell(Text(certificateUrl.isNotEmpty ? 'Uploaded' : 'N/A')),
            DataCell(Text(stripeId)),
            DataCell(
              CircleAvatar(
                backgroundImage: NetworkImage(imageToDisplay),
                radius: 20, // Adjust size of the image
              ),
            ),
            DataCell(ElevatedButton(
              onPressed: () => removeTeacher(teacherId),
              child: Text("Remove"),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            )),
            DataCell(ElevatedButton(
              onPressed: () => viewCertificate(teacherId),
              child: Text("View Certificate"),
            )),
          ]),
        );
      });

      setState(() {
        teacherRows = tempRows;
      });
    } else {
      print("No teachers data available");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("No teachers data found")),
      );
    }
  }

  void removeTeacher(String teacherId) async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("teacher/$teacherId");
    await ref.remove();
    fetchTeachers();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Teacher Removed")),
    );
  }

  void viewCertificate(String teacherId) async {
    DatabaseReference ref =
        FirebaseDatabase.instance.ref("teacher/$teacherId/certificateUrl");
    DataSnapshot snapshot = await ref.get();

    if (snapshot.exists) {
      String certificateUrl = snapshot.value as String;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) =>
              CertificateScreen(certificateUrl: certificateUrl),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Certificate not found")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Admin Panel")),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Education')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Certificate')),
              DataColumn(label: Text('Stripe ID')),
              DataColumn(label: Text('Profile')),
              DataColumn(label: Text('Remove')),
              DataColumn(label: Text('View Certificate')),
            ],
            rows: teacherRows,
          ),
        ),
      ),
    );
  }
}
