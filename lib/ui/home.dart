import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather_point/data/database_forecast.dart';
import 'package:weather_point/data/database_hourlyForecast.dart';
import 'package:weather_point/models/city.dart';
import 'package:weather_point/models/constants.dart';
import 'package:weather_point/widgets/weather_item.dart';
import 'package:weather_point/data/database.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:weather_point/widgets/forecast_item.dart';
import 'package:weather_point/widgets/hourlyForecast_item.dart';

//class made to represent the data to be displayed in forecast widgets
class Forecast {
  double temperature;
  late String weatherState;
  final DateTime time;        //final is used when the value we require is to be determined at run-time and not compile-time
  //final is also used when the value is not to be changed unless the whole widget tree is rebuilt

  Forecast({
    required this.temperature,
    required this.weatherState,
    required this.time,
  });
}

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();   //we make a seperate class to hold the mutable state of the widget
}

enum TemperatureUnit { Celsius, Fahrenheit }

class _HomeState extends State<Home> {
  Constants myConstants = Constants();
  TemperatureUnit selectedTemperatureUnit = TemperatureUnit.Celsius;
  TemperatureUnit userTemperatureUnit = TemperatureUnit.Celsius;
  TemperatureUnit userTemperaturePreference = TemperatureUnit.Celsius;
  int selectedDayIndex = 0; // To track the selected day index
  late WeatherDatabase _database;
  late ForecastWeatherDatabase _forecastWeatherDatabase;
  late HourlyForecastWeatherDatabase _hourlyForecastWeatherDatabase;

  // initialization
  double temperature = 0.0;
  double pressure = 0.0;
  String weatherStateName = 'Loading...';
  double humidity = 0.0;
  double windSpeed = 0.0;
  double clouds = 0.0;
  double visibility = 0.0;
  double degree = 0.0;
  String imageUrl = '';
  String location = 'Pilani'; // default city

  // Create a shader linear gradient
  final Shader linearGradient = const LinearGradient(
    colors: <Color>[Color(0xffABCFF2), Color(0xff9AC6F3)],
  ).createShader(const Rect.fromLTWH(0.0, 0.0, 200.0, 70.0));

  // get the cities data
  var selectedCities = City.citiesList;
  List<String> cities = ['Pilani']; // the list to hold our cities, default is Pilani
  List consolidatedWeatherList = []; // to hold weather data after API call
  List<Forecast> forecastList = [];
  List<Forecast> hourlyForecastList = [];

  // declare default asset list
  List<String> defaultAssets = [
    'assets/haze.png',
    'assets/broken clouds.png',
    'assets/clear sky.png',
    'assets/few clouds.png',
    'assets/fog.png',
    'assets/overcast clouds.png',
    'assets/rain.png',
    'assets/scattered clouds.png',
    'assets/shower rain.png',
    'assets/snow.png',
    'assets/thunderstorm.png',
    'assets/mist.png',
  ];

  void _convertTemperature() {
    // Update temperature data based on the selected unit
    if (selectedTemperatureUnit == TemperatureUnit.Fahrenheit) {
      temperature = (temperature * 9 / 5) + 32;
      hourlyForecastList.forEach((forecast) {
        forecast.temperature = (forecast.temperature * 9 / 5) + 32;
      });
      forecastList.forEach((forecast) {
        forecast.temperature = (forecast.temperature * 9 / 5) + 32;
      });
      print(temperature);
    } else {
      // Convert back to Celsius
      temperature = (temperature - 32) * 5 / 9;
      hourlyForecastList.forEach((forecast) {
        forecast.temperature = (forecast.temperature - 32) * 5 / 9;
      });
      forecastList.forEach((forecast) {
        forecast.temperature = (forecast.temperature - 32) * 5 / 9;
      });
      print(temperature);
    }
  }

