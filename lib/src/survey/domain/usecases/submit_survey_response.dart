import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/survey_response.dart';
import '../repositories/survey_repository.dart';

/// Use case to submit a survey response
class SubmitSurveyResponse {
  final SurveyRepository repository;

  SubmitSurveyResponse(this.repository);

  Future<Either<Failure, SurveyResponse>> call(SurveyResponse response) {
    return repository.submitSurveyResponse(response);
  }
}
