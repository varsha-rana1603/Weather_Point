import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class WeatherDatabase {
  late Database _database;     //property of SQLite package

  static const String dbTable = 'weather';
  static const String columnId = 'id';
  static const String columnLocation = 'location';
  static const String columnTemperature = 'temperature';
  static const String columnHumidity = 'humidity';
  static const String columnWeatherState = 'weather_state';
  static const String columnPressure = 'pressure';
  static const String columnClouds = 'clouds';
  static const String columnWindDegree = 'wind_degree';
  static const String columnWindSpeed = 'wind_speed';
  static const String columnVisibility = 'visibility';
  static const String columnTime = 'time';
  static const String columnTemperatureUnit = 'temp_unit';

  Future<void> initDatabase() async {
    _database = await openDatabase(
      join(await getDatabasesPath(), 'weather.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $dbTable(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnLocation TEXT,
            $columnTemperature REAL,
            $columnHumidity REAL,
            $columnWeatherState TEXT,
            $columnPressure REAL,
            $columnClouds REAL,
            $columnWindDegree REAL,
            $columnWindSpeed REAL,
            $columnVisibility REAL,
            $columnTime INTEGER,
            $columnTemperatureUnit INTEGER,
          )
          ''',
        );
      },
      version: 2,    //if the version is increased, the onCreate callback is executed
    );
  }

  Future<void> setTemperatureUnit(String location, int temperatureUnit) async {
    final db = await _database.database;
    await db.update(
      dbTable,
      {columnTemperatureUnit: temperatureUnit},
      where: '$columnLocation = ?',
      whereArgs: [location],
    );
  }
  //'insert' inserts a row into the database table
  Future<void> insertWeather(Map<String, dynamic> data) async {
    await _database.insert(
      dbTable,     //name of databse table
      data,        //map of all columns and values to be inserted
      conflictAlgorithm: ConflictAlgorithm.replace,   //used to replace existing row
    );
  }
   //retrieve data from database
  Future<List<Map<String, dynamic>>> getWeather(String location) async {
    final db = await _database.database;
    return await db.query(
      dbTable,
      where: '$columnLocation = ?',
      whereArgs: [location],
    );
  }
}
