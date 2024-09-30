import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class TeacherScreen extends StatefulWidget {
  @override
  _TeacherScreenState createState() => _TeacherScreenState();
}

class _TeacherScreenState extends State<TeacherScreen> {
  List<DataRow> teacherRows = [];

  @override
  void initState() {
    super.initState();
    fetchTeachers();
  }

  // Function to fetch teachers from Firebase
  void fetchTeachers() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("teacher");
    DataSnapshot snapshot = await ref.get();

    List<DataRow> tempRows = [];
    if (snapshot.exists) {
      snapshot.children.forEach((teacherSnapshot) {
        Map<dynamic, dynamic> teacher = teacherSnapshot.value as Map;

        // Checking if profile URL exists and is not empty
        String profileUrl = teacher['profile'] ?? '';
        bool hasProfilePic = profileUrl.isNotEmpty;

        tempRows.add(
          DataRow(cells: [
            DataCell(
              CircleAvatar(
                backgroundImage: hasProfilePic
                    ? NetworkImage(profileUrl) as ImageProvider<Object>
                    : const AssetImage(
                        'assets/default_profile.png'), // Default image
                onBackgroundImageError: (_, __) {
                  setState(() {
                    // Fallback to default profile picture on image loading error
                  });
                },
              ),
            ),
            DataCell(Text(teacher['name'] ?? '')),
            DataCell(Text(teacher['email'] ?? '')),
            DataCell(Text(teacher['education'] ?? '')),
            DataCell(Text(teacher['city'] ?? '')),
            DataCell(Text(teacher['phone'] ?? '')),
          ]),
        );
      });

      setState(() {
        teacherRows = tempRows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Teachers'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: const [
              DataColumn(label: Text('Profile')),
              DataColumn(label: Text('Name')),
              DataColumn(label: Text('Email')),
              DataColumn(label: Text('Education')),
              DataColumn(label: Text('City')),
              DataColumn(label: Text('Phone')),
            ],
            rows: teacherRows,
          ),
        ),
      ),
    );
  }
}
