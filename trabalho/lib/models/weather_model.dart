class WeatherModel {
  double? temperature;
  double? windSpeed;
  double? temperatureMax;
  double? temperatureMin;
  int? humidity;

  WeatherModel({
    this.temperature,
    this.windSpeed,
    this.temperatureMax,
    this.temperatureMin,
    this.humidity,
  });

  WeatherModel.fromJson(Map<String, dynamic> json) {
    temperature = (json['current']['temperature_2m'] as num?)?.toDouble();
    windSpeed = (json['current']['wind_speed_10m'] as num?)?.toDouble();
    humidity = json['current']['relative_humidity_2m'];
    temperatureMax = (json['daily']['temperature_2m_max'][0] as num?)?.toDouble();
    temperatureMin = (json['daily']['temperature_2m_min'][0] as num?)?.toDouble();
  }
}
