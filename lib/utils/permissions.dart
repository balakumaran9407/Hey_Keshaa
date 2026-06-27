// ignore_for_file: avoid_print
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestBluetoothPermissions() async {
  if (kIsWeb) return;
  final result = await <Permission>[
    Permission.bluetoothScan,
    Permission.bluetoothConnect,
    Permission.locationWhenInUse, // fine location
    Permission.location, // fallback
  ].request();

  final scanOk = result[Permission.bluetoothScan]?.isGranted ?? false;
  final connOk = result[Permission.bluetoothConnect]?.isGranted ?? false;
  final locWhenUseOk = result[Permission.locationWhenInUse]?.isGranted ?? false;
  final locOk = result[Permission.location]?.isGranted ?? false;

  print("Scan granted: $scanOk");
  print("Connect granted: $connOk");
  print("LocationWhenInUse granted: $locWhenUseOk");
  print("Location granted: $locOk");
}
