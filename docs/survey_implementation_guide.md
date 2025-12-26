# PROMIS Survey System - Implementierungsanleitung

## Übersicht

Diese Anleitung beschreibt die Implementierung des PROMIS-basierten Fragebogen-Systems für die Inner Circle App.

## Architektur

```
lib/src/survey/
├── domain/
│   ├── entities/
│   │   ├── survey_question.dart
│   │   ├── survey_response.dart
│   │   └── survey_schedule.dart
│   ├── repositories/
│   │   └── survey_repository.dart
│   └── usecases/
│       ├── get_survey_questions.dart
│       ├── submit_survey_response.dart
│       ├── get_user_surveys.dart
│       └── schedule_followup_survey.dart
├── data/
│   ├── models/
│   │   ├── survey_question_model.dart
│   │   ├── survey_response_model.dart
│   │   └── survey_schedule_model.dart
│   ├── datasources/
│   │   └── survey_remote_datasource.dart
│   ├── repositories/
│   │   └── survey_repository_impl.dart
│   └── survey_questions_data.dart
└── presentation/
    ├── pages/
    │   ├── survey_intro_page.dart
    │   ├── survey_page.dart
    │   └── survey_results_page.dart
    ├── widgets/
    │   ├── question_widgets/
    │   │   ├── frequency_question.dart
    │   │   ├── intensity_question.dart
    │   │   ├── agreement_question.dart
    │   │   ├── multiple_choice_question.dart
    │   │   └── open_text_question.dart
    │   ├── survey_progress_bar.dart
    │   └── domain_section_header.dart
    └── providers/
        └── survey_providers.dart
```

## Firestore Datenbank-Schema

### Collection: `survey_responses`

```json
{
  "id": "response_123",
  "userId": "user_456",
  "surveyId": "survey_baseline_v1",
  "type": "baseline", // "baseline" | "followup"
  "startedAt": "2025-01-15T10:00:00Z",
  "completedAt": "2025-01-15T10:15:00Z",
  "isComplete": true,
  "domainScores": {
    "depression": 3.2,
    "anxiety": 2.8,
    "social_isolation": 4.1,
    "emotional_support": 2.5,
    "social_participation": 3.0,
    "global_health": 2.7
  },
  "responses": [
    {
      "questionId": "DEP-1",
      "domain": "depression",
      "score": 3,
      "answeredAt": "2025-01-15T10:02:00Z"
    },
    {
      "questionId": "APP-2",
      "domain": "app_effectiveness",
      "multipleChoiceValues": ["community", "emotionalSupport", "loneliness"],
      "answeredAt": "2025-01-15T10:14:00Z"
    }
  ],
  "appFeedback": {
    "overallHelpfulness": 4,
    "helpfulAreas": ["community", "emotionalSupport"],
    "usageFrequency": 4,
    "recommendationLikelihood": 5,
    "openFeedback": "Die App hat mir sehr geholfen..."
  }
}
```

### Collection: `survey_schedules`

```json
{
  "id": "schedule_789",
  "userId": "user_456",
  "baselineCompletedAt": "2025-01-15T10:15:00Z",
  "followUpDueDate": "2025-03-12T00:00:00Z", // 8 weeks after baseline
  "followUpCompletedAt": null,
  "remindersSent": [
    {
      "sentAt": "2025-03-05T09:00:00Z",
      "type": "email"
    },
    {
      "sentAt": "2025-03-12T09:00:00Z",
      "type": "push"
    }
  ],
  "status": "pending" // "pending" | "completed" | "overdue"
}
```

### Collection: `users` (Erweiterung)

Füge zu bestehender User-Collection hinzu:

```json
{
  "surveyStatus": {
    "baselineCompleted": true,
    "baselineCompletedAt": "2025-01-15T10:15:00Z",
    "followUpDueDate": "2025-03-12T00:00:00Z",
    "followUpCompleted": false,
    "canSkipFollowUp": false
  }
}
```

## Schritt-für-Schritt Implementierung

### Phase 1: Datenmodelle und Repository (Erledigt ✅)

Die folgenden Dateien wurden bereits erstellt:
- ✅ `survey_question.dart` - Fragen-Entität
- ✅ `survey_response.dart` - Antworten-Entität
- ✅ `survey_questions_data.dart` - Alle PROMIS-Fragen

### Phase 2: Firestore Integration

#### 2.1 Survey Response Model

