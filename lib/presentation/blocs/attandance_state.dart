
import 'package:attendance_management/data/models/attandance_model.dart';

abstract class AttendanceState {}

class AttendanceLoading extends AttendanceState {}

class AttendanceLoaded extends AttendanceState {
  final List<Attendance> attendanceList;
  final List<Attendance> filteredAttendance;
  final String? selectedDate;
  final Set<String> removedEmployees;

  AttendanceLoaded(this.attendanceList, this.filteredAttendance, this.selectedDate,this.removedEmployees);
}

class AttendanceUpdated extends AttendanceState {}

class AttendanceDeleted extends AttendanceState {}

class AttendanceAdded extends AttendanceState {}

class EmployeeUpdated extends AttendanceState {}

class EmployeeRemoved extends AttendanceState {}

class AttendanceError extends AttendanceState {
  final String message;
  AttendanceError(this.message);
}

