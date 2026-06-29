import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:trabalho/models/location_model.dart';
import 'package:trabalho/pages/home.dart';
import 'package:trabalho/repository/location_repository.dart';

class Splash extends StatefulWidget {
  const Splash({Key? key}) : super(key: key);

  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void initState() {
    super.initState();

    Future<Position> p = _getPermissionForLocation();

    p.then((value) async {
      final location = LocationModel(
        latitude: value.latitude,
        longitude: value.longitude,
      );
      await LocationRepository.saveOrUpdateLocation(location);

      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    }).catchError((e) {
      debugPrint('Erro de localização: $e');
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const Home()),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnnotatedRegion<SystemUiOverlayStyle>(
        value: SystemUiOverlayStyle.dark,
        child: Container(
          color: Colors.white70,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wb_sunny, size: 75, color: Colors.orange),
                SizedBox(height: 16),
                Text(
                  'Previsão do Tempo',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<Position> _getPermissionForLocation() async {
    bool isLocationEnable = false;
    String MSG_ERRO = "Location permission are denied.";
    String MSG_FATAL_ERRO =
        "Location permissions are permanetly denied, we cannot request permissions.";
    LocationPermission permission;
    isLocationEnable = await Geolocator.isLocationServiceEnabled();

    if (!isLocationEnable) {
      return Future.error(MSG_ERRO);
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error(MSG_ERRO);
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(MSG_FATAL_ERRO);
    }

    return await Geolocator.getCurrentPosition();
  }
}
