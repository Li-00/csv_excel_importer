import 'package:csv_excel_importer/file_import.dart';

void main() async {
  final importer = FileImporter();

  /// 文件路径 csv_date_number.csv    excel_date_number.xlsx
  String filePath =
      'D:\\desk\\code\\csv_excel_importer\\date\\csv_date_200000.csv';

  /// 数据库路径
  String datePath = 'D:\\desk\\code\\csv_excel_importer\\date\\test_date';

  /// 总耗时统计
  final totalStopwatch = Stopwatch()..start();

  /// 解析文件
  final importStopwatch = Stopwatch()..start();
  final data = await importer.importFile(filePath);
  print(
      '[csv_excel_importer] main File importer in ${importStopwatch.elapsedMilliseconds} ms');

  /// 导入到数据库
  final dbStopwatch = Stopwatch()..start();
  await importer.importToDb(data, datePath);
  print(
      '[csv_excel_importer] main Data importToDb in ${dbStopwatch.elapsedMilliseconds} ms');

  /// 总耗时
  print(
      '[csv_excel_importer] main Total execution time: ${totalStopwatch.elapsedMilliseconds} ms');

  ///清空数据
  // await importer.clearTable(datePath);
}

/// 执行三次记录

// 解析 500 条对比                  excel                 csv
// 读取耗时                      148 - 170 ms       42 - 53 ms
// 数据库开启耗时                 135 - 172 ms        130 - 146 ms
// 入库耗时                      196 - 213 ms        194 - 273 ms
// 总耗时                        350 - 414 ms      238 - 326 ms
  

// 解析 200000 条对比                 excel                  csv
// 读取耗时                      5137 - 5959 ms          705 - 740 ms
// 数据库开启耗时                 121  - 127 ms           110 - 117 ms
// 入库耗时                      1630  - 1667 ms          1596 - 1623 ms
// 总耗时                        6791 - 7653 ms          2339 - 2381 ms
    