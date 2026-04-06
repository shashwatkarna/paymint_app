import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

class UserProfile {
  final String uid;
  final String name;
  final int age;
  final String currency;

  UserProfile({
    required this.uid,
    required this.name,
    required this.age,
    this.currency = 'INR',
  });

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'name': name,
      'age': age,
      'currency': currency,
      'updatedAt': FieldValue.serverTimestamp(),
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map, String uid) {
    return UserProfile(
      uid: uid,
      name: map['name'] ?? 'User',
      age: map['age'] ?? 0,
      currency: map['currency'] ?? 'INR',
    );
  }
}

class UserService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save or update user profile
  Future<void> saveProfile(UserProfile profile) async {
    await _db.collection('users').doc(profile.uid).set(
      profile.toMap(),
      SetOptions(merge: true),
    );
  }

  // Get user profile
  Future<UserProfile?> getProfile(String uid) async {
    try {
      final doc = await _db.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, uid);
      }
    } catch (e) {
      debugPrint('Error getting profile: $e');
    }
    return null;
  }

  // Stream user profile
  Stream<UserProfile?> streamProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      if (doc.exists && doc.data() != null) {
        return UserProfile.fromMap(doc.data()!, uid);
      }
      return null;
    });
  }
}
