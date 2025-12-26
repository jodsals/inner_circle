import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/datasources/survey_remote_datasource.dart';
import '../../data/repositories/survey_repository_impl.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/entities/survey_response.dart';
import '../../domain/repositories/survey_repository.dart';
import '../../domain/usecases/calculate_domain_scores.dart';
import '../../domain/usecases/check_should_take_followup.dart';
import '../../domain/usecases/get_survey_questions.dart';
import '../../domain/usecases/get_user_surveys.dart';
import '../../domain/usecases/schedule_followup_survey.dart';
import '../../domain/usecases/submit_survey_response.dart';

// ==================== Infrastructure ====================

/// Firebase Firestore instance provider
final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

/// Survey remote data source provider
final surveyRemoteDataSourceProvider = Provider<SurveyRemoteDataSource>((ref) {
  final firestore = ref.watch(firestoreProvider);
  return FirebaseSurveyRemoteDataSource(firestore);
});

/// Survey repository provider
final surveyRepositoryProvider = Provider<SurveyRepository>((ref) {
  final dataSource = ref.watch(surveyRemoteDataSourceProvider);
  return SurveyRepositoryImpl(dataSource);
});

// ==================== Use Cases ====================

/// Get survey questions use case provider
final getSurveyQuestionsProvider = Provider<GetSurveyQuestions>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return GetSurveyQuestions(repository);
});

/// Submit survey response use case provider
final submitSurveyResponseProvider = Provider<SubmitSurveyResponse>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return SubmitSurveyResponse(repository);
});

/// Get user surveys use case provider
final getUserSurveysProvider = Provider<GetUserSurveys>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return GetUserSurveys(repository);
});

/// Schedule follow-up survey use case provider
final scheduleFollowUpSurveyProvider = Provider<ScheduleFollowUpSurvey>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return ScheduleFollowUpSurvey(repository);
});

/// Check should take follow-up use case provider
final checkShouldTakeFollowUpProvider = Provider<CheckShouldTakeFollowUp>((ref) {
  final repository = ref.watch(surveyRepositoryProvider);
  return CheckShouldTakeFollowUp(repository);
});

/// Calculate domain scores use case provider
final calculateDomainScoresProvider = Provider<CalculateDomainScores>((ref) {
  return CalculateDomainScores();
});

// ==================== State Providers ====================

/// Provider for survey questions by type
final surveyQuestionsProvider =
    FutureProvider.family<List<SurveyQuestion>, SurveyType>((ref, type) async {
  final getSurveyQuestions = ref.watch(getSurveyQuestionsProvider);
  final result = await getSurveyQuestions(type);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (questions) => questions,
  );
});

/// Provider for user's survey responses
final userSurveyResponsesProvider =
    FutureProvider.family<List<SurveyResponse>, String>((ref, userId) async {
  final getUserSurveys = ref.watch(getUserSurveysProvider);
  final result = await getUserSurveys(userId);
  return result.fold(
    (failure) => throw Exception(failure.message),
    (responses) => responses,
  );
});

/// Provider to check if user should take follow-up survey
final shouldTakeFollowUpProvider =
    FutureProvider.family<bool, String>((ref, userId) async {
  final checkShouldTakeFollowUp = ref.watch(checkShouldTakeFollowUpProvider);
  final result = await checkShouldTakeFollowUp(userId);
  return result.fold(
    (failure) => false,
    (should) => should,
  );
});

// ==================== Controller ====================

/// Survey controller for managing survey state
class SurveyController extends StateNotifier<AsyncValue<void>> {
  final SubmitSurveyResponse submitSurveyResponse;
  final ScheduleFollowUpSurvey scheduleFollowUpSurvey;
  final SurveyRepository repository;

  SurveyController({
    required this.submitSurveyResponse,
    required this.scheduleFollowUpSurvey,
    required this.repository,
  }) : super(const AsyncValue.data(null));

  /// Submit a survey response
  Future<SurveyResponse?> submitSurvey(SurveyResponse response) async {
    state = const AsyncValue.loading();

    final result = await submitSurveyResponse(response);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return null;
      },
      (submittedResponse) async {
        // If baseline survey, schedule follow-up
        if (response.type == SurveyType.baseline) {
          await scheduleFollowUpSurvey(
            userId: response.userId,
            baselineCompletedAt: response.completedAt,
          );
        }

        state = const AsyncValue.data(null);
        return submittedResponse;
      },
    );
  }

  /// Save survey progress
  Future<bool> saveProgress({
    required String userId,
    required SurveyType type,
    required List<QuestionResponse> responses,
  }) async {
    state = const AsyncValue.loading();

    final result =
        await repository.saveSurveyProgress(userId, type, responses);

    return result.fold(
      (failure) {
        state = AsyncValue.error(failure.message, StackTrace.current);
        return false;
      },
      (_) {
        state = const AsyncValue.data(null);
        return true;
      },
    );
  }

  /// Load saved progress
  Future<List<QuestionResponse>?> loadProgress({
    required String userId,
    required SurveyType type,
  }) async {
    final result = await repository.getSurveyProgress(userId, type);

    return result.fold(
      (failure) => null,
      (progress) => progress,
    );
  }

  /// Delete saved progress
  Future<void> deleteProgress({
    required String userId,
    required SurveyType type,
  }) async {
    await repository.deleteSurveyProgress(userId, type);
  }
}

/// Survey controller provider
final surveyControllerProvider =
    StateNotifierProvider<SurveyController, AsyncValue<void>>((ref) {
  final submitUseCase = ref.watch(submitSurveyResponseProvider);
  final scheduleUseCase = ref.watch(scheduleFollowUpSurveyProvider);
  final repository = ref.watch(surveyRepositoryProvider);

  return SurveyController(
    submitSurveyResponse: submitUseCase,
    scheduleFollowUpSurvey: scheduleUseCase,
    repository: repository,
  );
});