```dart
// lib/src/survey/data/models/survey_response_model.dart

import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/survey_response.dart';

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

  factory SurveyResponseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SurveyResponseModel(
      id: doc.id,
      userId: data['userId'],
      surveyId: data['surveyId'],
      type: SurveyType.values.firstWhere((e) => e.key == data['type']),
      completedAt: (data['completedAt'] as Timestamp).toDate(),
      startedAt: data['startedAt'] != null
          ? (data['startedAt'] as Timestamp).toDate()
          : null,
      domainScores: Map<String, double>.from(data['domainScores']),
      responses: (data['responses'] as List)
          .map((r) => QuestionResponse(
                questionId: r['questionId'],
                domain: r['domain'],
                score: r['score'],
                multipleChoiceValues: r['multipleChoiceValues']?.cast<String>(),
                textValue: r['textValue'],
                answeredAt: (r['answeredAt'] as Timestamp).toDate(),
              ))
          .toList(),
      appFeedback: data['appFeedback'] != null
          ? AppEffectivenessResponse(
              overallHelpfulness: data['appFeedback']['overallHelpfulness'],
              helpfulAreas: (data['appFeedback']['helpfulAreas'] as List).cast<String>(),
              usageFrequency: data['appFeedback']['usageFrequency'],
              recommendationLikelihood: data['appFeedback']['recommendationLikelihood'],
              openFeedback: data['appFeedback']['openFeedback'],
            )
          : null,
      isComplete: data['isComplete'] ?? false,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'surveyId': surveyId,
      'type': type.key,
      'completedAt': Timestamp.fromDate(completedAt),
      'startedAt': startedAt != null ? Timestamp.fromDate(startedAt!) : null,
      'domainScores': domainScores,
      'responses': responses.map((r) => {
        'questionId': r.questionId,
        'domain': r.domain,
        'score': r.score,
        'multipleChoiceValues': r.multipleChoiceValues,
        'textValue': r.textValue,
        'answeredAt': Timestamp.fromDate(r.answeredAt),
      }).toList(),
      'appFeedback': appFeedback != null ? {
        'overallHelpfulness': appFeedback!.overallHelpfulness,
        'helpfulAreas': appFeedback!.helpfulAreas,
        'usageFrequency': appFeedback!.usageFrequency,
        'recommendationLikelihood': appFeedback!.recommendationLikelihood,
        'openFeedback': appFeedback!.openFeedback,
      } : null,
      'isComplete': isComplete,
    };
  }
}
```

### Phase 3: UI Components

#### 3.1 Survey Intro Page

Zeigt vor dem Fragebogen:
- Zweck der Umfrage
- Geschätzte Dauer
- Datenschutzinformationen
- Informed Consent

#### 3.2 Survey Page

Hauptseite für den Fragebogen mit:
- Fortschrittsanzeige
- Domain-Sections
- Frage-Widgets je nach Typ
- Navigation (Zurück/Weiter)
- Speichern und Später fortsetzen

#### 3.3 Question Widgets

Verschiedene Widgets für verschiedene Fragetypen:
- `FrequencyQuestionWidget` - Radio buttons für 1-5 Skala
- `IntensityQuestionWidget` - Ähnlich wie Frequency
- `AgreementQuestionWidget` - Ähnlich wie Frequency
- `MultipleChoiceQuestionWidget` - Checkboxen
- `OpenTextQuestionWidget` - TextField

### Phase 4: Workflow Integration

#### 4.1 Bei Registrierung

```dart
// Nach erfolgreicher Registrierung
if (registrationSuccess) {
  // Navigiere zum Survey Intro
  context.go('/survey/intro?type=baseline');
}
```

#### 4.2 Follow-up Scheduling

```dart
// Nach Abschluss des Baseline-Surveys
void scheduleFollowUpSurvey(String userId, DateTime baselineDate) {
  final followUpDate = baselineDate.add(Duration(days: 56)); // 8 weeks

  firestore.collection('survey_schedules').add({
    'userId': userId,
    'baselineCompletedAt': Timestamp.fromDate(baselineDate),
    'followUpDueDate': Timestamp.fromDate(followUpDate),
    'followUpCompletedAt': null,
    'remindersSent': [],
    'status': 'pending',
  });
}
```

#### 4.3 Erinnerungen

Cloud Function für automatische Erinnerungen:

```javascript
// Firebase Cloud Function
exports.sendSurveyReminders = functions.pubsub
  .schedule('every day 09:00')
  .onRun(async (context) => {
    const now = admin.firestore.Timestamp.now();
    const sevenDaysFromNow = admin.firestore.Timestamp.fromDate(
      new Date(Date.now() + 7 * 24 * 60 * 60 * 1000)
    );

    // Finde alle ausstehenden Surveys in 7 Tagen
    const snapshot = await admin.firestore()
      .collection('survey_schedules')
      .where('status', '==', 'pending')
      .where('followUpDueDate', '<=', sevenDaysFromNow)
      .get();

    for (const doc of snapshot.docs) {
      const schedule = doc.data();
      // Sende E-Mail/Push-Benachrichtigung
      await sendReminderNotification(schedule.userId);

      // Markiere Erinnerung als gesendet
      await doc.ref.update({
        remindersSent: admin.firestore.FieldValue.arrayUnion({
          sentAt: now,
          type: 'email'
        })
      });
    }
  });
```

