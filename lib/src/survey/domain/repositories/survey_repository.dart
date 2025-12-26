import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/survey_question.dart';
import '../entities/survey_response.dart';
import '../../data/models/survey_schedule_model.dart';

/// Repository interface for survey operations
abstract class SurveyRepository {
  /// Get survey questions by type
  Future<Either<Failure, List<SurveyQuestion>>> getSurveyQuestions(
      SurveyType type);

  /// Submit a survey response
  Future<Either<Failure, SurveyResponse>> submitSurveyResponse(
      SurveyResponse response);

  /// Get user's survey responses
  Future<Either<Failure, List<SurveyResponse>>> getUserSurveyResponses(
      String userId);

  /// Get a specific survey response
  Future<Either<Failure, SurveyResponse>> getSurveyResponse(String responseId);

  /// Get baseline survey response for a user
  Future<Either<Failure, SurveyResponse?>> getBaselineSurvey(String userId);

  /// Get follow-up survey response for a user
  Future<Either<Failure, SurveyResponse?>> getFollowUpSurvey(String userId);

  /// Create a survey schedule for follow-up
  Future<Either<Failure, SurveySchedule>> createSurveySchedule(
      SurveySchedule schedule);

  /// Get survey schedule for a user
  Future<Either<Failure, SurveySchedule?>> getUserSurveySchedule(String userId);

  /// Update survey schedule
  Future<Either<Failure, SurveySchedule>> updateSurveySchedule(
      SurveySchedule schedule);

  /// Check if user should take follow-up survey
  Future<Either<Failure, bool>> shouldTakeFollowUpSurvey(String userId);

  /// Get pending survey schedules (for reminders)
  Future<Either<Failure, List<SurveySchedule>>> getPendingSurveySchedules();

  /// Save partial survey progress
  Future<Either<Failure, void>> saveSurveyProgress(
    String userId,
    SurveyType type,
    List<QuestionResponse> responses,
  );

  /// Get saved survey progress
  Future<Either<Failure, List<QuestionResponse>?>> getSurveyProgress(
    String userId,
    SurveyType type,
  );

  /// Delete survey progress
  Future<Either<Failure, void>> deleteSurveyProgress(
    String userId,
    SurveyType type,
  );
}
