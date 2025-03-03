import 'dart:async';
import 'package:attendance_management/data/data_source/google_sheets_service.dart';
import 'package:attendance_management/data/models/attandance_model.dart';
import 'package:attendance_management/presentation/blocs/attandance_event.dart';
import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AttendanceBloc extends Bloc<AttendanceEvent, AttendanceState> {
  final GoogleSheetsService sheetsService;
  String? selectedDate;

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

      final List<Attendance> filteredAttendance = (selectedDate != null)
          ? attendanceList.where((e) => e.date == selectedDate).toList()
          : attendanceList;

      emit(AttendanceLoaded(attendanceList, filteredAttendance, selectedDate));
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
      final filteredAttendance = state.attendanceList.where((e) {
        return (selectedDate == null || e.date == selectedDate);
      }).toList();
      emit(AttendanceLoaded(state.attendanceList, filteredAttendance, selectedDate));
    }
  }

  Future<void> _updateAttendance(UpdateAttendance event, Emitter<AttendanceState> emit) async {
    try {
      await sheetsService.updateAttendance(
        'Sheet1',
        event.rowIndex,
        [
          event.updatedAttendance.date,
          event.updatedAttendance.employeeName,
          event.updatedAttendance.checkIn,
          event.updatedAttendance.checkOut,
          event.updatedAttendance.overtime,
          event.updatedAttendance.status,
        ],
      );
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
    try {
      await sheetsService.removeEmployee('Sheet1', event.employeeName);
      add(FetchAttendance(selectedDate ?? 'today'));
      emit(EmployeeRemoved());
    } catch (e) {
      emit(AttendanceError('Failed to remove employee: $e'));
    }
  }

}


