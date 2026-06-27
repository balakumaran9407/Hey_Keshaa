import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class SensorReading {
  final DateTime ts;
  final double temp;
  final double humidity;
  final double moisture;
  final double force;

  const SensorReading({
    required this.ts,
    required this.temp,
    required this.humidity,
    required this.moisture,
    required this.force,
  });
}

class BluetoothServiceESP32 extends ChangeNotifier {
  static final Guid serviceUuid = Guid("12345678-1234-1234-1234-123456789012");
  static final Guid charUuid = Guid("87654321-4321-4321-4321-210987654321");

  BluetoothDevice? _device;
  StreamSubscription<List<int>>? _notifySub;
  StreamSubscription<BluetoothConnectionState>? _connSub;

  bool _isConnected = false;
  String _deviceName = "";

  double _temperature = 0;
  double _humidity = 0;
  double _moisture = 0;
  double _accelerationX = 0;

  final List<SensorReading> _sensorHistory = [];

  bool get isConnected => _isConnected;
  String get deviceName => _deviceName.isEmpty ? "ESP32" : _deviceName;

  double get temperature => _temperature;
  double get humidity => _humidity;
  double get moisture => _moisture;
  double get accelerationX => _accelerationX;

  List<SensorReading> get sensorHistory => List.unmodifiable(_sensorHistory);

  double get hairHealthScore {
    double score = 100;

    if (_temperature > 35) score -= (_temperature - 35) * 2.0;
    if (_temperature < 28) score -= (28 - _temperature) * 1.5;

    if (_humidity > 70) score -= (_humidity - 70) * 0.8;
    if (_humidity < 40) score -= (40 - _humidity) * 0.8;

    if (_moisture > 80) score -= (_moisture - 80) * 0.6;
    if (_moisture < 30) score -= (30 - _moisture) * 0.9;

    if (_accelerationX > 16) score -= (_accelerationX - 16) * 1.2;

    if (score.isNaN || score.isInfinite) score = 0;
    if (score < 0) score = 0;
    if (score > 100) score = 100;
    return score;
  }

  Map<String, double> getAverageStats() {
    if (_sensorHistory.isEmpty) {
      return {
        'avgTemp': 0.0,
        'avgHumidity': 0.0,
        'avgMoisture': 0.0,
        'avgForce': 0.0,
      };
    }
    double t = 0, h = 0, m = 0, f = 0;
    for (final r in _sensorHistory) {
      t += r.temp;
      h += r.humidity;
      m += r.moisture;
      f += r.force;
    }
    final n = _sensorHistory.length.toDouble();
    return {
      'avgTemp': t / n,
      'avgHumidity': h / n,
      'avgMoisture': m / n,
      'avgForce': f / n,
    };
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    await disconnect();
    _device = device;

    try {
      await device.connect(timeout: const Duration(seconds: 15));
    } catch (_) {}

    _connSub?.cancel();
    _connSub = device.connectionState.listen((state) async {
      final connected = state == BluetoothConnectionState.connected;
      if (_isConnected != connected) {
        _isConnected = connected;
        notifyListeners();
      }

      if (connected) {
        _deviceName = device.platformName;
        notifyListeners();
        await _discoverAndSubscribe(device);
      } else {
        await _cleanupSubscriptions();
      }
    });

    notifyListeners();
  }

  Future<void> _discoverAndSubscribe(BluetoothDevice device) async {
    final services = await device.discoverServices();

    BluetoothCharacteristic? target;
    for (final s in services) {
      if (s.uuid == serviceUuid) {
        for (final c in s.characteristics) {
          if (c.uuid == charUuid) {
            target = c;
            break;
          }
        }
      }
    }

    if (target == null) return;

    _notifySub?.cancel();
    _notifySub = target.onValueReceived.listen((value) {
      _handleIncoming(value);
    });

    device.cancelWhenDisconnected(_notifySub!);
    await target.setNotifyValue(true);

    try {
      await target.read();
    } catch (_) {}
  }

  void _handleIncoming(List<int> value) {
    final text = utf8.decode(value, allowMalformed: true).trim();
    if (text.isEmpty) return;

    try {
      final obj = jsonDecode(text);
      final t = (obj['temp'] ?? obj['temperature'])?.toDouble();
      final h = (obj['humidity'])?.toDouble();
      final m = (obj['moisture'])?.toDouble();
      final force = (obj['accel_x'] ?? obj['accel_mag'])?.toDouble();

      if (t != null) _temperature = t;
      if (h != null) _humidity = h;
      if (m != null) _moisture = m;
      if (force != null) _accelerationX = force;

      _sensorHistory.add(SensorReading(
        ts: DateTime.now(),
        temp: _temperature,
        humidity: _humidity,
        moisture: _moisture,
        force: _accelerationX,
      ));
      if (_sensorHistory.length > 200) {
        _sensorHistory.removeRange(0, _sensorHistory.length - 200);
      }

      notifyListeners();
    } catch (_) {}
  }

  Future<void> disconnect() async {
    final d = _device;
    await _cleanupSubscriptions();
    _device = null;

    if (d != null) {
      try {
        await d.disconnect();
      } catch (_) {}
    }

    _isConnected = false;
    _deviceName = "";
    notifyListeners();
  }

  Future<void> _cleanupSubscriptions() async {
    await _notifySub?.cancel();
    _notifySub = null;

    await _connSub?.cancel();
    _connSub = null;
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}
