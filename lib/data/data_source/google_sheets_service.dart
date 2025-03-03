import 'dart:convert';
import 'package:googleapis/sheets/v4.dart';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/services.dart' show rootBundle;

class GoogleSheetsService {
  static const _scopes = [SheetsApi.spreadsheetsScope];

  final String spreadsheetId;
  late SheetsApi _sheetsApi;
  late AuthClient _client;

  GoogleSheetsService(this.spreadsheetId);

  Future<void> authenticate() async {
    final jsonString =
    await rootBundle.loadString('assets/service_account.json');
    final serviceAccount = jsonDecode(jsonString);
    final credentials = ServiceAccountCredentials.fromJson(serviceAccount);
    final client = http.Client();

    _client = await obtainAccessCredentialsViaServiceAccount(
        credentials, _scopes, client)
        .then((accessCredentials) =>
        authenticatedClient(client, accessCredentials));

    _sheetsApi = SheetsApi(_client);
  }

  Future<List<List<dynamic>>> fetchAttendanceData(String sheetName) async {
    await authenticate();
    final response = await _sheetsApi.spreadsheets.values.get(
      spreadsheetId,
      '$sheetName!A:F',
    );

    // Filter out empty rows
    final List<List<dynamic>> nonEmptyRows =
    (response.values ?? []).where((row) => row.isNotEmpty).toList();

    return nonEmptyRows;
  }


  Future<void> updateAttendance(
      String sheetName, int row, List<dynamic> values) async {
    await authenticate();
    final request = ValueRange(values: [values]);
    await _sheetsApi.spreadsheets.values.update(
      request,
      spreadsheetId,
      '$sheetName!A$row:F$row',
      valueInputOption: 'USER_ENTERED',
    );
  }

  Future<void> deleteAttendanceRecord(String sheetName, int row) async {
    await authenticate();

    await _sheetsApi.spreadsheets.batchUpdate(
      BatchUpdateSpreadsheetRequest(
        requests: [
          Request(
            deleteDimension: DeleteDimensionRequest(
              range: DimensionRange(
                sheetId: 0,
                dimension: "ROWS",
                startIndex: row - 1,
                endIndex: row,
              ),
            ),
          ),
        ],
      ),
      spreadsheetId,
    );
  }

  Future<void> addAttendanceRecord(String sheetName, List<dynamic> values) async {
    await authenticate();

    final request = ValueRange(values: [values]);

    await _sheetsApi.spreadsheets.values.append(
      request,
      spreadsheetId,
      '$sheetName!A:F',
      valueInputOption: 'USER_ENTERED',
    );
  }

  Future<void> removeEmployee(String sheetName, String employeeName) async {
    await authenticate();
    final data = await fetchAttendanceData(sheetName);

    List<int> rowsToDelete = [];
    for (int i = 0; i < data.length; i++) {
      if (data[i].isNotEmpty && data[i][0] == employeeName) {
        rowsToDelete.add(i + 1); // Convert to 1-based index for Sheets
      }
    }

    if (rowsToDelete.isEmpty) return;

    List<Map<String, int>> deleteGroups = [];
    int offset = 0;

    for (int i = 0; i < rowsToDelete.length;) {
      int count = 1;
      while (i + count < rowsToDelete.length &&
          rowsToDelete[i + count] == rowsToDelete[i] + count) {
        count++;
      }

      deleteGroups.add({"row": rowsToDelete[i] - offset, "num": count});
      offset += count;
      i += count;
    }

    // Batch delete grouped rows to optimize API calls
    for (var group in deleteGroups.reversed) {
      await _sheetsApi.spreadsheets.batchUpdate(
        BatchUpdateSpreadsheetRequest(
          requests: [
            Request(
              deleteDimension: DeleteDimensionRequest(
                range: DimensionRange(
                  sheetId: 0,
                  dimension: "ROWS",
                  startIndex: group["row"]! - 1,
                  endIndex: group["row"]! - 1 + group["num"]!,
                ),
              ),
            ),
          ],
        ),
        spreadsheetId,
      );
    }
  }

}
