import 'dart:async';
import 'package:attendance_management/data/data_source/google_sheets_service.dart';
import 'package:attendance_management/data/models/attandance_model.dart';
import 'package:attendance_management/presentation/blocs/attandance_event.dart';
import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GoogleSheetsService sheetsService;
  String? selectedDate;
  Set<String> removedEmployees = {}; // Store removed employees locally

  AttendanceBloc(this.sheetsService) : super(AttendanceLoading()) {
    on<FetchAttendance>(_fetchAttendance);
    on<SelectAttendanceDate>(_selectAttendanceDate);
    on<UpdateAttendance>(_updateAttendance);
    on<DeleteAttendance>(_deleteAttendance);
    on<AddAttendance>(_addAttendance);
    on<RemoveEmployeeEvent>(_removeEmployee);
  }

  Future<void> _fetchAttendance(FetchAttendance event, Emitter<AttendanceState> emit) async {
    try {
      final data = await sheetsService.fetchAttendanceData('Sheet1');
      final List<Attendance> attendanceList = [];

      for (int i = 0; i < data.length; i++) {
        attendanceList.add(Attendance.fromList(data[i], rowIndex: i + 1));
      }

      // Load removed employees from SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      removedEmployees = prefs.getStringList("removedEmployees")?.toSet() ?? {};

      final List<Attendance> filteredAttendance = (selectedDate != null)
          ? attendanceList.where((e) => e.date == selectedDate && !removedEmployees.contains(e.employeeName)).toList()
          : attendanceList.where((e) => !removedEmployees.contains(e.employeeName)).toList();

      emit(AttendanceLoaded(attendanceList, filteredAttendance, selectedDate, removedEmployees));
    } catch (e) {
      emit(AttendanceError('Failed to fetch data: $e'));
    }
  }

  void _selectAttendanceDate(SelectAttendanceDate event, Emitter<AttendanceState> emit) {
    selectedDate = event.date;
    _filterData(emit);
  }

  void _filterData(Emitter<AttendanceState> emit) {
    final state = this.state;
    if (state is AttendanceLoaded) {
      final filteredAttendance = state.attendanceList
          .where((e) => (selectedDate == null || e.date == selectedDate) && !removedEmployees.contains(e.employeeName))
          .toList();
      emit(AttendanceLoaded(state.attendanceList, filteredAttendance, selectedDate, removedEmployees));
    }
  }

  Future<void> _updateAttendance(UpdateAttendance event, Emitter<AttendanceState> emit) async {
    try {
      await sheetsService.updateAttendance('Sheet1', event.rowIndex, [
        event.updatedAttendance.date,
        event.updatedAttendance.employeeName,
        event.updatedAttendance.checkIn,
        event.updatedAttendance.checkOut,
        event.updatedAttendance.overtime,
        event.updatedAttendance.status,
      ]);
      add(FetchAttendance(selectedDate ?? 'today'));
    } catch (e) {
      emit(AttendanceError('Failed to update data: $e'));
    }
  }

  Future<void> _deleteAttendance(DeleteAttendance event, Emitter<AttendanceState> emit) async {
    try {
      await sheetsService.deleteAttendanceRecord('Sheet1', event.rowIndex);
      add(FetchAttendance(selectedDate ?? 'today'));
    } catch (e) {
      emit(AttendanceError('Failed to delete record: $e'));
    }
  }

  Future<void> _addAttendance(AddAttendance event, Emitter<AttendanceState> emit) async {
    try {
      await sheetsService.addAttendanceRecord('Sheet1', [
        event.newAttendance.date,
        event.newAttendance.employeeName,
        event.newAttendance.checkIn,
        event.newAttendance.checkOut,
        event.newAttendance.overtime,
        event.newAttendance.status,
      ]);

      emit(AttendanceAdded());
      add(FetchAttendance(selectedDate ?? 'today'));
    } catch (e) {
      emit(AttendanceError('Failed to add record: $e'));
    }
  }

  Future<void> _removeEmployee(RemoveEmployeeEvent event, Emitter<AttendanceState> emit) async {
    removedEmployees.add(event.employeeName);

    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList("removedEmployees", removedEmployees.toList());

    add(FetchAttendance(selectedDate ?? 'today'));
    emit(EmployeeRemoved());
  }
}
