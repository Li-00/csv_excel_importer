import 'dart:convert';
import 'dart:io';
import 'package:spreadsheet_decoder/spreadsheet_decoder.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:csv/csv.dart';
import 'package:csv_excel_importer/Instruction.dart';

import 'package:logger/logger.dart';

class FileImporter {
  final Logger logger = Logger(); // Initialize logger
  final String logPrefix = '[csv_excel_importer]'; // Unified log prefix

  Future<List<Instruction>> importFile(String filePath) async {
    final extension = filePath.split('.').last;

    if (extension == 'csv') {
      return await _importCsv(filePath);
    } else if (extension == 'xls' || extension == 'xlsx') {
      return await _importExcelSpreadSheet(filePath);
    } else {
      throw Exception('Unsupported file type');
    }
  }

  Future<List<Instruction>> _importCsv(String filePath) async {
    final input = File(filePath).openRead();

    final fields = await input
        .transform(utf8.decoder)
        .transform(const CsvToListConverter()) // Added 'const' here
        .toList();

    // Skip the header row
    return fields.skip(1).map((row) {
      // Add data validation here if necessary
      return Instruction.fromCsv(row); // Use the new method
    }).toList();
  }

  Future<List<Instruction>> _importExcelSpreadSheet(String filePath) async {
    logger.i(' _importExcel Excel file: filePath=$filePath');

    final bytes = File(filePath).readAsBytesSync();

    var decoder = SpreadsheetDecoder.decodeBytes(bytes, update: true);

    if (decoder.tables.isEmpty) {
      logger.e('$logPrefix Excel file is empty or invalid: $filePath');
      throw Exception('Excel file is empty or invalid');
    }

    final sheet = decoder.tables.values.firstOrNull;
    if (sheet == null) {
      throw Exception('No sheets found in the Excel file.');
    }

    // Skip the first row (header) and process the rest
    return sheet.rows
        .skip(1) // Skip the header row
        .where((row) => row.isNotEmpty)
        .map((row) {
          try {
            return Instruction.fromExcel(row);
          } catch (e) {
            logger.w('Error parsing row: $row. Error: $e');
            // Return null for rows that can't be parsed
            return null;
          }
        })
        .where((instruction) => instruction != null) // Filter out null values
        .cast<Instruction>() // Cast the non-null values to Instruction
        .toList();
  }

  Future<void> importToDb(List<Instruction> data, String datePath) async {
    // Check for data validation before importing
    if (data.isEmpty) {
      logger.e('$logPrefix No data to import.');
      throw Exception('No data to import.');
    }

    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    const batchSize = 1000;
    final stopwatch = Stopwatch();
    stopwatch.start();

    final databaseOpenStopwatch = Stopwatch();
    databaseOpenStopwatch.start();
    final database = await _getDatabase(datePath);
    databaseOpenStopwatch.stop();
    logger.i(
        '$logPrefix Database opened in ${databaseOpenStopwatch.elapsedMilliseconds} ms.');

    try {
      await database.transaction((txn) async {
        for (int i = 0; i < data.length; i += batchSize) {
          final batch = data.sublist(
              i, i + batchSize > data.length ? data.length : i + batchSize);

          final batchStopwatch = Stopwatch(); // Measure batch import time
          batchStopwatch.start();

          final Batch dbBatch = txn.batch();

          for (var instruction in batch) {
            final sql = instruction.toInsertSql();

            dbBatch.execute(sql);
          }

          await dbBatch.commit(noResult: true);
          batchStopwatch.stop();
          logger.i(
              '$logPrefix Batch of ${batch.length} imported in ${batchStopwatch.elapsedMilliseconds} ms.');
        }
      });
      logger.i(
          '$logPrefix Successfully imported ${data.length} instructions to database in ${stopwatch.elapsedMilliseconds} ms.');
    } catch (e) {
      logger.e('Error during database operation: $e');
      throw Exception('Failed to import data to database: $e');
    } finally {
      await database.close();
    }
  }

  Future<Database> _getDatabase(String datePath) async {
    try {
      logger.i('_getDatabase:datePath=$datePath');
      // We're opening an existing database, so we don't need to create the directory
      return await openDatabase(datePath, onCreate: (db, version) async {
        // The table creation is now inside the existing database
        await db.execute('''
          CREATE TABLE IF NOT EXISTS instructions (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            command_name TEXT NOT NULL,
            command_code INTEGER,
            command_content TEXT,
            description TEXT
          )
        ''');
      }, version: 1);
    } catch (e) {
      logger.e('$logPrefix Error opening database: $e');
      throw Exception('Failed to open database: $e');
    }
  }

  Future<void> clearTable(String datePath) async {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;

    final stopwatch = Stopwatch();
    stopwatch.start();

    final database = await _getDatabase(datePath);

    try {
      await database.execute('DELETE FROM instructions');
      logger.i(
          '$logPrefix Table cleared successfully in ${stopwatch.elapsedMilliseconds} ms.');
    } catch (e) {
      logger.e('$logPrefix Error clearing table: $e');
      throw Exception('Failed to clear table: $e');
    } finally {
      await database.close();
    }
  }
}
