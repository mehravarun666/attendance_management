class Attendance {
  final int rowIndex;
  final String employeeName;
  final String date;
  final String checkIn;
  final String checkOut;
  final String overtime;
  final String status;

  Attendance({
    required this.rowIndex,
    required this.employeeName,
    required this.date,
    required this.checkIn,
    required this.checkOut,
    required this.overtime,
    required this.status,
  });

  factory Attendance.fromList(List<dynamic> row, {int rowIndex = 0}) {
    return Attendance(
      rowIndex: rowIndex,
      employeeName: row[1] ?? '',
      date: row[0] ?? '',
      checkIn: row[2] ?? '',
      checkOut: row[3] ?? '',
      overtime: row[4] ?? '',
      status: row[5] ?? '',
    );
  }

  Attendance copyWith({
    int? rowIndex,
    String? employeeName,
    String? date,
    String? checkIn,
    String? checkOut,
    String? overtime,
    String? status,
  }) {
    return Attendance(
      rowIndex: rowIndex ?? this.rowIndex,
      employeeName: employeeName ?? this.employeeName,
      date: date ?? this.date,
      checkIn: checkIn ?? this.checkIn,
      checkOut: checkOut ?? this.checkOut,
      overtime: overtime ?? this.overtime,
      status: status ?? this.status,
    );
  }
}
