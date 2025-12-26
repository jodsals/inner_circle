/// User's response to a survey
class SurveyResponse {
  final String id;
  final String userId;
  final String surveyId;
  final SurveyType type;
  final DateTime completedAt;
  final DateTime? startedAt;
  final Map<String, double> domainScores;
  final List<QuestionResponse> responses;
  final AppEffectivenessResponse? appFeedback;
  final bool isComplete;

  const SurveyResponse({
    required this.id,
    required this.userId,
    required this.surveyId,
    required this.type,
    required this.completedAt,
    this.startedAt,
    required this.domainScores,
    required this.responses,
    this.appFeedback,
    this.isComplete = false,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyResponse &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Type of survey
enum SurveyType {
  baseline,  // T0 - at registration
  followup,  // T1 - after 8 weeks
}

extension SurveyTypeExtension on SurveyType {
  String get displayName {
    switch (this) {
      case SurveyType.baseline:
        return 'Baseline-Fragebogen';
      case SurveyType.followup:
        return 'Follow-up Fragebogen';
    }
  }

  String get key {
    switch (this) {
      case SurveyType.baseline:
        return 'baseline';
      case SurveyType.followup:
        return 'followup';
    }
  }
}

/// Individual question response
class QuestionResponse {
  final String questionId;
  final String domain;
  final int? score;
  final List<String>? multipleChoiceValues;
  final String? textValue;
  final DateTime answeredAt;

  const QuestionResponse({
    required this.questionId,
    required this.domain,
    this.score,
    this.multipleChoiceValues,
    this.textValue,
    required this.answeredAt,
  });
}

/// App effectiveness feedback (only for follow-up surveys)
class AppEffectivenessResponse {
  final int overallHelpfulness; // APP-1 (1-5)
  final List<String> helpfulAreas; // APP-2
  final int usageFrequency; // APP-3 (1-5)
  final int recommendationLikelihood; // APP-4 (1-5)
  final String? openFeedback; // APP-5

  const AppEffectivenessResponse({
    required this.overallHelpfulness,
    required this.helpfulAreas,
    required this.usageFrequency,
    required this.recommendationLikelihood,
    this.openFeedback,
  });

  /// Calculate Net Promoter Score (NPS) category
  NPSCategory get npsCategory {
    if (recommendationLikelihood >= 4) return NPSCategory.promoter;
    if (recommendationLikelihood >= 3) return NPSCategory.passive;
    return NPSCategory.detractor;
  }
}

/// Net Promoter Score category
enum NPSCategory {
  promoter,   // 4-5: Will recommend
  passive,    // 3: Neutral
  detractor,  // 1-2: Will not recommend
}

/// Helpful areas for APP-2
enum HelpfulArea {
  community,
  emotionalSupport,
  information,
  loneliness,
  socialContacts,
  mentalHealth,
  understanding,
  motivation,
  other,
}

extension HelpfulAreaExtension on HelpfulArea {
  String get displayName {
    switch (this) {
      case HelpfulArea.community:
        return 'Gefühl der Zugehörigkeit zu einer Gemeinschaft';
      case HelpfulArea.emotionalSupport:
        return 'Emotionale Unterstützung durch andere Mitglieder';
      case HelpfulArea.information:
        return 'Zugang zu wertvollen Informationen und Ressourcen';
      case HelpfulArea.loneliness:
        return 'Reduzierung von Einsamkeitsgefühlen';
      case HelpfulArea.socialContacts:
        return 'Aufbau neuer sozialer Kontakte';
      case HelpfulArea.mentalHealth:
        return 'Verbesserung meiner psychischen Gesundheit';
      case HelpfulArea.understanding:
        return 'Besseres Verständnis meiner Situation';
      case HelpfulArea.motivation:
        return 'Motivation für positive Veränderungen';
      case HelpfulArea.other:
        return 'Sonstiges';
    }
  }

  String get key {
    return toString().split('.').last;
  }
}
