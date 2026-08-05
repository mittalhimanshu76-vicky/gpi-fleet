import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
DatabaseHelper._();

static final DatabaseHelper instance = DatabaseHelper._();

static Database? _database;

Future<Database> get database async {
if (_database != null) return _database!;
_database = await _initDB();
return _database!;
}

Future<Database> _initDB() async {
final dbPath = await getDatabasesPath();
final path = join(dbPath, "gpi_fleet.db");

return await openDatabase(
path,
version: 3,
onCreate: _createDB,
onUpgrade: _upgradeDB,
);
}

Future<void> _createDB(Database db, int version) async {
await db.execute('''
CREATE TABLE drivers(
id INTEGER PRIMARY KEY AUTOINCREMENT,
name TEXT NOT NULL
)
''');

await db.execute('''
CREATE TABLE trucks(
id INTEGER PRIMARY KEY AUTOINCREMENT,
truck_no TEXT NOT NULL
)
''');

await db.execute('''
CREATE TABLE expenses(
id INTEGER PRIMARY KEY AUTOINCREMENT,
date TEXT NOT NULL,
driver_id INTEGER NOT NULL,
truck_id INTEGER NOT NULL,
amount REAL NOT NULL,
paid_by TEXT NOT NULL,
payment_mode TEXT NOT NULL,
expense_name TEXT NOT NULL,
remarks TEXT
)
''');
}

Future<void> _upgradeDB(
Database db,
int oldVersion,
int newVersion,
) async {

if (oldVersion < 2) {

await db.execute("DROP TABLE IF EXISTS expenses");

await db.execute('''
CREATE TABLE expenses(
id INTEGER PRIMARY KEY AUTOINCREMENT,
date TEXT NOT NULL,
driver_id INTEGER NOT NULL,
truck_id INTEGER NOT NULL,
amount REAL NOT NULL,
paid_by TEXT NOT NULL,
payment_mode TEXT NOT NULL,
expense_name TEXT NOT NULL,
remarks TEXT
)
''');
}

if (oldVersion < 3) {

final expenses = await db.query(
'expenses',
columns: ['id', 'date'],
);

for (final expense in expenses) {

final value = expense['date'] as String;

final parts = value.split('/');

if (parts.length == 3) {

final day = parts[0].padLeft(2, '0');
final month = parts[1].padLeft(2, '0');

await db.update(
'expenses',
{
'date': '${parts[2]}-$month-$day',
},
where: 'id=?',
whereArgs: [expense['id']],
);
}
}
}
}

//---------------- DRIVER ----------------//

Future<int> addDriver(String name) async {
final db = await database;

return db.insert(
"drivers",
{
"name": name,
},
);
}

Future<List<Map<String, dynamic>>> getDrivers() async {
final db = await database;

return db.query(
"drivers",
orderBy: "name",
);
}

Future<bool> isDriverReferenced(int id) async {
final db = await database;

final result = await db.query(
"expenses",
columns: ["id"],
where: "driver_id=?",
whereArgs: [id],
limit: 1,
);

return result.isNotEmpty;
}

Future<int> deleteDriver(int id) async {
if (await isDriverReferenced(id)) {
return 0;
}

final db = await database;

return db.delete(
"drivers",
where: "id=?",
whereArgs: [id],
);
}

//---------------- TRUCK ----------------//

Future<int> addTruck(String truckNo) async {
final db = await database;

return db.insert(
"trucks",
{
"truck_no": truckNo,
},
);
}

Future<List<Map<String, dynamic>>> getTrucks() async {
final db = await database;

return db.query(
"trucks",
orderBy: "truck_no",
);
}

Future<bool> isTruckReferenced(int id) async {
final db = await database;

final result = await db.query(
"expenses",
columns: ["id"],
where: "truck_id=?",
whereArgs: [id],
limit: 1,
);

return result.isNotEmpty;
}

Future<int> deleteTruck(int id) async {
if (await isTruckReferenced(id)) {
return 0;
}

final db = await database;

return db.delete(
"trucks",
where: "id=?",
whereArgs: [id],
);
}
  //---------------- EXPENSE ----------------//

  Future<int> addExpense(Map<String, dynamic> expense) async {
    final db = await database;

    return db.insert(
      "expenses",
      expense,
    );
  }

  Future<int> updateExpense(
      int id,
      Map<String, dynamic> expense,
      ) async {

    final db = await database;

    return db.update(
      "expenses",
      expense,
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<int> deleteExpense(int id) async {
    final db = await database;

    return db.delete(
      "expenses",
      where: "id=?",
      whereArgs: [id],
    );
  }

  Future<List<Map<String, dynamic>>> getExpenses() async {
    final db = await database;

    return db.rawQuery('''
SELECT
e.*,
d.name AS driver_name,
t.truck_no AS truck_no
FROM expenses e
LEFT JOIN drivers d
ON e.driver_id = d.id
LEFT JOIN trucks t
ON e.truck_id = t.id
ORDER BY e.id DESC
''');
  }

  Future<Map<String, double>> getDashboardTotals() async {

    final db = await database;

    final now = DateTime.now();

    final today = _dateString(now);

    final monthStart =
    _dateString(DateTime(now.year, now.month));

    final nextMonth =
    _dateString(DateTime(now.year, now.month + 1));

    final todayResult = await db.rawQuery(
      '''
SELECT COALESCE(SUM(amount),0) total
FROM expenses
WHERE date=?
''',
      [today],
    );

    final monthResult = await db.rawQuery(
      '''
SELECT COALESCE(SUM(amount),0) total
FROM expenses
WHERE date>=?
AND date<?
''',
      [
        monthStart,
        nextMonth,
      ],
    );

    return {
      "today":
      (todayResult.first["total"] as num).toDouble(),
      "month":
      (monthResult.first["total"] as num).toDouble(),
    };
  }

  String _dateString(DateTime date) {

    final month =
    date.month.toString().padLeft(2, "0");

    final day =
    date.day.toString().padLeft(2, "0");

    return "${date.year}-$month-$day";
  }
}
