import 'package:flutter/material.dart';

class HomeScreenUtils {
  static void showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Quick Guide'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('✔ Drag down to refresh attendance records.'),
              Text("✔ Click '🖊' edit button to modify attendance details."),
              Text('✔ Use the dropdown to filter records by date.'),
              Text("✔ Click '+' to add attendance."),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: Text('OK')),
          ],
        );
      },
    );
  }

}