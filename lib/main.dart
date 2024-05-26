import 'dart:math';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'login.dart';
import 'register.dart';
import 'package:intl/intl.dart';
import 'news_screen.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/cupertino.dart';
import 'package:mysql1/mysql1.dart';

const String apiKey = 'e9f33111dca14bda992105426231112';
const String baseUrl = 'http://api.weatherapi.com/v1/forecast.json';

void main() {
  runApp(MyApp());
}


class MyApp extends StatelessWidget {
  bool isLoggedIn = false;
  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    int hour = now.hour;

    Color backgroundColor;
    Color textColor;
    ThemeData myTheme = ThemeData();

    if (hour >= 6 && hour < 24) {
      myTheme = myTheme.copyWith(
        scaffoldBackgroundColor: Color(0xFF5991E1).withAlpha(3000),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF5991E1).withAlpha(3000)),
        textTheme: TextTheme(bodyText2: TextStyle(color: Color(0xFFFFFFe6))),
      );
    } else {
      myTheme = myTheme.copyWith(
        scaffoldBackgroundColor: Color(0xFF140029).withAlpha(3000),
        appBarTheme: AppBarTheme(backgroundColor: Color(0xFF140029).withAlpha(3000)),
        textTheme: TextTheme(bodyText2: TextStyle(color: Color(0xFFFFFFe6))),
      );
    }

    return MaterialApp(
      theme: myTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => WeatherApp(),
        '/register': (context) => RegisterScreen(),
        '/login': (context) => LoginScreen(),
      },
    );
  }
}

class CustomDrawer extends StatelessWidget {
  final Function showLocationDialog;

