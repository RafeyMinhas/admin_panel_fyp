import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  List<DataRow> studentRows = [];

  @override
  void initState() {
    super.initState();
    fetchStudents();
  }

  // Function to fetch students from Firebase
  void fetchStudents() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("student");
    DataSnapshot snapshot = await ref.get();

    List<DataRow> tempRows = [];
    if (snapshot.exists) {
      snapshot.children.forEach((studentSnapshot) {
        Map<dynamic, dynamic> student = studentSnapshot.value as Map;
        tempRows.add(
          DataRow(cells: [
            DataCell(CircleAvatar(
              backgroundImage: (student['profile'] != null &&
                      student['profile'].isNotEmpty)
                  ? NetworkImage(student['profile']) as ImageProvider<Object>
                  : const AssetImage('assets/default_profile.png')
                      as ImageProvider<Object>,
            )),
            DataCell(Text(student['name'] ?? '')),
            DataCell(Text(student['email'] ?? '')),
          ]),
        );
      });

      setState(() {
        studentRows = tempRows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            // ignore: prefer_const_literals_to_create_immutables
            columns: [
              const DataColumn(label: Text('Profile')),
              const DataColumn(label: Text('Name')),
              const DataColumn(label: Text('Email')),
            ],
            rows: studentRows,
          ),
        ),
      ),
    );
  }
}
