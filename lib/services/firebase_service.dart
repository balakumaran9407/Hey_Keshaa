import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/scan_model.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user ID
  String? get currentUserId => _auth.currentUser?.uid;

  // Save scan to Firebase
  Future<void> saveScanToCloud(HairScan scan) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .doc(scan.id)
          .set(scan.toJson());
    } catch (e) {
      throw Exception('Failed to save scan to cloud: $e');
    }
  }

  // Get all scans from Firebase
  Future<List<HairScan>> getScansFromCloud() async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HairScan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get scans from cloud: $e');
    }
  }

  // Get scans stream (real-time updates)
  Stream<List<HairScan>> getScansStream() {
    if (currentUserId == null) throw Exception('User not logged in');

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => HairScan.fromJson(doc.data())).toList());
  }

  // Delete scan from Firebase
  Future<void> deleteScanFromCloud(String scanId) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .doc(scanId)
          .delete();
    } catch (e) {
      throw Exception('Failed to delete scan from cloud: $e');
    }
  }

  // Save user profile
  Future<void> saveUserProfile(Map<String, dynamic> userData) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .set(userData, SetOptions(merge: true));
    } catch (e) {
      throw Exception('Failed to save user profile: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      final docSnapshot =
          await _firestore.collection('users').doc(currentUserId).get();

      return docSnapshot.data();
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Sync local database with Firebase
  Future<void> syncScans(List<HairScan> localScans) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      // Upload local scans to Firebase
      final batch = _firestore.batch();

      for (var scan in localScans) {
        final docRef = _firestore
            .collection('users')
            .doc(currentUserId)
            .collection('scans')
            .doc(scan.id);

        batch.set(docRef, scan.toJson());
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to sync scans: $e');
    }
  }

  // Get scan statistics
  Future<Map<String, dynamic>> getScanStatistics() async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      final scans = await getScansFromCloud();

      if (scans.isEmpty) {
        return {
          'totalScans': 0,
          'avgTemperature': 0.0,
          'avgHumidity': 0.0,
          'avgMoisture': 0.0,
        };
      }

      double totalTemp = 0;
      double totalHumidity = 0;
      double totalMoisture = 0;

      for (var scan in scans) {
        totalTemp += scan.temperature;
        totalHumidity += scan.humidity;
        totalMoisture += scan.moisture;
      }

      return {
        'totalScans': scans.length,
        'avgTemperature': totalTemp / scans.length,
        'avgHumidity': totalHumidity / scans.length,
        'avgMoisture': totalMoisture / scans.length,
      };
    } catch (e) {
      throw Exception('Failed to get statistics: $e');
    }
  }

  // Get recent scans (last 7 days)
  Future<List<HairScan>> getRecentScans({int days = 7}) async {
    if (currentUserId == null) throw Exception('User not logged in');

    try {
      final startDate = DateTime.now().subtract(Duration(days: days));

      final querySnapshot = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('scans')
          .where('timestamp', isGreaterThan: startDate.toIso8601String())
          .orderBy('timestamp', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => HairScan.fromJson(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to get recent scans: $e');
    }
  }
}
