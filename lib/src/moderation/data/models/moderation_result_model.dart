import 'dart:convert';

import '../../domain/entities/moderation_result.dart';

/// Data model for ModerationResult
class ModerationResultModel extends ModerationResult {
  const ModerationResultModel({
    required super.isFlagged,
    required super.reasons,
    required super.analysis,
    required super.confidenceScore,
  });

  /// Create from JSON (Ollama response)
  factory ModerationResultModel.fromJson(Map<String, dynamic> json) {
    return ModerationResultModel(
      isFlagged: json['isFlagged'] as bool? ?? false,
      reasons: (json['reasons'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      analysis: json['summary'] as String? ?? json['analysis'] as String? ?? '',
      confidenceScore: (json['confidenceScore'] as num?)?.toDouble() ?? 0.0,
    );
  }

  /// Parse from Ollama API response text
  factory ModerationResultModel.fromOllamaResponse(String responseText) {
    try {
      // Try to extract JSON from response
      final jsonStart = responseText.indexOf('{');
      final jsonEnd = responseText.lastIndexOf('}');

      if (jsonStart == -1 || jsonEnd == -1) {
        // No JSON found, return safe result
        return const ModerationResultModel(
          isFlagged: false,
          reasons: [],
          analysis: 'Keine gültige Antwort vom Moderationssystem',
          confidenceScore: 0.0,
        );
      }

      final jsonStr = responseText.substring(jsonStart, jsonEnd + 1);
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;

      return ModerationResultModel.fromJson(json);
    } catch (e) {
      // Error parsing, return safe result
      return ModerationResultModel(
        isFlagged: false,
        reasons: [],
        analysis: 'Fehler beim Parsen der Moderation: $e',
        confidenceScore: 0.0,
      );
    }
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'isFlagged': isFlagged,
      'reasons': reasons,
      'analysis': analysis,
      'confidenceScore': confidenceScore,
    };
  }

  /// Create from entity
  factory ModerationResultModel.fromEntity(ModerationResult result) {
    return ModerationResultModel(
      isFlagged: result.isFlagged,
      reasons: result.reasons,
      analysis: result.analysis,
      confidenceScore: result.confidenceScore,
    );
  }
}