  Future<void> fetchWeatherData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      // When no internet connection, load data from the database
      var storedData = await _database.getWeather(location);
      if (storedData.isNotEmpty) {
        selectedTemperatureUnit = TemperatureUnit.Celsius;
        // Use stored data
        setState(() {
          temperature = storedData[0][WeatherDatabase.columnTemperature];
          humidity = storedData[0][WeatherDatabase.columnHumidity];
          windSpeed = storedData[0][WeatherDatabase.columnWindSpeed];
          pressure = storedData[0][WeatherDatabase.columnPressure];
          weatherStateName = storedData[0][WeatherDatabase.columnWeatherState];
          clouds = storedData[0][WeatherDatabase.columnClouds];
          visibility = storedData[0][WeatherDatabase.columnVisibility];
          degree = storedData[0][WeatherDatabase.columnWindDegree];
       //   int storedTemperatureUnit = storedData[0][WeatherDatabase.columnTemperatureUnit];
          //for the temperature unit
        /*  selectedTemperatureUnit = storedTemperatureUnit == 0
          ? TemperatureUnit.Celsius
          : TemperatureUnit.Fahrenheit;*/
         // _convertTemperature();
        });
      }
      return;
    }
    var weatherResult = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/weather?q=$location&appid=$openWeatherAPIKey'));
    Map<String, dynamic> result = json.decode(weatherResult.body);

    dynamic weatherData = result['main'];
    dynamic wind = result['wind'];
    dynamic weatherState = result['weather'];
    dynamic cloudsJson = result['clouds'];
    dynamic visible = result['visibility'];

    setState(() {
      // Check if temperature is not null before using it
      if (weatherData['temp'] != null) {
        if (selectedTemperatureUnit == TemperatureUnit.Celsius) {
          temperature = (weatherData['temp'].toDouble() - 273.15).toDouble();
        } else {
          temperature = (((weatherData['temp'].toDouble() - 273.15).toDouble() * 1.8).toDouble() + 32.0).toDouble();
        }
      } else {
        // Handle the case where temperature is null, set a default value, or log an error
        temperature = 0.0; // You can set any default value here
        print('Temperature value is null or in unexpected format');
      }

      humidity = weatherData['humidity'].toDouble();
      windSpeed = wind['speed'].toDouble();
      pressure = weatherData['pressure'].toDouble();
      weatherStateName = weatherState[0]['description'];
      clouds = cloudsJson['all'].toDouble();
      visibility = visible.toDouble();
      degree = wind['deg'].toDouble();
    });


    //to store the data in the data base
    await _database.insertWeather({
      WeatherDatabase.columnLocation: location,
      WeatherDatabase.columnTemperature: temperature,
      WeatherDatabase.columnHumidity: humidity,
      WeatherDatabase.columnWeatherState: weatherStateName,
      WeatherDatabase.columnPressure: pressure,
      WeatherDatabase.columnClouds: clouds,
      WeatherDatabase.columnWindDegree: degree,
      WeatherDatabase.columnWindSpeed: windSpeed,
      WeatherDatabase.columnVisibility: visibility,
      WeatherDatabase.columnTime: DateTime.now().millisecondsSinceEpoch,
    });
  }
  Future<void> fetchForecastData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      selectedTemperatureUnit = TemperatureUnit.Celsius;
      // When no internet connection, load data from the database
      var storedData = await _forecastWeatherDatabase.getWeather(location);
      if (storedData.isNotEmpty) {
        // Use stored data
        setState(() {
          forecastList[0].temperature = storedData[0][ForecastWeatherDatabase.columnTemperature];
          forecastList[0].weatherState = storedData[0][ForecastWeatherDatabase.columnWeatherState];
        });
      }
      return;
    }

    var forecastResult = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$openWeatherAPIKey'));
    Map<String, dynamic> forecastData = json.decode(forecastResult.body);

    setState(() {
      forecastList.clear();
      List<dynamic> forecasts = forecastData['list'];
      forecasts.forEach((forecast) {
        DateTime forecastDateTime = DateTime.parse(forecast['dt_txt']);
        if (forecastDateTime.hour == 9) {
          double temperature = forecast['main']['temp'].toDouble() - 273.15;
          if (selectedTemperatureUnit == TemperatureUnit.Fahrenheit) {
            temperature = (temperature * 1.8) + 32.0;
          }

          // Create a new Forecast object and add it to forecastList
          forecastList.add(Forecast(
            temperature: temperature,
            weatherState: forecast['weather'][0]['description'],
            time: forecastDateTime,
          ));
        }
      });
    });

    // Store the data in the database
    await _forecastWeatherDatabase.insertWeather({
      ForecastWeatherDatabase.columnTemperature: forecastList[0].temperature,
      ForecastWeatherDatabase.columnWeatherState: forecastList[0].weatherState,
      ForecastWeatherDatabase.columnTime: DateTime.now().millisecondsSinceEpoch,
    });
  }


        Future<void> fetchHourlyForecastData() async {
    var connectivityResult = await (Connectivity().checkConnectivity());
    if(connectivityResult == ConnectivityResult.none) {
      var storedData = await _hourlyForecastWeatherDatabase.getWeather(location);
      if(storedData != null) {
        selectedTemperatureUnit = TemperatureUnit.Celsius;
        //use the stored data
        setState(() {
          hourlyForecastList[0].temperature = storedData[0][HourlyForecastWeatherDatabase.columnTemperature];
          hourlyForecastList[0].weatherState = storedData[0][HourlyForecastWeatherDatabase.columnWeatherState];
        });
      }
      return;
    }
    var hourlyForecastResult = await http.get(Uri.parse(
        'https://api.openweathermap.org/data/2.5/forecast?q=$location&appid=$openWeatherAPIKey'));
    Map<String, dynamic> hourlyForecastData = json.decode(hourlyForecastResult.body);

    setState(() {
      hourlyForecastList.clear();
      List<dynamic> hourlyForecasts = hourlyForecastData['list'];

      hourlyForecasts.forEach((hourlyForecast) {
        DateTime forecastDateTime = DateTime.parse(hourlyForecast['dt_txt']);

        // Check if the forecast date is the same as the current date
        if (forecastDateTime.year == DateTime.now().year &&
            forecastDateTime.month == DateTime.now().month &&
            forecastDateTime.day == DateTime.now().day) {
          double hourlyTemperature = hourlyForecast['main']['temp'].toDouble() - 273.15;
          if(selectedTemperatureUnit == TemperatureUnit.Fahrenheit){
            hourlyTemperature = (hourlyTemperature * 1.8) + 32.0;
          }
          hourlyForecastList.add(Forecast(
            temperature: hourlyTemperature,
            weatherState: hourlyForecast['weather'][0]['description'],
            time: forecastDateTime,
          ));
        }
      });
    });

      //store the hourly Forecast Data
      await _hourlyForecastWeatherDatabase.insertWeather({
        HourlyForecastWeatherDatabase.columnTemperature: hourlyForecastList[0].temperature,
        HourlyForecastWeatherDatabase.columnWeatherState: hourlyForecastList[0].weatherState,
        HourlyForecastWeatherDatabase.columnTime: DateTime.now().millisecondsSinceEpoch,
      });
    }

  // Function to handle day selection
  /*void onDaySelected(int index) {
    setState(() {
      selectedDayIndex = index;
      fetchWeatherData();
      fetchForecastData();
      fetchHourlyForecastData();
    });
  }*/

  // this function to get the asset path based on the weather state name
  String getImageAssetPath(String weatherStateName) {
    String assetPath = 'assets/$weatherStateName.png';
    if (!defaultAssets.contains(assetPath)) {
      return defaultAssets.first;
    }
    return assetPath;
  }

  void _showTemperatureUnitMenu() async {
    final selectedUnit = await showDialog<TemperatureUnit>(
        context: context,
        builder: (BuildContext context) {
          return SimpleDialog(
            title: const Text('Select Temperature Unit'),
            children: <Widget>[
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, TemperatureUnit.Celsius);
                },
                child: const Text('Celsius'),
              ),
              SimpleDialogOption(
                onPressed: () {
                  Navigator.pop(context, TemperatureUnit.Fahrenheit);
                },
                child: const Text('Fahrenheit'),
              )
            ],
          );
        });
    if (selectedUnit != null) {
      setState(() {
        selectedTemperatureUnit = selectedUnit;
        userTemperatureUnit = selectedUnit;
        //store the unit
       // _database.setTemperatureUnit(location, selectedUnit == TemperatureUnit.Celsius ? 0 : 1);

        _convertTemperature();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _initializeDatabase();
  }

  Future<void> _initializeDatabase() async {  //future is added so that initializing happens fast and does not interfere with the UI
    try {
      _database = WeatherDatabase(); // Initialize the database
      _forecastWeatherDatabase = ForecastWeatherDatabase(); //Initialise the forecast database
      _hourlyForecastWeatherDatabase = HourlyForecastWeatherDatabase(); //Initialise the hourlyForecast database
      await _database.initDatabase();
      await _forecastWeatherDatabase.initDatabase();
      await _hourlyForecastWeatherDatabase.initDatabase();
     // await _database.setTemperatureUnit(location, userTemperatureUnit == TemperatureUnit.Celsius ? 0 : 1);
      await fetchWeatherData();       // Await the completion of fetching current weather data
      await fetchForecastData();           //for weekly forecast
      await fetchHourlyForecastData();     // for hourly forecast
    } catch (e) {
      print('Error initializing database or fetching data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.blue.shade100,
      appBar: AppBar(
          titleSpacing: 0,
          backgroundColor: Colors.blue.shade200,
          title: Container(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            width: size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // location dropdown
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/pin.png',
                      width: 50,
                    ),
                    const SizedBox(
                      width: 0.1,
                    ),

                    DropdownButtonHideUnderline(
                      child: DropdownButton(
                        value: location,
                        icon: const Icon(Icons.keyboard_arrow_down),
                        items: City.citiesList.map((City city) {
                          return DropdownMenuItem(
                            value: city.city,
                            child: Text(city.city),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            location = newValue!;
                            fetchWeatherData();
                            fetchForecastData();
                            fetchHourlyForecastData();
                          });
                        },
                      ),
                    )
                  ],
                ),
              ],
            ),
          ),
          actions: [
            IconButton(
                onPressed: _showTemperatureUnitMenu,
                icon: const Icon(Icons.ballot_sharp),
                color: Colors.blue,
            ),
          ]
      ),

      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,

        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                location,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 40.0,
                ),
              ),
              const SizedBox(height: 0.00001),
              const CurrentDate(),
              const SizedBox(
                height: 35,
              ),

              Container(
                width: size.width,
                height: 200,
                decoration: BoxDecoration(
                  color: myConstants.primaryColor,
                  borderRadius: BorderRadius.circular(2),
                  boxShadow: [
                    BoxShadow(
                      color: myConstants.primaryColor.withOpacity(.5),
                      offset: const Offset(0, 25),
                      blurRadius: 10,
                      spreadRadius: -12,
                    )
                  ],
                ),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Positioned(
                      top: -35,
                      left: 10,
                      child: imageUrl == weatherStateName
                          ? const Text('')
                          : Image.asset(
                        getImageAssetPath(weatherStateName),
                        width: 150,
                      ),
                    ),
                    Positioned(
                      bottom: 30,
                      left: 20,
                      child: Text(
                        weatherStateName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                        ),
                      ),
                    ),
                    Positioned(
                      top: 20,
                      right: 5,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 4.0),
                            child: Text(
                              temperature.toStringAsFixed(1),
                              style: TextStyle(
                                fontSize: 60,
                                fontWeight: FontWeight.bold,
                                foreground: Paint()..shader = linearGradient,
                              ),
                            ),
                          ),
                          Text(
                            selectedTemperatureUnit == TemperatureUnit.Celsius ? '°C' : '°F',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 25,
                              foreground: Paint()
                                ..shader = linearGradient,
                            ),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const SizedBox(
                  height: 25,
                  child: Text(
                      'Weather Conditions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      )
                  )
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        weatherItem(
                          text: 'Wind Speed',
                          value: windSpeed,
                          unit: ' km/h',
                          imageUrl: 'assets/windspeed.png',
                        ),
                        weatherItem(
                          text: 'Humidity',
                          value: humidity,
                          unit: ' %',
                          imageUrl: 'assets/humidity.png',
                        ),
                        weatherItem(
                          text: 'Pressure',
                          value: pressure,
                          unit: ' hPa',
                          imageUrl: 'assets/pressure.png',
                        ),
                      ],
                    ),
                    const SizedBox(height: 10), // Add some spacing between rows
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        weatherItem(
                          value: clouds,
                          text: 'Cloudiness',
                          unit: ' %',
                          imageUrl: 'assets/clouds.png',
                        ),
                        weatherItem(value: visibility,
                          text: 'Visibility' ,
                          unit: ' m',
                          imageUrl: 'assets/visibility.png',
                        ),
                        weatherItem(
                          value: degree,
                          text: 'Wind Angle',
                          unit: ' °',
                          imageUrl: 'assets/sealevel.png',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              const SizedBox(height: 20),
              const SizedBox(
                height: 25,
                child: Text(
                  'Hourly Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Display hourly forecast
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: hourlyForecastList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        width: 150,
                        child: hourlyForecastWidget(
                          forecast: hourlyForecastList[index],
                          getImageAssetPath: getImageAssetPath,
                          index: index,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              const SizedBox(
                height: 30,
                child:
                Text(
                  'Weekly Forecast',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              // Display forecast for the next 5 days at 9:00:00
              Container(
                height: 150,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: forecastList.length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4.0),
                      child: SizedBox(
                        width: 150,
                        child: ForecastWidget(
                          forecast: forecastList[index],
                          getImageAssetPath: getImageAssetPath,
                          index: index,
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CurrentDate extends StatefulWidget {
  const CurrentDate({super.key});   //when we want to include parameters present in the superclass into the subclass

  @override
  _CurrentDateState createState() => _CurrentDateState();
}

class _CurrentDateState extends State<CurrentDate> {
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now(); // get the current date
    String currentDate = DateFormat('EEEE, MMMM d, y').format(now);

    // return a widget
    return Text(
      currentDate,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
