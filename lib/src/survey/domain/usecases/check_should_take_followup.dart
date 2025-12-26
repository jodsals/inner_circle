import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../repositories/survey_repository.dart';

/// Use case to check if user should take follow-up survey
class CheckShouldTakeFollowUp {
  final SurveyRepository repository;

  CheckShouldTakeFollowUp(this.repository);

  Future<Either<Failure, bool>> call(String userId) {
    return repository.shouldTakeFollowUpSurvey(userId);
  }
}
