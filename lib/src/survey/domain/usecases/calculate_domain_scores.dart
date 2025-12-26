import '../entities/survey_response.dart';

/// Use case to calculate domain scores from survey responses
class CalculateDomainScores {
  /// Calculate scores for all domains
  Map<String, double> call(List<QuestionResponse> responses) {
    final domainScores = <String, double>{};

    // Group responses by domain
    final domainResponses = <String, List<QuestionResponse>>{};
    for (final response in responses) {
      domainResponses.putIfAbsent(response.domain, () => []);
      domainResponses[response.domain]!.add(response);
    }

    // Calculate average score for each domain
    for (final entry in domainResponses.entries) {
      final domain = entry.key;
      final responses = entry.value;

      // Get valid scores (non-null)
      final scores = responses
          .where((r) => r.score != null)
          .map((r) => r.score!)
          .toList();

      if (scores.isEmpty) {
        domainScores[domain] = 0.0;
        continue;
      }

      // Calculate average
      final sum = scores.reduce((a, b) => a + b);
      domainScores[domain] = sum / scores.length;
    }

    return domainScores;
  }

  /// Calculate change between baseline and follow-up
  Map<String, double> calculateChanges(
    Map<String, double> baselineScores,
    Map<String, double> followUpScores,
  ) {
    final changes = <String, double>{};

    for (final domain in baselineScores.keys) {
      final baselineScore = baselineScores[domain] ?? 0;
      final followUpScore = followUpScores[domain] ?? 0;
      changes[domain] = followUpScore - baselineScore;
    }

    return changes;
  }

  /// Check if change is clinically significant
  bool isClinicallySignificant(double change, String domain) {
    // MCID thresholds from PROMIS documentation
    final mcidThresholds = {
      'depression': 5.0,
      'anxiety': 4.0,
      'social_isolation': 5.0,
      'emotional_support': 4.0,
      'social_participation': 4.0,
      'global_health': 5.0,
    };

    final threshold = mcidThresholds[domain] ?? 5.0;
    return change.abs() >= threshold;
  }

  /// Convert raw score to T-Score (Mean=50, SD=10)
  /// This is a simplified conversion - actual PROMIS T-scores require lookup tables
  double toTScore(double rawScore, {double mean = 3.0}) {
    // Assuming 1-5 scale with mean of 3.0
    // T-Score = 50 + ((raw - mean) / SD) * 10
    // Using SD of 1.0 as approximation
    return 50 + ((rawScore - mean) * 10);
  }
}
