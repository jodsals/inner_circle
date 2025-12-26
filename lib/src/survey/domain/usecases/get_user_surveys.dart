import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/survey_response.dart';
import '../repositories/survey_repository.dart';

/// Use case to get all survey responses for a user
class GetUserSurveys {
  final SurveyRepository repository;

  GetUserSurveys(this.repository);

  Future<Either<Failure, List<SurveyResponse>>> call(String userId) {
    return repository.getUserSurveyResponses(userId);
  }
}
