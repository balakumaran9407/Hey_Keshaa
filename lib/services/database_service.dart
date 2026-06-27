// ignore_for_file: avoid_print
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? get userId => FirebaseAuth.instance.currentUser?.uid;

  // Save scan data to Firestore
  Future<String?> saveScan({
    required double healthScore,
    required double moisture,
    required double temperature,
    required double pH,
    required double protein,
    String? notes,
  }) async {
    if (userId == null) return null;

    try {
      final docRef = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .add({
        'healthScore': healthScore,
        'moisture': moisture,
        'temperature': temperature,
        'pH': pH,
        'protein': protein,
        'notes': notes ?? '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      return docRef.id;
    } catch (e) {
      print('Error saving scan: $e');
      return null;
    }
  }

  // Get all scans for current user
  Stream<QuerySnapshot> getAllScans() {
    if (userId == null) {
      return const Stream.empty();
    }

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('scans')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }

  // Get latest scan
  Future<Map<String, dynamic>?> getLatestScan() async {
    if (userId == null) return null;

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (snapshot.docs.isNotEmpty) {
        return snapshot.docs.first.data();
      }
    } catch (e) {
      print('Error getting latest scan: $e');
    }
    return null;
  }

  // Delete a scan
  Future<bool> deleteScan(String scanId) async {
    if (userId == null) return false;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .doc(scanId)
          .delete();
      return true;
    } catch (e) {
      print('Error deleting scan: $e');
      return false;
    }
  }

  // Get scan statistics
  Future<Map<String, double>> getScanStatistics() async {
    if (userId == null) return {};

    try {
      final snapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('scans')
          .get();

      if (snapshot.docs.isEmpty) {
        return {
          'avgHealthScore': 0.0,
          'avgMoisture': 0.0,
          'avgTemperature': 0.0,
          'avgpH': 0.0,
          'avgProtein': 0.0,
          'totalScans': 0.0,
        };
      }

      double totalHealthScore = 0;
      double totalMoisture = 0;
      double totalTemperature = 0;
      double totalpH = 0;
      double totalProtein = 0;

      for (var doc in snapshot.docs) {
        final data = doc.data();
        totalHealthScore += (data['healthScore'] ?? 0).toDouble();
        totalMoisture += (data['moisture'] ?? 0).toDouble();
        totalTemperature += (data['temperature'] ?? 0).toDouble();
        totalpH += (data['pH'] ?? 0).toDouble();
        totalProtein += (data['protein'] ?? 0).toDouble();
      }

      int count = snapshot.docs.length;

      return {
        'avgHealthScore': totalHealthScore / count,
        'avgMoisture': totalMoisture / count,
        'avgTemperature': totalTemperature / count,
        'avgpH': totalpH / count,
        'avgProtein': totalProtein / count,
        'totalScans': count.toDouble(),
      };
    } catch (e) {
      print('Error getting statistics: $e');
      return {};
    }
  }

  // Save user profile
  Future<void> saveUserProfile({
    required String name,
    required String email,
    String? photoUrl,
    String? phoneNumber,
  }) async {
    if (userId == null) return;

    try {
      await _firestore.collection('users').doc(userId).set({
        'name': name,
        'email': email,
        'photoUrl': photoUrl ?? '',
        'phoneNumber': phoneNumber ?? '',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving profile: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (userId == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error getting profile: $e');
    }
    return null;
  }

  // Save user preferences
  Future<void> savePreferences({
    bool? notifications,
    bool? darkMode,
    String? language,
  }) async {
    if (userId == null) return;

    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .set({
        'notifications': notifications ?? true,
        'darkMode': darkMode ?? false,
        'language': language ?? 'en',
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      print('Error saving preferences: $e');
    }
  }

  // Get user preferences
  Future<Map<String, dynamic>?> getPreferences() async {
    if (userId == null) return null;

    try {
      final doc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('settings')
          .doc('preferences')
          .get();

      if (doc.exists) {
        return doc.data();
      }
    } catch (e) {
      print('Error getting preferences: $e');
    }
    return null;
  }
}
