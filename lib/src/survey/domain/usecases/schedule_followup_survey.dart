import 'package:dartz/dartz.dart';

import '../../../../core/errors/failures.dart';
import '../../data/models/survey_schedule_model.dart';
import '../repositories/survey_repository.dart';

/// Use case to schedule a follow-up survey
class ScheduleFollowUpSurvey {
  final SurveyRepository repository;

  ScheduleFollowUpSurvey(this.repository);

  /// Schedule follow-up survey 8 weeks after baseline
  Future<Either<Failure, SurveySchedule>> call({
    required String userId,
    required DateTime baselineCompletedAt,
  }) {
    // Calculate follow-up date (8 weeks = 56 days)
    final followUpDueDate =
        baselineCompletedAt.add(const Duration(days: 56));

    final schedule = SurveySchedule(
      id: '', // Will be set by datasource
      userId: userId,
      baselineCompletedAt: baselineCompletedAt,
      followUpDueDate: followUpDueDate,
      remindersSent: [],
      status: ScheduleStatus.pending,
    );

    return repository.createSurveySchedule(schedule);
  }
}
