import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_management/data/models/attandance_model.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import 'package:attendance_management/presentation/blocs/attandance_event.dart';
import 'package:attendance_management/core/utils/attandance_utils.dart';

class AddEmployee extends StatefulWidget {
  const AddEmployee({super.key});

  @override
  _AddEmployeeState createState() => _AddEmployeeState();
}

class _AddEmployeeState extends State<AddEmployee> {
  final _formKey = GlobalKey<FormState>();

  DateTime? _selectedDate;
  TimeOfDay? _checkInTime;
  TimeOfDay? _checkOutTime;
  final TextEditingController _nameController = TextEditingController();


  Future<void> _pickDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }


  Future<TimeOfDay?> _pickTime(TimeOfDay? initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime ?? TimeOfDay.now(),
    );
  }


  String _calculateOvertime() {
    if (_checkInTime == null || _checkOutTime == null) return '-';
    Duration overtime = AttendanceUtils.calculateOvertime(_checkInTime!, _checkOutTime!);
     String overtimeString = "${overtime.inHours}h ${overtime.inMinutes % 60}m";
     return overtimeString;
  }


  void _submitData() {
    if (_formKey.currentState!.validate() &&
        _selectedDate != null &&
        _checkInTime != null &&
        _checkOutTime != null) {
      final formattedDate = "${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}";
      final checkIn = _checkInTime!.format(context);
      final checkOut = _checkOutTime!.format(context);
      final overtime = _calculateOvertime();

      final newEntry = Attendance(
        date: formattedDate,
        employeeName: _nameController.text,
        checkIn: checkIn,
        checkOut: checkOut,
        overtime: overtime,
        status: 'Present',
        rowIndex: 0,
      );

      context.read<AttendanceBloc>().add(AddAttendance(newEntry));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Add Employee")),
      body: BlocListener<AttendanceBloc, AttendanceState>(
        listener: (context, state) {
          if (state is AttendanceAdded) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Employee added successfully!")),
            );
            Navigator.pop(context); // Close screen on success
          } else if (state is AttendanceError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                // Employee Name Input
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(labelText: "Employee Name"),
                  validator: (value) => value!.isEmpty ? "Enter name" : null,
                ),

                SizedBox(height: 10),

                // Date Picker
                ListTile(
                  title: Text(_selectedDate == null
                      ? "Select Date"
                      : "Date: ${_selectedDate!.toLocal()}".split(' ')[0]),
                  leading: Icon(Icons.calendar_today),
                  onTap: _pickDate,
                ),


                ListTile(
                  title: Text(_checkInTime == null
                      ? "Select Check-In Time"
                      : "Check-In: ${_checkInTime!.format(context)}"),
                  leading: Icon(Icons.access_time),
                  onTap: () async {
                    TimeOfDay? picked = await _pickTime(_checkInTime);
                    if (picked != null) setState(() => _checkInTime = picked);
                  },
                ),


                ListTile(
                  title: Text(_checkOutTime == null
                      ? "Select Check-Out Time"
                      : "Check-Out: ${_checkOutTime!.format(context)}"),
                  leading: Icon(Icons.access_time),
                  onTap: () async {
                    TimeOfDay? picked = await _pickTime(_checkOutTime);
                    if (picked != null) setState(() => _checkOutTime = picked);
                  },
                ),

                SizedBox(height: 20),


                ElevatedButton(
                  onPressed: _submitData,
                  child: Text("Add Employee"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
