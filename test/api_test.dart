import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

Future<Map<String, dynamic>> fetchWeatherData(String url) async {
  final mockResponse = {
    'weather': [{'description': 'clear sky'}],
    'main': {'temp': 289.0},
    'wind': {'speed': 2.0},
    'name': 'Dalat',
  };

  await Future.delayed(Duration(milliseconds: 100));

  return mockResponse;
}

void main() {
  test('Fetch weather data from API', () async {
    final String apiUrl = 'https://api.weather.com/data/2.5/weather?q=London&appid=e9f33111dca14bda992105426231112';

    final weatherData = await fetchWeatherData(apiUrl);

    expect(weatherData.containsKey('weather'), true);
    expect(weatherData.containsKey('main'), true);
    expect(weatherData.containsKey('wind'), true);
    expect(weatherData.containsKey('name'), true);
  });
}
