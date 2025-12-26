/// PROMIS-based survey question entity
class SurveyQuestion {
  final String id;
  final String domain;
  final String questionText;
  final String timeframe;
  final QuestionType type;
  final List<ResponseOption> options;
  final bool isRequired;
  final int order;

  const SurveyQuestion({
    required this.id,
    required this.domain,
    required this.questionText,
    required this.timeframe,
    required this.type,
    required this.options,
    this.isRequired = true,
    required this.order,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SurveyQuestion &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Type of survey question
enum QuestionType {
  frequency,     // Häufigkeitsskala (1-5)
  intensity,     // Intensitätsskala (1-5)
  agreement,     // Zustimmungsskala (1-5)
  rating,        // Bewertungsskala (1-5)
  multipleChoice, // Mehrfachauswahl
  openText,      // Freitext
}

/// Response option for a question
class ResponseOption {
  final int value;
  final String label;

  const ResponseOption({
    required this.value,
    required this.label,
  });
}

/// PROMIS Domain categories
enum PROMISDomain {
  depression,
  anxiety,
  socialIsolation,
  emotionalSupport,
  socialParticipation,
  globalHealth,
  appEffectiveness, // Only for follow-up
}

extension PROMISDomainExtension on PROMISDomain {
  String get displayName {
    switch (this) {
      case PROMISDomain.depression:
        return 'Depression';
      case PROMISDomain.anxiety:
        return 'Angst';
      case PROMISDomain.socialIsolation:
        return 'Soziale Isolation';
      case PROMISDomain.emotionalSupport:
        return 'Emotionale Unterstützung';
      case PROMISDomain.socialParticipation:
        return 'Soziale Teilhabe';
      case PROMISDomain.globalHealth:
        return 'Lebensqualität';
      case PROMISDomain.appEffectiveness:
        return 'App-Wirksamkeit';
    }
  }

  String get key {
    switch (this) {
      case PROMISDomain.depression:
        return 'depression';
      case PROMISDomain.anxiety:
        return 'anxiety';
      case PROMISDomain.socialIsolation:
        return 'social_isolation';
      case PROMISDomain.emotionalSupport:
        return 'emotional_support';
      case PROMISDomain.socialParticipation:
        return 'social_participation';
      case PROMISDomain.globalHealth:
        return 'global_health';
      case PROMISDomain.appEffectiveness:
        return 'app_effectiveness';
    }
  }
}
