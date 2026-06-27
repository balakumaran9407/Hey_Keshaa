import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:provider/provider.dart';

import '../services/bluetooth_service.dart';

class BluetoothDevicesScreen extends StatefulWidget {
  const BluetoothDevicesScreen({super.key});

  @override
  State<BluetoothDevicesScreen> createState() => _BluetoothDevicesScreenState();
}

class _BluetoothDevicesScreenState extends State<BluetoothDevicesScreen> {
  final Map<String, ScanResult> _unique = {};
  StreamSubscription<List<ScanResult>>? _scanSub;
  bool _isScanning = false;

  @override
  void initState() {
    super.initState();

    // Real-time scan results
    _scanSub = FlutterBluePlus.onScanResults.listen((results) {
      for (final r in results) {
        // TEMP: keep all devices so you can see if scan works at all
        _unique[r.device.remoteId.str] = r;

        // If you want to filter only your comb later, use:
        //
        // final hasService = r.advertisementData.serviceUuids.any(
        //   (u) =>
        //       u.toString().toLowerCase() ==
        //       BluetoothServiceESP32.serviceUuid
        //           .toString()
        //           .toLowerCase(),
        // );
        // final looksLikeComb = advName.contains("HeyKeshaa") ||
        //     r.device.platformName.contains("HeyKeshaa");
        // if (hasService || looksLikeComb) {
        //   _unique[r.device.remoteId.str] = r;
        // }
      }
      if (mounted) setState(() {});
    }, onError: (e) {
      debugPrint("Scan error: $e");
    });

    _startScan();
  }

  @override
  void dispose() {
    _scanSub?.cancel();
    FlutterBluePlus.stopScan();
    super.dispose();
  }

  Future<void> _startScan() async {
    if (_isScanning) return;

    debugPrint("🔍 START SCAN");
    setState(() {
      _isScanning = true;
      _unique.clear();
    });

    try {
      // No filter for now so we see ALL BLE devices
      await FlutterBluePlus.startScan(
        timeout: const Duration(seconds: 12),
        // withServices: [BluetoothServiceESP32.serviceUuid],
      );

      await FlutterBluePlus.isScanning.where((v) => v == false).first;
    } catch (e) {
      debugPrint("startScan error: $e");
    }

    debugPrint("✅ SCAN FINISHED, found=${_unique.length}");
    if (mounted) setState(() => _isScanning = false);
  }

  @override
  Widget build(BuildContext context) {
    final results = _unique.values.toList()
      ..sort((a, b) => b.rssi.compareTo(a.rssi));

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Select Device',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _isScanning ? null : _startScan,
            icon: Icon(
              _isScanning ? Icons.hourglass_empty : Icons.refresh,
              color: _isScanning ? Colors.grey : Colors.black,
            ),
          ),
        ],
      ),
      body: results.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _isScanning
                        ? Icons.bluetooth_searching
                        : Icons.bluetooth_disabled,
                    size: 64,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _isScanning
                        ? "Scanning for devices..."
                        : "No devices found.\nTap refresh to scan again.",
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            )
          : ListView.separated(
              itemCount: results.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, i) {
                final r = results[i];
                final name = r.advertisementData.advName.isNotEmpty
                    ? r.advertisementData.advName
                    : (r.device.platformName.isNotEmpty
                        ? r.device.platformName
                        : "Unnamed Device");

                return ListTile(
                  leading: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6C63FF).withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.bluetooth,
                      color: Color(0xFF6C63FF),
                    ),
                  ),
                  title: Text(
                    name,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  subtitle: Text(
                    "${r.device.remoteId.str}\nSignal: ${r.rssi} dBm",
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () async {
                    final bt = context.read<BluetoothServiceESP32>();

                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(
                        child: Card(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                CircularProgressIndicator(),
                                SizedBox(height: 16),
                                Text("Connecting..."),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );

                    await bt.connectToDevice(r.device);

                    if (context.mounted) {
                      Navigator.pop(context); // dialog
                      Navigator.pop(context); // screen
                    }
                  },
                );
              },
            ),
    );
  }
}
