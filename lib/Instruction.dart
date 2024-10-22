class Instruction {
  String commandName;
  int? commandCode;
  String? commandContent;

  String? description;

  Instruction({
    required this.commandName,
    this.commandCode,
    this.commandContent,
    this.description,
  });

  // New method to create Instruction from CSV row
  static Instruction fromCsv(List<dynamic> row) {
    return Instruction(
      commandName: row[0],
      commandCode: row[1] != null ? int.tryParse(row[1].toString()) : null,
      commandContent: row[2],
      description: row[3],
    );
  }

  // New method to create Instruction from Excel row
  static Instruction fromExcel(List<dynamic> row) {
    return Instruction(
      commandName: row[0]?.toString() ?? '',
      commandCode: row[1] != null ? int.tryParse(row[1].toString()) : null,
      commandContent: row[2]?.toString(),
      description: row[3]?.toString(),
    );
  }

  // 生成插入 SQL 语句

  String toInsertSql() {
    final values = [
      "'$commandName'",
      commandCode != null ? commandCode.toString() : 'NULL',
      commandContent != null ? "'$commandContent'" : 'NULL',
      description != null ? "'$description'" : 'NULL',
    ].join(', ');

    return 'INSERT INTO instructions (command_name, command_code, command_content, description) VALUES ($values);';
  }
}
