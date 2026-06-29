import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:trabalho/models/weather_model.dart';

class WeatherService {
  static Future<WeatherModel> fetchWeatherByCoords(
    double lat,
    double lon,
  ) async {
    final url = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': lat.toString(),
      'longitude': lon.toString(),
      'current': 'temperature_2m,relative_humidity_2m,wind_speed_10m',
      'daily': 'temperature_2m_max,temperature_2m_min',
      'timezone': 'America/Sao_Paulo',
    });

    final response = await http.get(url);

    if (response.statusCode != 200) {
      throw Exception('Erro ao buscar clima: ${response.statusCode}');
    }

    debugPrint('Clima obtido para lat=$lat, lon=$lon');
    return WeatherModel.fromJson(jsonDecode(response.body));
  }

  static Future<WeatherModel> fetchWeatherByCity(String cityName) async {
    final geoUrl = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {'name': cityName, 'count': '1', 'language': 'pt', 'format': 'json'},
    );

    final geoResponse = await http.get(geoUrl);

    if (geoResponse.statusCode != 200) {
      throw Exception('Erro ao buscar coordenadas: ${geoResponse.statusCode}');
    }

    final geoJson = jsonDecode(geoResponse.body);

    if (geoJson['results'] == null || geoJson['results'].isEmpty) {
      throw Exception('Cidade não encontrada');
    }

    final double lat = geoJson['results'][0]['latitude'];
    final double lon = geoJson['results'][0]['longitude'];

    return fetchWeatherByCoords(lat, lon);
  }
}
