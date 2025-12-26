import 'package:dartz/dartz.dart';

import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/survey_question.dart';
import '../../domain/entities/survey_response.dart';
import '../../domain/repositories/survey_repository.dart';
import '../datasources/survey_remote_datasource.dart';
import '../models/survey_response_model.dart';
import '../models/survey_schedule_model.dart';
import '../survey_questions_data.dart';

/// Implementation of SurveyRepository
class SurveyRepositoryImpl implements SurveyRepository {
  final SurveyRemoteDataSource remoteDataSource;

  SurveyRepositoryImpl(this.remoteDataSource);

  @override
  Future<Either<Failure, List<SurveyQuestion>>> getSurveyQuestions(
      SurveyType type) async {
    try {
      final questions = type == SurveyType.baseline
          ? SurveyQuestionsData.getBaselineQuestions()
          : SurveyQuestionsData.getFollowUpQuestions();

      return Right(questions);
    } catch (e) {
      return Left(ServerFailure('Failed to get survey questions: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveyResponse>> submitSurveyResponse(
      SurveyResponse response) async {
    try {
      final model = SurveyResponseModel.fromEntity(response);
      final result = await remoteDataSource.submitSurveyResponse(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SurveyResponse>>> getUserSurveyResponses(
      String userId) async {
    try {
      final responses = await remoteDataSource.getUserSurveyResponses(userId);
      return Right(responses);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveyResponse>> getSurveyResponse(
      String responseId) async {
    try {
      final response = await remoteDataSource.getSurveyResponse(responseId);
      return Right(response);
    } on NotFoundException catch (e) {
      return Left(NotFoundFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveyResponse?>> getBaselineSurvey(
      String userId) async {
    try {
      final response = await remoteDataSource.getBaselineSurvey(userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveyResponse?>> getFollowUpSurvey(
      String userId) async {
    try {
      final response = await remoteDataSource.getFollowUpSurvey(userId);
      return Right(response);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveySchedule>> createSurveySchedule(
      SurveySchedule schedule) async {
    try {
      final model = SurveyScheduleModel.fromEntity(schedule);
      final result = await remoteDataSource.createSurveySchedule(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveySchedule?>> getUserSurveySchedule(
      String userId) async {
    try {
      final schedule = await remoteDataSource.getUserSurveySchedule(userId);
      return Right(schedule);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, SurveySchedule>> updateSurveySchedule(
      SurveySchedule schedule) async {
    try {
      final model = SurveyScheduleModel.fromEntity(schedule);
      final result = await remoteDataSource.updateSurveySchedule(model);
      return Right(result);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, bool>> shouldTakeFollowUpSurvey(String userId) async {
    try {
      // Check if baseline is completed
      final baseline = await remoteDataSource.getBaselineSurvey(userId);
      if (baseline == null) return const Right(false);

      // Check if follow-up is already completed
      final followUp = await remoteDataSource.getFollowUpSurvey(userId);
      if (followUp != null) return const Right(false);

      // Check schedule
      final schedule = await remoteDataSource.getUserSurveySchedule(userId);
      if (schedule == null) return const Right(false);

      // Check if it's time for follow-up
      final now = DateTime.now();
      final isDue = now.isAfter(schedule.followUpDueDate) ||
          now.isAtSameMomentAs(schedule.followUpDueDate);

      return Right(isDue);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<SurveySchedule>>> getPendingSurveySchedules() async {
    try {
      final schedules = await remoteDataSource.getPendingSurveySchedules();
      return Right(schedules);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> saveSurveyProgress(
    String userId,
    SurveyType type,
    List<QuestionResponse> responses,
  ) async {
    try {
      await remoteDataSource.saveSurveyProgress(userId, type, responses);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, List<QuestionResponse>?>> getSurveyProgress(
    String userId,
    SurveyType type,
  ) async {
    try {
      final progress = await remoteDataSource.getSurveyProgress(userId, type);
      return Right(progress);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }

  @override
  Future<Either<Failure, void>> deleteSurveyProgress(
    String userId,
    SurveyType type,
  ) async {
    try {
      await remoteDataSource.deleteSurveyProgress(userId, type);
      return const Right(null);
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } catch (e) {
      return Left(ServerFailure('Unexpected error: $e'));
    }
  }
}
