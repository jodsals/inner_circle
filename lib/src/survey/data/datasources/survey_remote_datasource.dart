import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/errors/exceptions.dart';
import '../../domain/entities/survey_response.dart';
import '../models/survey_response_model.dart';
import '../models/survey_schedule_model.dart';

/// Abstract remote data source for surveys
abstract class SurveyRemoteDataSource {
  /// Submit a survey response
  Future<SurveyResponseModel> submitSurveyResponse(
      SurveyResponseModel response);

  /// Get user's survey responses
  Future<List<SurveyResponseModel>> getUserSurveyResponses(String userId);

  /// Get a specific survey response
  Future<SurveyResponseModel> getSurveyResponse(String responseId);

  /// Get baseline survey for a user
  Future<SurveyResponseModel?> getBaselineSurvey(String userId);

  /// Get follow-up survey for a user
  Future<SurveyResponseModel?> getFollowUpSurvey(String userId);

  /// Create survey schedule
  Future<SurveyScheduleModel> createSurveySchedule(
      SurveyScheduleModel schedule);

  /// Get survey schedule for a user
  Future<SurveyScheduleModel?> getUserSurveySchedule(String userId);

  /// Update survey schedule
  Future<SurveyScheduleModel> updateSurveySchedule(
      SurveyScheduleModel schedule);

  /// Get pending survey schedules
  Future<List<SurveyScheduleModel>> getPendingSurveySchedules();

  /// Save partial survey progress
  Future<void> saveSurveyProgress(
    String userId,
    SurveyType type,
    List<QuestionResponse> responses,
  );

  /// Get saved survey progress
  Future<List<QuestionResponse>?> getSurveyProgress(
    String userId,
    SurveyType type,
  );

  /// Delete survey progress
  Future<void> deleteSurveyProgress(String userId, SurveyType type);
}

/// Implementation of survey remote data source using Firebase
class FirebaseSurveyRemoteDataSource implements SurveyRemoteDataSource {
  final FirebaseFirestore firestore;

  FirebaseSurveyRemoteDataSource(this.firestore);

  CollectionReference get _surveyResponsesCollection =>
      firestore.collection('survey_responses');

  CollectionReference get _surveySchedulesCollection =>
      firestore.collection('survey_schedules');

  CollectionReference get _surveyProgressCollection =>
      firestore.collection('survey_progress');

  @override
  Future<SurveyResponseModel> submitSurveyResponse(
      SurveyResponseModel response) async {
    try {
      // Auto-generate ID if empty
      final docRef = response.id.isEmpty
          ? _surveyResponsesCollection.doc()
          : _surveyResponsesCollection.doc(response.id);

      // Create response with the correct ID
      final responseWithId = SurveyResponseModel(
        id: docRef.id,
        userId: response.userId,
        surveyId: response.surveyId,
        type: response.type,
        completedAt: response.completedAt,
        startedAt: response.startedAt,
        domainScores: response.domainScores,
        responses: response.responses,
        appFeedback: response.appFeedback,
        isComplete: response.isComplete,
      );

      await docRef.set(responseWithId.toFirestore());

      final doc = await docRef.get();
      return SurveyResponseModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to submit survey: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to submit survey: $e');
    }
  }

  @override
  Future<List<SurveyResponseModel>> getUserSurveyResponses(
      String userId) async {
    try {
      final snapshot = await _surveyResponsesCollection
          .where('userId', isEqualTo: userId)
          .orderBy('completedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SurveyResponseModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get survey responses: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get survey responses: $e');
    }
  }

  @override
  Future<SurveyResponseModel> getSurveyResponse(String responseId) async {
    try {
      final doc = await _surveyResponsesCollection.doc(responseId).get();

      if (!doc.exists) {
        throw const NotFoundException('Survey response not found');
      }

      return SurveyResponseModel.fromFirestore(doc);
    } on NotFoundException {
      rethrow;
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get survey response: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get survey response: $e');
    }
  }