### Phase 5: Scoring und Analyse

#### 5.1 Domain Score Berechnung

```dart
class SurveyScoring {
  /// Berechne Score für eine Domain
  static double calculateDomainScore(
    String domain,
    List<QuestionResponse> responses,
  ) {
    final domainResponses = responses
        .where((r) => r.domain == domain)
        .toList();

    if (domainResponses.isEmpty) return 0.0;

    // Durchschnitt der Rohwerte
    final sum = domainResponses
        .map((r) => r.score ?? 0)
        .reduce((a, b) => a + b);

    return sum / domainResponses.length;
  }

  /// Konvertiere zu PROMIS T-Score (optional)
  static double toTScore(double rawScore, String domain) {
    // T-Score: Mean = 50, SD = 10
    // Dies erfordert Domain-spezifische Normwerte
    // Vereinfacht hier als Beispiel:
    return 50 + ((rawScore - 3) * 10);
  }

  /// Berechne Veränderung von Baseline zu Follow-up
  static Map<String, double> calculateChanges(
    SurveyResponse baseline,
    SurveyResponse followup,
  ) {
    final changes = <String, double>{};

    for (final domain in baseline.domainScores.keys) {
      final baselineScore = baseline.domainScores[domain] ?? 0;
      final followupScore = followup.domainScores[domain] ?? 0;
      changes[domain] = followupScore - baselineScore;
    }

    return changes;
  }

  /// Prüfe ob Veränderung klinisch bedeutsam ist
  static bool isClinicallySignificant(double change, String domain) {
    // MCID (Minimal Clinically Important Difference) für verschiedene Domains
    final mcidThresholds = {
      'depression': 5.0,
      'anxiety': 4.0,
      'social_isolation': 5.0,
      'emotional_support': 4.0,
      'social_participation': 4.0,
      'global_health': 5.0,
    };

    return change.abs() >= (mcidThresholds[domain] ?? 5.0);
  }
}
```

### Phase 6: Datenschutz und Ethik

#### 6.1 Informed Consent

```dart
class SurveyConsentDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Einverständniserklärung'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Zweck der Umfrage:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Diese Umfrage hilft uns, die Wirksamkeit unserer App zu verstehen...'),
            SizedBox(height: 16),
            Text('Datenschutz:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Ihre Antworten werden verschlüsselt und pseudonymisiert gespeichert...'),
            SizedBox(height: 16),
            Text('Freiwilligkeit:', style: TextStyle(fontWeight: FontWeight.bold)),
            Text('Die Teilnahme ist vollständig freiwillig...'),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text('Ablehnen'),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(context, true),
          child: Text('Zustimmen'),
        ),
      ],
    );
  }
}
```

#### 6.2 Krisenintervention

```dart
class CrisisDetection {
  /// Prüfe auf kritische Antworten
  static bool detectsCrisis(List<QuestionResponse> responses) {
    // Beispiel: Sehr hohe Depression-Scores
    final depScores = responses
        .where((r) => r.domain == 'depression')
        .map((r) => r.score ?? 0)
        .toList();

    if (depScores.isEmpty) return false;

    final avgDepScore = depScores.reduce((a, b) => a + b) / depScores.length;

    // Wenn durchschnittlicher Depression-Score >= 4.5 (von 5)
    return avgDepScore >= 4.5;
  }

  /// Zeige Krisen-Ressourcen
  static void showCrisisResources(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text('Hilfsangebote'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Wenn Sie sich in einer Krise befinden, stehen Ihnen folgende Hilfsangebote zur Verfügung:'),
            SizedBox(height: 16),
            Text('Telefonseelsorge:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText('0800 111 0 111 (24/7 kostenlos)'),
            SizedBox(height: 8),
            Text('Krisenchat:', style: TextStyle(fontWeight: FontWeight.bold)),
            SelectableText('www.krisenchat.de'),
          ],
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Verstanden'),
          ),
        ],
      ),
    );
  }
}
```

## Nächste Schritte

1. ✅ Dokumentation erstellt
2. ✅ Datenmodelle definiert
3. ✅ Fragen-Daten vorbereitet
4. ⬜ Firestore Models implementieren
5. ⬜ Repository und DataSource erstellen
6. ⬜ UI Components entwickeln
7. ⬜ Integration in Registrierungs-Flow
8. ⬜ Erinnerungs-System implementieren
9. ⬜ Scoring und Analytics
10. ⬜ Testing und Validierung

## Ressourcen

- [PROMIS Official Website](http://www.healthmeasures.net/explore-measurement-systems/promis)
- [PROMIS Item Banks](http://www.healthmeasures.net/index.php?option=com_instruments&view=search&Itemid=992)
- [PROMIS Scoring Manuals](http://www.healthmeasures.net/score-and-interpret/calculate-scores)
