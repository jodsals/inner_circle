import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../entities/survey_question.dart';
import '../entities/survey_response.dart';
import '../repositories/survey_repository.dart';

/// Use case to get survey questions
class GetSurveyQuestions {
  final SurveyRepository repository;

  GetSurveyQuestions(this.repository);

  Future<Either<Failure, List<SurveyQuestion>>> call(SurveyType type) {
    return repository.getSurveyQuestions(type);
  }
}
