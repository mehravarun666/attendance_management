import 'package:attendance_management/data/data_source/google_sheets_service.dart';
import 'package:attendance_management/presentation/blocs/attendance_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'presentation/screens/home_screen.dart';

void main() {
  final sheetsService = GoogleSheetsService('Google Sheet Id');

  runApp(
    BlocProvider(
      create: (context) => AttendanceBloc(sheetsService),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: HomeScreen(),
    );
  }
}
