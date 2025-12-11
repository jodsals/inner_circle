import 'package:equatable/equatable.dart';

/// User roles in the application
enum UserRole {
  user,
  moderator,
  admin;

  /// Check if user has moderator or admin privileges
  bool get isModerator => this == UserRole.moderator || this == UserRole.admin;

  /// Check if user is admin
  bool get isAdmin => this == UserRole.admin;
}

/// User entity representing a user in the domain layer
/// This is the core business object with no dependencies on external frameworks
class User extends Equatable {
  final String id;
  final String email;
  final String? displayName;
  final String? photoUrl;
  final UserRole role;
  final bool isAnonymous;
  final DateTime? lastSurveyDate;
  final bool hasCompletedInitialSurvey;

  const User({
    required this.id,
    required this.email,
    this.displayName,
    this.photoUrl,
    this.role = UserRole.user,
    this.isAnonymous = false,
    this.lastSurveyDate,
    this.hasCompletedInitialSurvey = false,
  });

  /// Create a copy of this user with updated fields
  User copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoUrl,
    UserRole? role,
    bool? isAnonymous,
    DateTime? lastSurveyDate,
    bool? hasCompletedInitialSurvey,
  }) {
    return User(
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

  /// Check if user needs to complete weekly survey
  bool get needsWeeklySurvey {
    if (!hasCompletedInitialSurvey) return false;
    if (lastSurveyDate == null) return true;

    final daysSinceLastSurvey = DateTime.now().difference(lastSurveyDate!).inDays;
    return daysSinceLastSurvey >= 7;
  }

  @override
  List<Object?> get props => [
        id,
        email,
        displayName,
        photoUrl,
        role,
        isAnonymous,
        lastSurveyDate,
        hasCompletedInitialSurvey,
      ];

  @override
  String toString() => 'User(id: $id, email: $email, role: ${role.name})';
}