  CustomDrawer(this.showLocationDialog);
  @override
  Widget build(BuildContext context) {
    final deviceWidth = MediaQuery.of(context).size.width;
    final drawerWidth = min(230.0, deviceWidth * 0.7);

    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.75),
        border: Border.all(color: Colors.blue.withOpacity(0.6)),
        borderRadius: BorderRadius.only(
          topRight: Radius.circular(100.0),
          bottomRight: Radius.circular(100.0),
          bottomLeft: Radius.circular(100.0),
        ),
      ),
      width: drawerWidth,
      child: Column(
        children: <Widget>[
          Container(
            height: 50,
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: <Widget>[
                SizedBox(height: 10.0,),
                ListTile(
                  title: Text(
                    'Choose/Add location',
                    style: TextStyle(color: Colors.white, fontSize: 18),
                  ),
                  onTap: () {
                    showLocationDialog(context);
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}


class WeatherDayInfo {
  final String date;
  final String maxTemp;
  final String minTemp;
  final String humidity;
  final String precipMm;

  WeatherDayInfo({
    required this.date,
    required this.maxTemp,
    required this.minTemp,
    required this.humidity,
    required this.precipMm,
  });
}

class WeatherInfoContainer extends StatelessWidget {
  final String time;
  final String temperature;
  final String humidity;
  final String precipMm;
  final List<FlSpot> temperatureSpots;

  WeatherInfoContainer({
    required this.time,
    required this.temperature,
    required this.humidity,
    required this.precipMm,
    required this.temperatureSpots,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400.0,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70),
        color: Colors.blue.withOpacity(0.3),
        borderRadius: BorderRadius.circular(10.0),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.view_headline_outlined,
                    size: 10.0,
                    color: Colors.lightBlue,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    precipMm,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text("Today's weather diagram",
                    style: TextStyle(
                      fontSize: 12.0,
                    ),
                  )
                ],
              ),
              Row(
                children: [
                  Icon(
                    Icons.opacity,
                    size: 10.0,
                    color: Colors.lightBlue,
                  ),
                  SizedBox(width: 4.0),
                  Text(
                    humidity,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 10.0,
                    ),
                  ),
                ],
              ),
            ],
          ),

          SizedBox(height: 12.0),
          Container(
            height: 90.0,
            child: LineChart(
              LineChartData(
                titlesData: FlTitlesData(
                  leftTitles: SideTitles(showTitles: false),
                  bottomTitles: SideTitles(showTitles: false),
                ),
                borderData: FlBorderData(show: false),
                gridData: FlGridData(show: false),
                lineBarsData: [
                  LineChartBarData(
                    spots: temperatureSpots,
                    isCurved: true,
                    belowBarData: BarAreaData(show: false),
                    dotData: FlDotData(
                      show: false,
                      getDotPainter: (spot, percent, barData, index) {
                        return FlDotCirclePainter(
                          radius: 1.7,
                          color: Colors.blue,
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
class WeatherApp extends StatefulWidget {
  @override
  _WeatherAppState createState() => _WeatherAppState();
}

class _WeatherAppState extends State<WeatherApp> {
  String selectedLocation = 'Da lat';
  bool _showTemperatureChart = false;
  String temperature = '';
  String conditionInfo = '';
  String forecastInfo = '';
  String humidity = '';
  String maxTemperature = '';
  String minTemperature = '';
  String uvIndex = '';
  String windSpeed = '';
  String drivingDifficulty = '';
  String visibility = '';
  String moonPhase = '';
  String feelsLike = '';
  bool _isRefreshing = false;
  String precipMm = '';
  List<WeatherDayInfo> _weatherInfoList = [];
  String _getDayOfWeek(String date) {
    DateTime dateTime = DateTime.parse(date);
    List<String> daysOfWeek = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    return daysOfWeek[dateTime.weekday - 1];
  }

  List<FlSpot> _temperatureSpots = [];


  Future<void> _fetchWeatherData() async {
    setState(() {
      _isRefreshing = true;
    });
    final response =
    await http.get(Uri.parse('$baseUrl?key=$apiKey&q=$selectedLocation&days=3'));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = jsonDecode(response.body);
      setState(() {
        temperature = '${(data['current']['temp_c'] as double).ceil()}°C';
        conditionInfo = data['current']['condition']['text'];
        humidity = '${data['current']['humidity']}%';
        maxTemperature =
        '${((data['forecast']['forecastday'][0]['day']['maxtemp_c'] as double).ceil())}°C';
        minTemperature =
        '${((data['forecast']['forecastday'][0]['day']['mintemp_c'] as double).ceil())}°C';
        uvIndex = '${data['current']['uv']}';
        windSpeed = '${data['current']['wind_kph']} km/h';
        drivingDifficulty =
        '${_calculateDrivingDifficulty(data['current']['wind_kph'])}';
        visibility = '${data['current']['vis_miles']} m';
        moonPhase = '${data['forecast']['forecastday'][0]['astro']['moon_phase']}';
        feelsLike = '${((data['current']['feelslike_c']) as double).ceil()}°C';
        String formattedTime = DateFormat('H:mm').format(DateTime.now());
        forecastInfo = '$formattedTime\nCurrent weather:';
        _temperatureSpots = _createTemperatureSpots(data);
        precipMm = '${data['current']['precip_mm']} mm';
        _weatherInfoList.clear();

        List<dynamic> forecastDays = data['forecast']['forecastday'];
        for (var days in forecastDays) {
          WeatherDayInfo weatherDayInfo = WeatherDayInfo(
            date: days['date'],
            maxTemp: '${((days['day']['maxtemp_c'] as double).ceil())}°C',
            minTemp: '${((days['day']['mintemp_c'] as double).ceil())}°C',
            humidity: '${days['day']['avghumidity']}%',
            precipMm: '${days['day']['totalprecip_mm']} mm',
          );
          _weatherInfoList.add(weatherDayInfo);
        }
      });
    } else {
      throw Exception('Failed to load weather data');
    }


    setState(() {
      _isRefreshing = false;
    });
  }

  Future<void> saveToDatabase(String location) async {
    try {
      final MySqlConnection connection = await MySqlConnection.connect(ConnectionSettings(
        host: 'inus-users.ckjforryv7ff.ap-southeast-1.rds.amazonaws.com',
        port: 3306,
        user: 'admin',
        password: '01234567',
        db: 'weather_news',
      ));

      await connection.query(
          'INSERT INTO Locations (LocationName) VALUES (?)',
          [location]);

      await connection.close();
    } catch (e) {
      print('Error: Unable to connect to the database. $e');
    }
  }


  void _showLocationDialog(BuildContext context) {
    TextEditingController locationController = TextEditingController();
    locationController.text = selectedLocation;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
          ),
          backgroundColor: Colors.grey.withAlpha(500),
          title: Text('Choose/Add Location'),
          content: TextField(
            controller: locationController,
            decoration: InputDecoration(labelText: 'Enter location'),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('OK'),
              onPressed: () {
                setState(() {
                  selectedLocation = locationController.text;
                });
                _fetchWeatherData();
                Navigator.of(context).pop();
                saveToDatabase(selectedLocation);
              },
            ),
          ],
        );
      },
    );
  }

  String _calculateDrivingDifficulty(double windSpeed) {
    if (windSpeed < 10) {
      return 'Low';
    } else if (windSpeed < 25) {
      return 'Moderate';
    } else {
      return 'High';
    }
  }

  List<FlSpot> _createTemperatureSpots(Map<String, dynamic> data) {
    List<FlSpot> spots = [];

    List<dynamic> hourly = data['forecast']['forecastday'][0]['hour'];

    for (int i = 0; i < hourly.length; i++) {
      double temp = (hourly[i]['temp_c'] as double).toDouble();
      spots.add(FlSpot(i.toDouble(), temp));
    }

    return spots;
  }

  Future<void> _refreshData() async {
    await _fetchWeatherData();
  }

  @override
  void initState() {
    super.initState();
    _fetchWeatherData();
  }

  String _getGifForTime() {
    DateTime now = DateTime.now();
    int hour = now.hour;
    String weatherCondition = conditionInfo.toLowerCase();

    if (weatherCondition.contains("rain") || weatherCondition.contains("sleet") || weatherCondition.contains("freezing drizzle") || weatherCondition.contains("light drizzle") || weatherCondition.contains("freezing drizzle") || weatherCondition.contains("freezing drizzle") ) {
      if (hour >= 6 && hour < 12) {
        return 'assets/images/morning-rain.jpg';
      } else if (hour >= 12 && hour < 17) {
        return 'assets/images/afternoon-rain.jpg';
      } else if (hour >= 17 && hour < 20) {
        return 'assets/images/evening-rain.jpg';
      } else {
        return 'assets/images/night-rain.jpg';
      }
    } else {
      if (hour >= 6 && hour < 12) {
        return 'assets/images/morning.jpg';
      } else if (hour >= 12 && hour < 17) {
        return 'assets/images/afternoon.jpg';
      } else if (hour >= 17 && hour < 20) {
        return 'assets/images/evening.jpg';
      } else {
        return 'assets/images/night.jpg';
      }
    }
  }

  Widget _buildInfoLabel(IconData icon, String title, String value) {
    return Container(
      width: 100.0,
      height: 112.0,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.white70),
        borderRadius: BorderRadius.circular(10.0),
      ),
      padding: const EdgeInsets.all(8.0),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Icon(
              icon,
              color: Colors.white,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 24.0),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4.0),
              Text(
                value,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: Container(
          padding: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.wb_sunny,
                        size: 38.0,
                        color: Colors.yellowAccent,
                      ),
                      onPressed: () {},
                    ),
                  ),
                  SizedBox(width: 100),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 0.0),
                    child: IconButton(
                      icon: Icon(
                        Icons.newspaper,
                        size: 38.0,
                        color: Colors.blueAccent,
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => NewsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),
              SizedBox(height: 0.0),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Weather',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 100),
                  Text(
                    'News',
                    style: TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ],
          ),
        ),
        actions: [],
      ),
      drawer: CustomDrawer(_showLocationDialog),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      temperature,
                      style: TextStyle(
                          fontSize: 40.0,
                          fontFamily: "roboto"),
                    ),
                    Container(
                      width: 250.0,
                      height: 250.0,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20.0),
                        child: Image.asset(
                          _getGifForTime(),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 16.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.location_on, size: 20, color: Colors.white,),
                        Text('$selectedLocation', style: TextStyle(fontSize: 20, fontStyle: FontStyle.italic)),
                      ],
                    ),
                    Text('\nCondition Info: $conditionInfo', style: TextStyle(fontSize: 16)),
                  ],
                ),
                SizedBox(height: 16.0),
                Container(
                  height: 452.0,
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            forecastInfo,
                            style: TextStyle(fontSize: 20.0),
                          ),
                          _isRefreshing
                              ? CircularProgressIndicator()
                              : IconButton(
                            icon: Icon(
                              Icons.refresh,
                              color: Colors.white,
                            ),
                            onPressed: _refreshData,
                          )
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoLabel(Icons.water_drop,'Humidity', humidity),
                          _buildInfoLabel(Icons.whatshot,'Max Temp', maxTemperature),
                          _buildInfoLabel(Icons.ac_unit,'Min Temp', minTemperature),
                        ],
                      ),
                      SizedBox(height: 8.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoLabel(Icons.bedtime,'Moon', moonPhase),
                          _buildInfoLabel(Icons.air,'Wind Speed', windSpeed),
                          _buildInfoLabel(Icons.directions_car_filled,'Driving Difficutly', drivingDifficulty),
                        ],
                      ),
                      SizedBox(height: 8.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildInfoLabel(Icons.visibility,'Visibility', visibility),
                          _buildInfoLabel(Icons.wb_sunny_rounded,'UV Index', uvIndex),
                          _buildInfoLabel(Icons.thermostat_rounded,'Feels Like', feelsLike),
                        ],
                      ),
                      SizedBox(height: 8.0),
                    ],
                  ),
                ),
                SizedBox(height: 16.0),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: WeatherInfoContainer(
                      time: DateTime.now().toString(),
                      temperature: temperature,
                      precipMm: precipMm,
                      humidity: humidity,
                      temperatureSpots: _temperatureSpots,
                    ),
                  ),
                ),
                SizedBox(height: 16.0),
                SingleChildScrollView(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.blueAccent.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Text('Weather forecast for the next 3 days',
                          style: TextStyle(
                              fontWeight: FontWeight.bold),
                        ),
                        ..._weatherInfoList.map((weatherInfo) {
                          return Card(
                            color: Colors.grey.withOpacity(0.1),
                            elevation: 4.0,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.0),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16.0),
                              title: Text(
                                '${_getDayOfWeek(weatherInfo.date)}',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20.0,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '${weatherInfo.maxTemp}/${weatherInfo.minTemp}',
                                        style: TextStyle(
                                          fontSize: 18.0,
                                        ),
                                      ),
                                      Text(
                                        'Humidity: ${weatherInfo.humidity}',
                                        style: TextStyle(
                                          fontSize: 16.0,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8.0),
                                  Text(
                                    'Precipitation: ${weatherInfo.precipMm}',
                                    style: TextStyle(
                                      fontSize: 16.0,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}