import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class HourlyForecastWeatherDatabase {
  late Database _hourlyForecastWeatherDatabase;
  static const String dbTable_hourly = 'weather';
  static const String columnLocation = 'location';
  static const String columnId = 'id';
  static const String columnTemperature = 'temperature';
  static const String columnWeatherState = 'weather_state';
  static const String columnTime = 'time';

  Future<void> initDatabase() async {
    _hourlyForecastWeatherDatabase = await openDatabase(
      join(await getDatabasesPath(), 'weather_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $dbTable_hourly(
            $columnId INTEGER PRIMARY KEY AUTOINCREMENT,
            $columnTemperature REAL,
            $columnWeatherState TEXT,
            $columnTime INTEGER
          )
          ''',
        );
      },
      version: 1,
    );
  }

  Future<void> insertWeather(Map<String, dynamic> data) async {
    await _hourlyForecastWeatherDatabase.insert(
      dbTable_hourly,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWeather(String location) async {
    return await _hourlyForecastWeatherDatabase.query(
      dbTable_hourly,
      where: '$columnLocation = ?',
      whereArgs: [location],
    );
  }
}
