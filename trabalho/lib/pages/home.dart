import 'package:flutter/material.dart';
import 'package:trabalho/models/weather_model.dart';
import 'package:trabalho/repository/location_repository.dart';
import 'package:trabalho/services/weather_service.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  bool _isLoading = true;
  WeatherModel? _weather;
  String? _erro;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _erro = null;
    });
    try {
      final location = await LocationRepository.getLocation();
      if (location == null) {
        setState(() => _erro = 'Localização não encontrada.');
        return;
      }
      final weather = await WeatherService.fetchWeatherByCoords(
        location.latitude!,
        location.longitude!,
      );
      setState(() => _weather = weather);
    } catch (e) {
      setState(() => _erro = 'Erro ao buscar previsão do tempo.');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1565C0),
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: Colors.white))
            : _erro != null
                ? _buildErro()
                : _buildConteudo(),
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, size: 64, color: Colors.white54),
          const SizedBox(height: 16),
          Text(
            _erro!,
            style: const TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _loadWeather,
            child: const Text('Tentar novamente'),
          ),
        ],
      ),
    );
  }

  Widget _buildConteudo() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          const Row(
            children: [
              Icon(Icons.location_on, color: Colors.white70, size: 18),
              SizedBox(width: 4),
              Text(
                'Sua localização',
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ],
          ),
          const SizedBox(height: 32),
          Center(
            child: Column(
              children: [
                const Icon(Icons.wb_sunny, size: 80, color: Colors.yellow),
                const SizedBox(height: 12),
                Text(
                  '${_weather!.temperature?.toStringAsFixed(0)}°C',
                  style: const TextStyle(
                    fontSize: 72,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 48),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfo(Icons.arrow_downward, '${_weather!.temperatureMin?.toStringAsFixed(0)}°', 'Mín'),
                _buildDivider(),
                _buildInfo(Icons.arrow_upward, '${_weather!.temperatureMax?.toStringAsFixed(0)}°', 'Máx'),
                _buildDivider(),
                _buildInfo(Icons.water_drop, '${_weather!.humidity}%', 'Humidade'),
                _buildDivider(),
                _buildInfo(Icons.air, '${_weather!.windSpeed?.toStringAsFixed(0)} km/h', 'Vento'),
              ],
            ),
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _buildInfo(IconData icon, String valor, String label) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: 20),
        const SizedBox(height: 6),
        Text(
          valor,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 12)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(width: 1, height: 40, color: Colors.white24);
  }
}
