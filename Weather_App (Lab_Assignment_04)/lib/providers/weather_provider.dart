import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';

enum WeatherStatus { initial, loading, success, error }

class WeatherProvider extends ChangeNotifier {
  final WeatherService _service = WeatherService();

  WeatherStatus _status = WeatherStatus.initial;
  WeatherModel? _weather;
  String? _errorMessage;
  WeatherErrorType? _errorType;

  WeatherStatus get status => _status;
  WeatherModel? get weather => _weather;
  String? get errorMessage => _errorMessage;
  WeatherErrorType? get errorType => _errorType;

  Future<void> fetchWeather(String city) async {
    if (city.trim().isEmpty) {
      _status = WeatherStatus.error;
      _errorMessage = 'Please enter a city name.';
      _errorType = WeatherErrorType.unknown;
      notifyListeners();
      return;
    }

    _status = WeatherStatus.loading;
    _errorMessage = null;
    _errorType = null;
    notifyListeners();

    try {
      _weather = await _service.getWeatherByCity(city.trim());
      _status = WeatherStatus.success;
    } on WeatherException catch (e) {
      _status = WeatherStatus.error;
      _errorMessage = e.message;
      _errorType = e.type;
    }

    notifyListeners();
  }

  void reset() {
    _status = WeatherStatus.initial;
    _weather = null;
    _errorMessage = null;
    _errorType = null;
    notifyListeners();
  }
}
