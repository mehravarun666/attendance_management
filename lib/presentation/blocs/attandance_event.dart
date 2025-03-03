import 'package:attendance_management/data/models/attandance_model.dart';

abstract class AttendanceEvent {}

class FetchAttendance extends AttendanceEvent {
  final String date;
  FetchAttendance(this.date);
}

class SelectAttendanceDate extends AttendanceEvent {
  final String date;
  SelectAttendanceDate(this.date);
}

class UpdateAttendance extends AttendanceEvent {
  final int rowIndex;
  final Attendance updatedAttendance;

  UpdateAttendance(this.rowIndex, this.updatedAttendance);
}


class DeleteAttendance extends AttendanceEvent {
  final int rowIndex;

  DeleteAttendance(this.rowIndex);
}


class AddAttendance extends AttendanceEvent {
  final Attendance newAttendance;
  AddAttendance(this.newAttendance);
}

class RemoveEmployeeEvent extends AttendanceEvent {
  final String employeeName;
  RemoveEmployeeEvent(this.employeeName);
}



