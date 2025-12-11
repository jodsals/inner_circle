import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../domain/entities/user.dart';

/// Data Transfer Object (DTO) for User
/// Handles conversion between Firebase and Domain entities
class UserModel extends User {
  const UserModel({
    required super.id,
    required super.email,
    super.displayName,
    super.photoUrl,
    super.role,
    super.isAnonymous,
    super.lastSurveyDate,
    super.hasCompletedInitialSurvey,
  });

  /// Create UserModel from Firebase Auth User
  factory UserModel.fromFirebaseAuth(firebase_auth.User firebaseUser) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoUrl: firebaseUser.photoURL,
      isAnonymous: firebaseUser.isAnonymous,
      role: UserRole.user, // Default role, will be fetched from Firestore
    );
  }

  /// Create UserModel from Firestore DocumentSnapshot
  factory UserModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return UserModel(
      id: doc.id,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String?,
      photoUrl: data['photoUrl'] as String?,
      role: _parseRole(data['role'] as String?),
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      lastSurveyDate: (data['lastSurveyDate'] as Timestamp?)?.toDate(),
      hasCompletedInitialSurvey:
          data['hasCompletedInitialSurvey'] as bool? ?? false,
    );
  }

  /// Create UserModel from Map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as String,
      email: map['email'] as String,
      displayName: map['displayName'] as String?,
      photoUrl: map['photoUrl'] as String?,
      role: _parseRole(map['role'] as String?),
      isAnonymous: map['isAnonymous'] as bool? ?? false,
      lastSurveyDate: map['lastSurveyDate'] != null
          ? DateTime.parse(map['lastSurveyDate'] as String)
          : null,
      hasCompletedInitialSurvey:
          map['hasCompletedInitialSurvey'] as bool? ?? false,
    );
  }

  /// Convert to Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'isAnonymous': isAnonymous,
      'lastSurveyDate':
          lastSurveyDate != null ? Timestamp.fromDate(lastSurveyDate!) : null,
      'hasCompletedInitialSurvey': hasCompletedInitialSurvey,
      'createdAt': FieldValue.serverTimestamp(),
      'lastLogin': FieldValue.serverTimestamp(),
    };
  }

  /// Convert to Map for local storage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'role': role.name,
      'isAnonymous': isAnonymous,
      'lastSurveyDate': lastSurveyDate?.toIso8601String(),
      'hasCompletedInitialSurvey': hasCompletedInitialSurvey,
    };
  }

  /// Parse UserRole from string
  static UserRole _parseRole(String? roleString) {
    if (roleString == null) return UserRole.user;
    try {
      return UserRole.values.byName(roleString);
    } catch (e) {
      return UserRole.user;
    }
  }

  /// Create a copy with updated fields
  @override
  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    bool? isAnonymous,
    DateTime? lastSurveyDate,
    bool? hasCompletedInitialSurvey,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      role: role ?? this.role,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      lastSurveyDate: lastSurveyDate ?? this.lastSurveyDate,
      hasCompletedInitialSurvey:
          hasCompletedInitialSurvey ?? this.hasCompletedInitialSurvey,
    );
  }
}
