import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/notification_service.dart';
import '../../../core/services/weather_service.dart';

class StatusProvider with ChangeNotifier {
  String _status = 'stable';
  String _pathogenType = 'Optimal';
  double _score = 0.0;
  String _reasoning = 'Metrics within optimal baseline.';
  String _currentRegion = 'pune';
  
  // Real Weather Fields
  double _temperature = 28.0;
  double _humidity = 70.0;
  String _weatherDesc = 'Clear';
  
  // Engine 3.0 Fields
  String _safetyLabel = 'AREA STATUS: SAFE';
  String _stockLabel = 'High Stock';
  List<dynamic> _hospitals = [];
  String _preventiveMeasures = 'Continue normal hygiene practices.';
  
  StreamSubscription? _subscription;

  String get status => _status;
  String get pathogenType => _pathogenType;
  double get score => _score;
  String get reasoning => _reasoning;
  String get currentRegion => _currentRegion;
  double get temperature => _temperature;
  double get humidity => _humidity;
  String get weatherDesc => _weatherDesc;
  String get safetyLabel => _safetyLabel;
  String get stockLabel => _stockLabel;
  List<dynamic> get hospitals => _hospitals;
  String get preventiveMeasures => _preventiveMeasures;
  
  // Shift to Red (#D32F2F) for Danger
  Color get themeColor => _status == 'alert' ? const Color(0xFFD32F2F) : const Color(0xFF059669);

  StatusProvider() {
    _listenToStatus();
  }

  void setRegion(String region) {
    _currentRegion = region.toLowerCase().contains('mumbai') ? 'mumbai' : 'pune';
    _listenToStatus();
    _fetchLiveWeather(region);
  }

  Future<void> _fetchLiveWeather(String city) async {
    final weather = await WeatherService.fetchWeather(city);
    _temperature = weather['temp'];
    _humidity = weather['humidity'];
    _weatherDesc = weather['desc'];
    notifyListeners();
  }

  void _listenToStatus() {
    _subscription?.cancel();
    _subscription = FirebaseFirestore.instance
        .collection('regional_status')
        .doc(_currentRegion)
        .snapshots()
        .listen((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        
        final newStatus = data['status'] ?? 'stable';
        final newPathogen = data['pathogen_type'] ?? 'Optimal';
        
        if (newStatus == 'alert' && _status != 'alert') {
          NotificationService.showNotification(
            id: 1,
            title: "CRITICAL: ${newPathogen.toUpperCase()} ALERT",
            body: "Outbreak detected in ${_currentRegion.toUpperCase()}. Pulse Score: ${data['pulse_score']}%",
          );
        }
        
        _status = newStatus;
        _pathogenType = newPathogen;
        _score = (data['pulse_score'] ?? 0.0).toDouble();
        _reasoning = data['reasoning'] ?? '';
        
        // Engine 3.0 sync
        _safetyLabel = data['safety_label'] ?? 'AREA STATUS: SAFE';
        _stockLabel = data['stock_label'] ?? 'High Stock';
        _hospitals = data['hospitals'] ?? [];
        _preventiveMeasures = data['preventive_measures'] ?? 'Continue normal hygiene practices.';
        
        notifyListeners();
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
