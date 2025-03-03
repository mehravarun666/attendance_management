import 'package:attendance_management/core/utils/managescreen_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:attendance_management/presentation/screens/add_employee.dart';

class ManageScreen extends StatelessWidget {
  const ManageScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            final employeeNames = state.attendanceList
                .map((e) => e.employeeName)
                .toSet()
                .skip(1) // Ensure this logic is correct
                .toList();

            if (employeeNames.isEmpty) {
              return Center(child: Text("No employees available."));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Text("Employees List", style: TextStyle(fontSize: 20)),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: employeeNames.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        leading: CircleAvatar(child: Text(employeeNames[index][0])),
                        title: Text(employeeNames[index]),
                        trailing: IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: () => showDeleteConfirmation(context,);
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          } else if (state is AttendanceError) {
            return Center(child: Text("Error: ${state.message}"));
          }
          return Center(child: Text("No data available."));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEmployee()),
          );
        },
        tooltip: "Add New Employee Data",
        child: Icon(Icons.add),
      ),
    );
  }

  static void showDeleteConfirmation(BuildContext context, int rowIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this employee?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {

                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
