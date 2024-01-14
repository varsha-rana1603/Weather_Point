import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class ForecastWeatherDatabase {
  late Database _forecastWeatherDatabase;
  static const String dbTable_forecast = 'weather';
  static const String columnLocation = 'location';
  static const String columnId = 'id';
  static const String columnTemperature = 'temperature';
  static const String columnWeatherState = 'weather_state';
  static const String columnTime = 'time';

  Future<void> initDatabase() async {
    _forecastWeatherDatabase = await openDatabase(
      join(await getDatabasesPath(), 'weather_database.db'),
      onCreate: (db, version) {
        return db.execute(
          '''
          CREATE TABLE $dbTable_forecast(
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
    await _forecastWeatherDatabase.insert(
      dbTable_forecast,
      data,
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<Map<String, dynamic>>> getWeather(String location) async {
    return await _forecastWeatherDatabase.query(
      dbTable_forecast,
      where: '$columnLocation = ?',
      whereArgs: [location],
    );
  }
}