  @override
  Future<SurveyResponseModel?> getBaselineSurvey(String userId) async {
    try {
      final snapshot = await _surveyResponsesCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'baseline')
          .where('isComplete', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return SurveyResponseModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get baseline survey: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get baseline survey: $e');
    }
  }

  @override
  Future<SurveyResponseModel?> getFollowUpSurvey(String userId) async {
    try {
      final snapshot = await _surveyResponsesCollection
          .where('userId', isEqualTo: userId)
          .where('type', isEqualTo: 'followup')
          .where('isComplete', isEqualTo: true)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return SurveyResponseModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get follow-up survey: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get follow-up survey: $e');
    }
  }

  @override
  Future<SurveyScheduleModel> createSurveySchedule(
      SurveyScheduleModel schedule) async {
    try {
      final docRef = _surveySchedulesCollection.doc();
      final scheduleWithId = SurveyScheduleModel(
        id: docRef.id,
        userId: schedule.userId,
        baselineCompletedAt: schedule.baselineCompletedAt,
        followUpDueDate: schedule.followUpDueDate,
        followUpCompletedAt: schedule.followUpCompletedAt,
        remindersSent: schedule.remindersSent,
        status: schedule.status,
      );

      await docRef.set(scheduleWithId.toFirestore());

      final doc = await docRef.get();
      return SurveyScheduleModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to create survey schedule: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to create survey schedule: $e');
    }
  }

  @override
  Future<SurveyScheduleModel?> getUserSurveySchedule(String userId) async {
    try {
      final snapshot = await _surveySchedulesCollection
          .where('userId', isEqualTo: userId)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        return null;
      }

      return SurveyScheduleModel.fromFirestore(snapshot.docs.first);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get survey schedule: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get survey schedule: $e');
    }
  }

  @override
  Future<SurveyScheduleModel> updateSurveySchedule(
      SurveyScheduleModel schedule) async {
    try {
      await _surveySchedulesCollection
          .doc(schedule.id)
          .update(schedule.toFirestore());

      final doc = await _surveySchedulesCollection.doc(schedule.id).get();
      return SurveyScheduleModel.fromFirestore(doc);
    } on FirebaseException catch (e) {
      throw ServerException('Failed to update survey schedule: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to update survey schedule: $e');
    }
  }

  @override
  Future<List<SurveyScheduleModel>> getPendingSurveySchedules() async {
    try {
      final snapshot = await _surveySchedulesCollection
          .where('status', isEqualTo: 'pending')
          .get();

      return snapshot.docs
          .map((doc) => SurveyScheduleModel.fromFirestore(doc))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException(
          'Failed to get pending survey schedules: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get pending survey schedules: $e');
    }
  }

  @override
  Future<void> saveSurveyProgress(
    String userId,
    SurveyType type,
    List<QuestionResponse> responses,
  ) async {
    try {
      final docId = '${userId}_${type.key}';
      await _surveyProgressCollection.doc(docId).set({
        'userId': userId,
        'type': type.key,
        'responses': responses
            .map((r) => QuestionResponseModel.fromEntity(r).toMap())
            .toList(),
        'savedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      throw ServerException('Failed to save survey progress: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to save survey progress: $e');
    }
  }

  @override
  Future<List<QuestionResponse>?> getSurveyProgress(
    String userId,
    SurveyType type,
  ) async {
    try {
      final docId = '${userId}_${type.key}';
      final doc = await _surveyProgressCollection.doc(docId).get();

      if (!doc.exists) {
        return null;
      }

      final data = doc.data() as Map<String, dynamic>;
      return (data['responses'] as List<dynamic>?)
          ?.map((r) => QuestionResponseModel.fromMap(r))
          .toList();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to get survey progress: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to get survey progress: $e');
    }
  }

  @override
  Future<void> deleteSurveyProgress(String userId, SurveyType type) async {
    try {
      final docId = '${userId}_${type.key}';
      await _surveyProgressCollection.doc(docId).delete();
    } on FirebaseException catch (e) {
      throw ServerException('Failed to delete survey progress: ${e.message}');
    } catch (e) {
      throw ServerException('Failed to delete survey progress: $e');
    }
  }
}
