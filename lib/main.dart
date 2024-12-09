import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  static final FirebaseService _instance = FirebaseService._internal();

  factory FirebaseService() => _instance;

  FirebaseService._internal() {
    Firebase.initializeApp(
      options: FirebaseOptions(
        apiKey: 'HGDwQCodRg4Q6BIICDYWL9XalZK4rIpds7JvMmCQ',
        appId: '1:878673350771:android:31c36c57af60ada3cbda06',
        messagingSenderId: '878673350771',
        projectId: 'air-quality-index-7396c',
        databaseURL:
            'https://air-quality-index-7396c-default-rtdb.firebaseio.com/',
      ),
    );
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Air Quality Index',
      color: Colors.white,
      theme: isDarkMode
          ? ThemeData.dark().copyWith(
              primaryColor: Colors.teal[700],
              hintColor: Colors.teal[200],
            )
          : ThemeData.light().copyWith(
              primaryColor: Colors.teal[700],
              hintColor: Colors.teal[200],
            ),
      home: AirQualityIndexPage(
        onThemeToggle: () {
          setState(() {
            isDarkMode = !isDarkMode;
          });
        },
      ),
    );
  }
}

class AirQualityIndexPage extends StatefulWidget {
  final Function onThemeToggle;

  AirQualityIndexPage({required this.onThemeToggle});

  @override
  _AirQualityIndexPageState createState() => _AirQualityIndexPageState();
}

class _AirQualityIndexPageState extends State<AirQualityIndexPage> {
  final databaseReference = FirebaseDatabase.instance.ref();
  double _temperature = 0;
  double _humidity = 0;
  double _pm1_0 = 0;
  double _pm2_5 = 0;
  double _pm10_0 = 0;
  double _co = 0;
  double _no2 = 0;
  double _smoke = 0;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() {
    databaseReference.child('temperature').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _temperature = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('humidity').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _humidity = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('PM1_0').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _pm1_0 = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('PM2_5').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _pm2_5 = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('PM10_0').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _pm10_0 = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('CO').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _co = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('NO2').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _no2 = double.parse(event.snapshot.value.toString());
        });
      }
    });
    databaseReference.child('Smoke').onValue.listen((event) {
      if (event.snapshot.value != null) {
        setState(() {
          _smoke = double.parse(event.snapshot.value.toString());
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Air Quality Index'),
        backgroundColor: Colors.teal[700],
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.brightness_6),
            onPressed: () {
              widget.onThemeToggle();
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              _headerCard(),
              SizedBox(height: 20),
              _weatherCard('Temperature', '$_temperature°C', Colors.blue),
              SizedBox(height: 20),
              _weatherCard('Humidity', '$_humidity%', Colors.blue),
              SizedBox(height: 20),
              _pmCard('PM1.0', 0),
              SizedBox(height: 20),
              _pmCard('PM2.5', 0),
              SizedBox(height: 20),
              _pmCard('PM10.0', 0),
              SizedBox(height: 20),
              _weatherCard('CO', '$_co', Colors.blue),
              SizedBox(height: 20),
              _weatherCard('NO2', '$_no2', Colors.blue),
              SizedBox(height: 20),
              _weatherCard('Smoke', '$_smoke', Colors.blue),
            ],
          ),
        ),
      ),
    );
  }

  Widget _headerCard() {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Text(
              'Air Quality Index',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Monitor the air quality in your area',
              style: TextStyle(fontSize: 18, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _weatherCard(String label, String value, Color color) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            Row(
              children: [
                Icon(_getIconForLabel(label), color: color),
                SizedBox(width: 10),
                Text(
                  label,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            Text(
              value,
              style: TextStyle(
                  fontSize: 18, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForLabel(String label) {
    switch (label) {
      case 'Temperature':
        return Icons.thermostat_outlined;
      case 'Humidity':
        return Icons.water_drop;
      case 'CO':
        return Icons.cloud;
      case 'NO2':
        return Icons.air;
      case 'Smoke':
        return Icons.smoking_rooms;
      default:
        return Icons.device_thermostat;
    }
  }

  Widget _pmCard(String label, double value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Text(
                  label,
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                Tooltip(
                  message: _getPmQuality(value),
                  child: Text(
                    value.toString(),
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[200],
              color: _getPmColor(value),
            ),
          ],
        ),
      ),
    );
  }

  String _getPmQuality(double value) {
    if (value <= 50) {
      return 'Good';
    } else if (value <= 100) {
      return 'Moderate';
    } else if (value <= 150) {
      return 'Unhealthy for Sensitive Groups';
    } else {
      return 'Unhealthy';
    }
  }

  Color _getPmColor(double value) {
    if (value <= 50) {
      return Colors.green;
    } else if (value <= 100) {
      return Colors.yellow;
    } else if (value <= 150) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
}
