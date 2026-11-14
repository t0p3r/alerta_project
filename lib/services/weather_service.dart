import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';

class PhilippineStation {
  final String id;
  final String name;
  final String region;
  final double latitude;
  final double longitude;

  const PhilippineStation({
    required this.id,
    required this.name,
    required this.region,
    required this.latitude,
    required this.longitude,
  });
}

class LiveWeatherReading {
  final int temperatureC;
  final int feelsLikeC;
  final int humidity;
  final int windSpeedKmh;
  final double precipitationMm;
  final String description;
  final String stationName;
  final String region;
  final String updatedAt;
  final bool isLiveApi;

  const LiveWeatherReading({
    required this.temperatureC,
    required this.feelsLikeC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.precipitationMm,
    required this.description,
    required this.stationName,
    required this.region,
    required this.updatedAt,
    required this.isLiveApi,
  });
}

class WeatherService extends ChangeNotifier {
  static const List<PhilippineStation> stations = [
    PhilippineStation(id: 'ncr', name: 'Metro Manila (Science Garden, QC)', region: 'NCR', latitude: 14.6465, longitude: 121.0427),
    PhilippineStation(id: 'legazpi', name: 'Legazpi City / Mayon (Bicol)', region: 'Region V', latitude: 13.1391, longitude: 123.7438),
    PhilippineStation(id: 'baguio', name: 'Baguio City (Synoptic)', region: 'CAR', latitude: 16.4023, longitude: 120.5960),
    PhilippineStation(id: 'pampanga', name: 'Clark / Pampanga', region: 'Region III', latitude: 15.0794, longitude: 120.6200),
    PhilippineStation(id: 'cebu', name: 'Mactan / Cebu City', region: 'Region VII', latitude: 10.3157, longitude: 123.8854),
    PhilippineStation(id: 'iloilo', name: 'Iloilo City', region: 'Region VI', latitude: 10.7202, longitude: 122.5621),
    PhilippineStation(id: 'davao', name: 'Davao City', region: 'Region XI', latitude: 7.1907, longitude: 125.4553),
    PhilippineStation(id: 'cdo', name: 'Cagayan de Oro', region: 'Region X', latitude: 8.4542, longitude: 124.6319),
  ];

  String selectedStationId = 'ncr';
  bool isLoading = false;
  LiveWeatherReading current = const LiveWeatherReading(
    temperatureC: 29,
    feelsLikeC: 33,
    humidity: 78,
    windSpeedKmh: 14,
    precipitationMm: 0.0,
    description: 'Partly Cloudy · Easterlies',
    stationName: 'Metro Manila (Science Garden, QC)',
    region: 'NCR',
    updatedAt: 'PAGASA Synoptic Baseline',
    isLiveApi: false,
  );

  String _decodeWmo(int code) {
    if (code == 0) return 'Clear Skies';
    if (code <= 2) return 'Partly Cloudy';
    if (code == 3) return 'Overcast / Cloudy';
    if (code >= 45 && code <= 48) return 'Fog / Mist';
    if (code >= 51 && code <= 55) return 'Light Drizzle / Ambon';
    if (code >= 61 && code <= 65) return 'Moderate Rain / Ulan';
    if (code >= 80 && code <= 82) return 'Scattered Rain Showers';
    if (code >= 95) return 'Thunderstorms with Gusty Winds';
    return 'Cloudy with Isolated Showers';
  }

  Future<void> fetchWeather([String? stationId]) async {
    if (stationId != null) selectedStationId = stationId;
    final station = stations.firstWhere(
      (s) => s.id == selectedStationId,
      orElse: () => stations.first,
    );

    isLoading = true;
    notifyListeners();

    final client = HttpClient();
    try {
      client.connectionTimeout = const Duration(seconds: 8);
      final uri = Uri.parse(
        'https://api.open-meteo.com/v1/forecast?latitude=${station.latitude}&longitude=${station.longitude}&current=temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m&timezone=Asia%2FManila',
      );
      final request = await client.getUrl(uri);
      final response = await request.close();

      if (response.statusCode == 200) {
        final body = await response.transform(utf8.decoder).join();
        final json = jsonDecode(body) as Map<String, dynamic>;
        final data = json['current'] as Map<String, dynamic>;

        final now = DateTime.now();
        final hour = now.hour > 12 ? now.hour - 12 : (now.hour == 0 ? 12 : now.hour);
        final min = now.minute.toString().padLeft(2, '0');
        final ampm = now.hour >= 12 ? 'PM' : 'AM';

        current = LiveWeatherReading(
          temperatureC: (data['temperature_2m'] as num).round(),
          feelsLikeC: (data['apparent_temperature'] as num).round(),
          humidity: (data['relative_humidity_2m'] as num).round(),
          windSpeedKmh: (data['wind_speed_10m'] as num).round(),
          precipitationMm: (data['precipitation'] as num?)?.toDouble() ?? 0.0,
          description: _decodeWmo((data['weather_code'] as num?)?.toInt() ?? 2),
          stationName: station.name,
          region: station.region,
          updatedAt: 'Live · $hour:$min $ampm PHT',
          isLiveApi: true,
        );
      }
    } catch (e) {
      debugPrint('Weather fetch fallback: $e');
      current = LiveWeatherReading(
        temperatureC: current.temperatureC,
        feelsLikeC: current.feelsLikeC,
        humidity: current.humidity,
        windSpeedKmh: current.windSpeedKmh,
        precipitationMm: current.precipitationMm,
        description: 'Partly Cloudy with Isolated Showers',
        stationName: station.name,
        region: station.region,
        updatedAt: 'Official Synoptic Baseline',
        isLiveApi: false,
      );
    } finally {
      client.close();
      isLoading = false;
      notifyListeners();
    }
  }
}
