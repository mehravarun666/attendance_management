import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:attendance_management/presentation/blocs/attandance_event.dart';
import 'package:attendance_management/presentation/screens/add_employee.dart';

class ManageScreen extends StatefulWidget {
  const ManageScreen({super.key});

  @override
  _ManageScreenState createState() => _ManageScreenState();
}

class _ManageScreenState extends State<ManageScreen> {
  Set<String> _removedEmployees = {}; // Stores removed employees

  @override
  void initState() {
    super.initState();
    _loadRemovedEmployees();
  }

  /// Loads removed employees from SharedPreferences
  Future<void> _loadRemovedEmployees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? removedList = prefs.getStringList("removedEmployees");
    if (removedList != null) {
      setState(() {
        _removedEmployees = removedList.toSet();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            final employeeNames = state.attendanceList
                .map((e) => e.employeeName)
                .toSet().skip(1)
                .where((name) => !_removedEmployees.contains(name)) // Exclude removed employees
                .toList();

            if (employeeNames.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(20),
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
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showDeleteConfirmation(context, employeeNames[index]),
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
          return const Center(child: CircularProgressIndicator());
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddEmployee()),
          );
        },
        tooltip: "Add New Employee Data",
        child: const Icon(Icons.add),
      ),
    );
  }

  /// Shows confirmation dialog for removing an employee
  void _showDeleteConfirmation(BuildContext context, String employeeName) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Remove Employee"),
          content: Text("Are you sure you want to remove $employeeName permanently?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
            TextButton(
              onPressed: () async {
                context.read<AttendanceBloc>().add(RemoveEmployeeEvent(employeeName)); // Remove via BLoC
                setState(() {
                  _removedEmployees.add(employeeName);
                });
                await _saveRemovedEmployees(); // Persist changes
                Navigator.pop(context);
              },
              child: const Text("Remove", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  /// Saves removed employees to SharedPreferences
  Future<void> _saveRemovedEmployees() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("removedEmployees", _removedEmployees.toList());
  }
}
