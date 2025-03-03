import 'package:attendance_management/data/models/attandance_model.dart';
import 'package:attendance_management/presentation/blocs/attandance_event.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceUtils {

  static void showEditDialog(BuildContext context, Attendance person) {
    TimeOfDay? checkInTime = _parseTime(person.checkIn);
    TimeOfDay? checkOutTime = _parseTime(person.checkOut);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text("Edit Attendance"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text("Employee: ${person.employeeName}"),
                  SizedBox(height: 10),

                  // **Check-In Time Picker**
                  ListTile(
                    title: Text(checkInTime == null
                        ? "Select Check-In Time"
                        : "Check-In: ${checkInTime?.format(context)}"),
                    leading: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await _pickTime(context, checkInTime!);
                      if (picked != null) {
                        setState(() {
                          checkInTime = picked;
                        });
                      }
                    },
                  ),

                  // **Check-Out Time Picker**
                  ListTile(
                    title: Text(checkOutTime == null
                        ? "Select Check-Out Time"
                        : "Check-Out: ${checkOutTime?.format(context)}"),
                    leading: Icon(Icons.access_time),
                    onTap: () async {
                      TimeOfDay? picked = await _pickTime(context, checkOutTime!);
                      if (picked != null) {
                        setState(() {
                          checkOutTime = picked;
                        });
                      }
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (checkInTime == null || checkOutTime == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("Please select valid times")),
                      );
                      return;
                    }

                    // **Calculate Overtime**
                    Duration overtime = calculateOvertime(checkInTime!, checkOutTime!);
                    String overtimeString = "${overtime.inHours}h ${overtime.inMinutes % 60}m";

                    Attendance updatedAttendance = person.copyWith(
                      checkIn: checkInTime!.format(context),
                      checkOut: checkOutTime!.format(context),
                      overtime: overtimeString,
                    );

                    context.read<AttendanceBloc>().add(UpdateAttendance(person.rowIndex, updatedAttendance));
                    Navigator.pop(context);
                  },
                  child: Text("Update"),
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// **Pick a Time (Helper Function)**
  static Future<TimeOfDay?> _pickTime(BuildContext context, TimeOfDay initialTime) async {
    return await showTimePicker(
      context: context,
      initialTime: initialTime,
    );
  }

  /// **Overtime Calculation**
  static Duration calculateOvertime(TimeOfDay checkIn, TimeOfDay checkOut) {
    int workMinutes = (checkOut.hour * 60 + checkOut.minute) - (checkIn.hour * 60 + checkIn.minute);
    int overtimeMinutes = (workMinutes > 540) ? (workMinutes - 540) : 0; // Assuming 9 hours is normal work time
    return Duration(minutes: overtimeMinutes);
  }

  /// **Time Parser (Handles Different Formats)**
  static TimeOfDay? _parseTime(String time) {
    try {
      time = time.trim().toUpperCase();
      final regex = RegExp(r'^(\d{1,2}):(\d{2})\s?(AM|PM)?$');
      final match = regex.firstMatch(time);

      if (match == null) return null;

      int hour = int.parse(match.group(1)!);
      int minute = int.parse(match.group(2)!);
      String? period = match.group(3);

      if (period != null) {
        if (period == "PM" && hour != 12) hour += 12;
        if (period == "AM" && hour == 12) hour = 0;
      }

      return TimeOfDay(hour: hour, minute: minute);
    } catch (_) {
      return null;
    }
  }

  /// **Delete Confirmation Dialog**
  static void showDeleteConfirmation(BuildContext context, int rowIndex) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Confirm Deletion"),
          content: Text("Are you sure you want to delete this record?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text("Cancel")),
            TextButton(
              onPressed: () {
                context.read<AttendanceBloc>().add(DeleteAttendance(rowIndex));
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  static Color getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'present': return Colors.green;
      case 'absent': return Colors.red;
      case 'late': return Colors.orange;
      default: return Colors.blueGrey;
    }
  }
}