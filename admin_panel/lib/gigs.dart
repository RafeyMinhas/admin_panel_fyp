import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class GigScreen extends StatefulWidget {
  @override
  _GigScreenState createState() => _GigScreenState();
}

class _GigScreenState extends State<GigScreen> {
  List<DataRow> gigRows = [];

  @override
  void initState() {
    super.initState();
    fetchGigs();
  }

  // Fetch teacher's name based on the teacherId
  Future<String> getTeacherName(String teacherId) async {
    DatabaseReference teacherRef =
        FirebaseDatabase.instance.ref("teacher/$teacherId");
    DataSnapshot teacherSnapshot = await teacherRef.get();
    if (teacherSnapshot.exists) {
      Map<dynamic, dynamic> teacher = teacherSnapshot.value as Map;
      return teacher['name'] as String? ??
          'Unknown Teacher'; // Handle null safely
    } else {
      return 'Unknown Teacher';
    }
  }

  void fetchGigs() async {
    DatabaseReference ref = FirebaseDatabase.instance.ref("gigs");
    DataSnapshot snapshot = await ref.get();

    List<DataRow> tempRows = [];
    if (snapshot.exists) {
      for (DataSnapshot categorySnapshot in snapshot.children) {
        String category =
            categorySnapshot.key ?? 'Unknown Category'; // Handle null safely

        for (DataSnapshot gigSnapshot in categorySnapshot.children) {
          Map<dynamic, dynamic> gig = gigSnapshot.value as Map;
          String teacherId = gig['uid'] as String? ?? ''; // Handle null safely

          // Fetch the teacher's name asynchronously
          String teacherName = await getTeacherName(teacherId);

          tempRows.add(
            DataRow(cells: [
              DataCell(
                  Text(gig['title'] as String? ?? '')), // Handle null safely
              DataCell(Text(teacherName)),
              DataCell(Text(
                  '${gig['rate'] as int? ?? 0}')), // Handle null for numbers
              DataCell(Text(category)), // Display the category
              DataCell(Text(gig['description'] as String? ?? '')),
            ]),
          );
        }
      }

      setState(() {
        gigRows = tempRows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Gigs'),
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columns: [
              DataColumn(label: Text('Gig Title')),
              DataColumn(label: Text('Teacher')),
              DataColumn(label: Text('Rate')),
              DataColumn(label: Text('Category')),
              DataColumn(label: Text('Description')),
            ],
            rows: gigRows,
          ),
        ),
      ),
    );
  }
}
