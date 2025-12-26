import 'package:cloud_firestore/cloud_firestore.dart';

import '../../domain/entities/survey_response.dart';

/// Firestore model for SurveyResponse
class SurveyResponseModel extends SurveyResponse {
  const SurveyResponseModel({
    required super.id,
    required super.userId,
    required super.surveyId,
    required super.type,
    required super.completedAt,
    super.startedAt,
    required super.domainScores,
    required super.responses,
    super.appFeedback,
    super.isComplete,
  });

  /// Create from Firestore document
  factory SurveyResponseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SurveyResponseModel(
      id: doc.id,
      userId: data['userId'] as String,
      surveyId: data['surveyId'] as String,
      type: SurveyType.values.firstWhere(
        (e) => e.key == data['type'],
        orElse: () => SurveyType.baseline,
      ),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      domainScores: Map<String, double>.from(data['domainScores'] ?? {}),
      responses: (data['responses'] as List<dynamic>?)
              ?.map((r) => QuestionResponseModel.fromMap(r))
              .toList() ??
          [],
      appFeedback: data['appFeedback'] != null
          ? AppEffectivenessResponseModel.fromMap(data['appFeedback'])
          : null,
      isComplete: data['isComplete'] as bool? ?? false,
    );
  }

  /// Convert to Firestore document
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'surveyId': surveyId,
      'type': type.key,
      'completedAt': Timestamp.fromDate(completedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'domainScores': domainScores,
      'responses': responses
          .map((r) => QuestionResponseModel.fromEntity(r).toMap())
          .toList(),
      'appFeedback': appFeedback != null
          ? AppEffectivenessResponseModel.fromEntity(appFeedback!).toMap()
          : null,
      'isComplete': isComplete,
    };
  }

  /// Create from entity
  factory SurveyResponseModel.fromEntity(SurveyResponse entity) {
    return SurveyResponseModel(
      id: entity.id,
      userId: entity.userId,
      surveyId: entity.surveyId,
      type: entity.type,
      completedAt: entity.completedAt,
      startedAt: entity.startedAt,
      domainScores: entity.domainScores,
      responses: entity.responses,
      appFeedback: entity.appFeedback,
      isComplete: entity.isComplete,
    );
  }
}

/// Model for QuestionResponse
class QuestionResponseModel extends QuestionResponse {
  const QuestionResponseModel({
    required super.questionId,
    required super.domain,
    super.score,
    super.multipleChoiceValues,
    super.textValue,
    required super.answeredAt,
  });

  factory QuestionResponseModel.fromMap(Map<String, dynamic> map) {
    return QuestionResponseModel(
      questionId: map['questionId'] as String,
      domain: map['domain'] as String,
      score: map['score'] as int?,
      multipleChoiceValues:
          (map['multipleChoiceValues'] as List<dynamic>?)?.cast<String>(),
      textValue: map['textValue'] as String?,
      answeredAt: (map['answeredAt'] as Timestamp).toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'questionId': questionId,
      'domain': domain,
      'score': score,
      'multipleChoiceValues': multipleChoiceValues,
      'textValue': textValue,
      'answeredAt': Timestamp.fromDate(answeredAt),
    };
  }

  factory QuestionResponseModel.fromEntity(QuestionResponse entity) {
    return QuestionResponseModel(
      questionId: entity.questionId,
      domain: entity.domain,
      score: entity.score,
      multipleChoiceValues: entity.multipleChoiceValues,
      textValue: entity.textValue,
      answeredAt: entity.answeredAt,
    );
  }
}

/// Model for AppEffectivenessResponse
class AppEffectivenessResponseModel extends AppEffectivenessResponse {
  const AppEffectivenessResponseModel({
    required super.overallHelpfulness,
    required super.helpfulAreas,
    required super.usageFrequency,
    required super.recommendationLikelihood,
    super.openFeedback,
  });

  factory AppEffectivenessResponseModel.fromMap(Map<String, dynamic> map) {
    return AppEffectivenessResponseModel(
      overallHelpfulness: map['overallHelpfulness'] as int,
      helpfulAreas: (map['helpfulAreas'] as List<dynamic>).cast<String>(),
      usageFrequency: map['usageFrequency'] as int,
      recommendationLikelihood: map['recommendationLikelihood'] as int,
      openFeedback: map['openFeedback'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'overallHelpfulness': overallHelpfulness,
      'helpfulAreas': helpfulAreas,
      'usageFrequency': usageFrequency,
      'recommendationLikelihood': recommendationLikelihood,
      'openFeedback': openFeedback,
    };
  }

  factory AppEffectivenessResponseModel.fromEntity(
      AppEffectivenessResponse entity) {
    return AppEffectivenessResponseModel(
      overallHelpfulness: entity.overallHelpfulness,
      helpfulAreas: entity.helpfulAreas,
      usageFrequency: entity.usageFrequency,
      recommendationLikelihood: entity.recommendationLikelihood,
      openFeedback: entity.openFeedback,
    );
  }
}
