import 'package:attendance_management/core/utils/attandance_utils.dart';
import 'package:attendance_management/data/models/attandance_model.dart';
import 'package:attendance_management/presentation/blocs/attandance_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import '../blocs/attandance_event.dart';

class AttendanceScreen extends StatelessWidget {
  const AttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    context.read<AttendanceBloc>().add(FetchAttendance('today'));
    return  BlocBuilder<AttendanceBloc, AttendanceState>(
        builder: (context, state) {
          if (state is AttendanceLoading) {
            return Center(child: CircularProgressIndicator());
          } else if (state is AttendanceLoaded) {
            final attendanceList = state.attendanceList.skip(1).toList();
            final availableDates =
                attendanceList.map((e) => e.date).toSet().toList();
            availableDates.sort((a, b) => b.compareTo(a));
            final selectedDate = state.selectedDate ??
                (availableDates.isNotEmpty ? availableDates.first : null);

            //check if app first loaded or no date selected then latest date should shown
            if (state.selectedDate == null && selectedDate != null) {
              context.read<AttendanceBloc>().add(SelectAttendanceDate(availableDates.first));
            }

            return Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Theme(
                    data: Theme.of(context)
                        .copyWith(canvasColor: Colors.grey.shade200),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        Text("Select By Date:"),
                        DropdownButton<String>(
                          value: selectedDate,
                          hint: Text("Select Date"),
                          items: availableDates.map((date) {
                            return DropdownMenuItem(
                                value: date, child: Text(date));
                          }).toList(),
                          onChanged: (newDate) {
                            context
                                .read<AttendanceBloc>()
                                .add(SelectAttendanceDate(newDate!));
                          },
                        ),
                      ],
                    ),
                  ),
                ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      context
                          .read<AttendanceBloc>()
                          .add(FetchAttendance(selectedDate ?? 'today'));
                    },
                    child: ListView.builder(
                      itemCount: state.filteredAttendance.length,
                      itemBuilder: (context, index) {
                        Attendance person = state.filteredAttendance[index];
                        return Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 5),
                          child: Stack(
                            children: [
                              Card(
                                child:Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Row(
                                    children: [
                                      Container(
                                          color: Colors.grey,
                                          height: 70,
                                          width: 70),
                                      SizedBox(width: 10,),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(person.employeeName,style: TextStyle(fontSize: 15,fontWeight: FontWeight.w600),),
                                          Text(
                                            "Check-In: ${person.checkIn} "),
                                          Text(
                                              "Check-Out: ${person.checkOut} "),
                                          Text(
                                              "Overtime: ${person.overtime} "),
                                        ],
                                      ),
                                      Spacer(),
                                      IconButton(
                                        icon: Icon(Icons.edit, size: 20),
                                        onPressed: () =>
                                            AttendanceUtils.showEditDialog(
                                                context, person),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.delete, size: 20, color: Colors.red),
                                        onPressed: () {
                                          AttendanceUtils.showDeleteConfirmation(context, person.rowIndex);
                                        },
                                      ),

                                    ],
                                  ),
                                )
                              ),
                              Positioned(
                                top: 0,
                                left: 0,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: AttendanceUtils.getStatusColor(
                                        person.status),
                                    borderRadius: BorderRadius.only(
                                        bottomRight: Radius.circular(8)),
                                  ),
                                  child: Text(person.status.toUpperCase(),
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold)),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            );
          } else if (state is AttendanceError) {
            return Center(child: Text('Error: ${state.message}'));
          }
          return Container();
        },
      );
  }
}
