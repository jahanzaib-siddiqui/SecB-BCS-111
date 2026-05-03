import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {
  static const String _apiKey = '75a71c43f3ec75a8460624b738bc4bc1'; // 🔑 OpenWeatherMap API key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  Future<WeatherModel> getWeatherByCity(String city) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?q=${Uri.encodeComponent(city)}&appid=$_apiKey&units=metric',
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      return _parseResponse(response);
    } on SocketException {
      throw WeatherException(
        'No internet connection. Please check your network and try again.',
        type: WeatherErrorType.noInternet,
      );
    } on HttpException {
      throw WeatherException(
        'Could not connect to weather service. Please try again later.',
        type: WeatherErrorType.serverError,
      );
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException(
        'An unexpected error occurred. Please try again.',
        type: WeatherErrorType.unknown,
      );
    }
  }

  Future<WeatherModel> getWeatherByCoords(double lat, double lon) async {
    try {
      final uri = Uri.parse(
        '$_baseUrl?lat=$lat&lon=$lon&appid=$_apiKey&units=metric',
      );

      final response = await http
          .get(uri)
          .timeout(const Duration(seconds: 10));

      return _parseResponse(response);
    } on SocketException {
      throw WeatherException(
        'No internet connection. Please check your network and try again.',
        type: WeatherErrorType.noInternet,
      );
    } catch (e) {
      if (e is WeatherException) rethrow;
      throw WeatherException(
        'An unexpected error occurred. Please try again.',
        type: WeatherErrorType.unknown,
      );
    }
  }

  WeatherModel _parseResponse(http.Response response) {
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return WeatherModel.fromJson(json);
    } else if (response.statusCode == 401) {
      throw WeatherException(
        'Invalid API key. Please check your OpenWeatherMap API key.',
        type: WeatherErrorType.invalidApiKey,
      );
    } else if (response.statusCode == 404) {
      throw WeatherException(
        'City not found. Please check the city name and try again.',
        type: WeatherErrorType.cityNotFound,
      );
    } else if (response.statusCode == 429) {
      throw WeatherException(
        'API limit exceeded. Please try again later.',
        type: WeatherErrorType.rateLimited,
      );
    } else {
      throw WeatherException(
        'Server error (${response.statusCode}). Please try again later.',
        type: WeatherErrorType.serverError,
      );
    }
  }
}

enum WeatherErrorType {
  noInternet,
  cityNotFound,
  invalidApiKey,
  serverError,
  rateLimited,
  unknown,
}

class WeatherException implements Exception {
  final String message;
  final WeatherErrorType type;

  WeatherException(this.message, {required this.type});

  @override
  String toString() => message;
}
