import '../domain/entities/survey_question.dart';

/// Static data for all PROMIS survey questions
class SurveyQuestionsData {
  // Response options for different scale types
  static const frequencyOptions = [
    ResponseOption(value: 1, label: 'Nie'),
    ResponseOption(value: 2, label: 'Selten'),
    ResponseOption(value: 3, label: 'Manchmal'),
    ResponseOption(value: 4, label: 'Oft'),
    ResponseOption(value: 5, label: 'Immer'),
  ];

  static const intensityOptions = [
    ResponseOption(value: 1, label: 'Überhaupt nicht'),
    ResponseOption(value: 2, label: 'Ein wenig'),
    ResponseOption(value: 3, label: 'Mäßig'),
    ResponseOption(value: 4, label: 'Ziemlich'),
    ResponseOption(value: 5, label: 'Sehr'),
  ];

  static const agreementOptions = [
    ResponseOption(value: 1, label: 'Stimme überhaupt nicht zu'),
    ResponseOption(value: 2, label: 'Stimme eher nicht zu'),
    ResponseOption(value: 3, label: 'Neutral'),
    ResponseOption(value: 4, label: 'Stimme eher zu'),
    ResponseOption(value: 5, label: 'Stimme völlig zu'),
  ];

  static const qualityRatingOptions = [
    ResponseOption(value: 1, label: 'Sehr schlecht'),
    ResponseOption(value: 2, label: 'Schlecht'),
    ResponseOption(value: 3, label: 'Mittelmäßig'),
    ResponseOption(value: 4, label: 'Gut'),
    ResponseOption(value: 5, label: 'Sehr gut'),
  ];

  static const satisfactionOptions = [
    ResponseOption(value: 1, label: 'Sehr unzufrieden'),
    ResponseOption(value: 2, label: 'Unzufrieden'),
    ResponseOption(value: 3, label: 'Neutral'),
    ResponseOption(value: 4, label: 'Zufrieden'),
    ResponseOption(value: 5, label: 'Sehr zufrieden'),
  ];

  static const helpfulnessOptions = [
    ResponseOption(value: 1, label: 'Überhaupt nicht geholfen'),
    ResponseOption(value: 2, label: 'Kaum geholfen'),
    ResponseOption(value: 3, label: 'Teilweise geholfen'),
    ResponseOption(value: 4, label: 'Ziemlich geholfen'),
    ResponseOption(value: 5, label: 'Sehr geholfen'),
  ];

  static const usageFrequencyOptions = [
    ResponseOption(value: 1, label: 'Nie oder fast nie'),
    ResponseOption(value: 2, label: 'Ein paar Mal im Monat'),
    ResponseOption(value: 3, label: 'Ein paar Mal pro Woche'),
    ResponseOption(value: 4, label: 'Fast täglich'),
    ResponseOption(value: 5, label: 'Täglich oder mehrmals täglich'),
  ];

  static const recommendationOptions = [
    ResponseOption(value: 1, label: 'Definitiv nicht'),
    ResponseOption(value: 2, label: 'Wahrscheinlich nicht'),
    ResponseOption(value: 3, label: 'Vielleicht'),
    ResponseOption(value: 4, label: 'Wahrscheinlich ja'),
    ResponseOption(value: 5, label: 'Definitiv ja'),
  ];

  /// Get all baseline questions (T0 - at registration)
  static List<SurveyQuestion> getBaselineQuestions() {
    return [
      ...depressionQuestions,
      ...anxietyQuestions,
      ...socialIsolationQuestions,
      ...emotionalSupportQuestions,
      ...socialParticipationQuestions,
      ...globalHealthQuestions,
    ];
  }

  /// Get all follow-up questions (T1 - after 8 weeks)
  static List<SurveyQuestion> getFollowUpQuestions() {
    return [
      ...getBaselineQuestions(),
      ...appEffectivenessQuestions,
    ];
  }

  // PROMIS Domain 1: Depression (3 questions)
  static const depressionQuestions = [
    SurveyQuestion(
      id: 'DEP-1',
      domain: 'depression',
      questionText:
          'Wie oft hatten Sie das Gefühl, dass nichts Ihre Stimmung verbessern konnte?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 1,
    ),
    SurveyQuestion(
      id: 'DEP-2',
      domain: 'depression',
      questionText: 'Wie oft haben Sie sich unglücklich gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 2,
    ),
    SurveyQuestion(
      id: 'DEP-3',
      domain: 'depression',
      questionText: 'Wie oft fiel es Ihnen schwer, Dinge zu Ende zu bringen?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 3,
    ),
  ];

  // PROMIS Domain 2: Anxiety
  static const anxietyQuestions = [
    SurveyQuestion(
      id: 'ANX-1',
      domain: 'anxiety',
      questionText: 'Wie oft haben Sie sich ängstlich gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 6,
    ),
    SurveyQuestion(
      id: 'ANX-2',
      domain: 'anxiety',
      questionText: 'Wie oft haben Sie sich angespannt oder nervös gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 7,
    ),
    SurveyQuestion(
      id: 'ANX-3',
      domain: 'anxiety',
      questionText: 'Wie oft haben Sie Schwierigkeiten gehabt, sich zu entspannen?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 8,
    ),
    SurveyQuestion(
      id: 'ANX-4',
      domain: 'anxiety',
      questionText: 'Wie oft haben Sie sich besorgt gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 9,
    ),
    SurveyQuestion(
      id: 'ANX-5',
      domain: 'anxiety',
      questionText:
          'Wie oft hatten Sie plötzliche Angstgefühle ohne erkennbaren Grund?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 10,
    ),
  ];

  // PROMIS Domain 3: Social Isolation
  static const socialIsolationQuestions = [
    SurveyQuestion(
      id: 'SI-1',
      domain: 'social_isolation',
      questionText:
          'Wie oft haben Sie sich von anderen Menschen ausgeschlossen gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 11,
    ),
    SurveyQuestion(
      id: 'SI-2',
      domain: 'social_isolation',
      questionText: 'Wie oft haben Sie sich einsam gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 12,
    ),
    SurveyQuestion(
      id: 'SI-3',
      domain: 'social_isolation',
      questionText: 'Wie oft hatten Sie das Gefühl, dass niemand Sie wirklich kennt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 13,
    ),
    SurveyQuestion(
      id: 'SI-4',
      domain: 'social_isolation',
      questionText:
          'Wie oft haben Sie sich von anderen Menschen isoliert gefühlt?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 14,
    ),
    SurveyQuestion(
      id: 'SI-5',
      domain: 'social_isolation',
      questionText:
          'Wie oft hatten Sie das Gefühl, dass Menschen nur um Sie herum sind, aber nicht mit Ihnen?',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.frequency,
      options: frequencyOptions,
      order: 15,
    ),
  ];

  // PROMIS Domain 4: Emotional Support
  static const emotionalSupportQuestions = [
    SurveyQuestion(
      id: 'ES-1',
      domain: 'emotional_support',
      questionText:
          'Ich habe jemanden, mit dem ich über meine tiefsten Sorgen sprechen kann.',
      timeframe: 'Aktuell',
      type: QuestionType.agreement,
      options: agreementOptions,
      order: 16,
    ),
    SurveyQuestion(
      id: 'ES-2',
      domain: 'emotional_support',
      questionText:
          'Ich habe jemanden, der mir zuhört, wenn ich über meine Probleme sprechen muss.',
      timeframe: 'Aktuell',
      type: QuestionType.agreement,
      options: agreementOptions,
      order: 17,
    ),
    SurveyQuestion(
      id: 'ES-3',
      domain: 'emotional_support',
      questionText:
          'Ich habe jemanden, der mir das Gefühl gibt, geschätzt zu werden.',
      timeframe: 'Aktuell',
      type: QuestionType.agreement,
      options: agreementOptions,
      order: 18,
    ),
    SurveyQuestion(
      id: 'ES-4',
      domain: 'emotional_support',
      questionText:
          'Ich habe jemanden, an den ich mich bei emotionalen Problemen wenden kann.',
      timeframe: 'Aktuell',
      type: QuestionType.agreement,
      options: agreementOptions,
      order: 19,
    ),
    SurveyQuestion(
      id: 'ES-5',
      domain: 'emotional_support',
      questionText:
          'Ich habe jemanden, der mir Trost spendet, wenn ich mich niedergeschlagen fühle.',
      timeframe: 'Aktuell',
      type: QuestionType.agreement,
      options: agreementOptions,
      order: 20,
    ),
  ];

  // PROMIS Domain 5: Social Participation
  static const socialParticipationQuestions = [
    SurveyQuestion(
      id: 'SRA-1',
      domain: 'social_participation',
      questionText:
          'Ich habe Schwierigkeiten, meine üblichen sozialen Aktivitäten mit Familie oder Freunden durchzuführen.',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.intensity,
      options: intensityOptions,
      order: 21,
    ),
    SurveyQuestion(
      id: 'SRA-2',
      domain: 'social_participation',
      questionText:
          'Ich bin in der Lage, an sozialen Aktivitäten teilzunehmen, die mir wichtig sind.',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.intensity,
      options: intensityOptions,
      order: 22,
    ),
    SurveyQuestion(
      id: 'SRA-3',
      domain: 'social_participation',
      questionText:
          'Ich fühle mich in der Lage, mit anderen Menschen in Kontakt zu treten.',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.intensity,
      options: intensityOptions,
      order: 23,
    ),
    SurveyQuestion(
      id: 'SRA-4',
      domain: 'social_participation',
      questionText: 'Ich habe Schwierigkeiten, neue soziale Kontakte zu knüpfen.',
      timeframe: 'In den letzten 7 Tagen',
      type: QuestionType.intensity,
      options: intensityOptions,
      order: 24,
    ),
  ];

  // PROMIS Domain 6: Global Health
  static const globalHealthQuestions = [
    SurveyQuestion(
      id: 'GH-1',
      domain: 'global_health',
      questionText: 'Wie würden Sie Ihre allgemeine Lebensqualität bewerten?',
      timeframe: 'Im Allgemeinen',
      type: QuestionType.rating,
      options: qualityRatingOptions,
      order: 25,
    ),
    SurveyQuestion(
      id: 'GH-2',
      domain: 'global_health',
      questionText: 'Wie würden Sie Ihre allgemeine psychische Gesundheit bewerten?',
      timeframe: 'Im Allgemeinen',
      type: QuestionType.rating,
      options: qualityRatingOptions,
      order: 26,
    ),
    SurveyQuestion(
      id: 'GH-3',
      domain: 'global_health',
      questionText:
          'Wie würden Sie Ihre Zufriedenheit mit Ihren sozialen Beziehungen bewerten?',
      timeframe: 'Im Allgemeinen',
      type: QuestionType.rating,
      options: satisfactionOptions,
      order: 27,
    ),
  ];

  // App Effectiveness Questions (only for follow-up)
  static const appEffectivenessQuestions = [
    SurveyQuestion(
      id: 'APP-1',
      domain: 'app_effectiveness',
      questionText: 'Hat Ihnen die Inner Circle App in den letzten 8 Wochen geholfen?',
      timeframe: 'In den letzten 8 Wochen',
      type: QuestionType.rating,
      options: helpfulnessOptions,
      order: 28,
    ),
    SurveyQuestion(
      id: 'APP-2',
      domain: 'app_effectiveness',
      questionText:
          'In welchen Bereichen hat Ihnen die App am meisten geholfen?',
      timeframe: 'In den letzten 8 Wochen',
      type: QuestionType.multipleChoice,
      options: [], // Will use HelpfulArea enum
      isRequired: false,
      order: 29,
    ),
    SurveyQuestion(
      id: 'APP-3',
      domain: 'app_effectiveness',
      questionText: 'Wie häufig haben Sie die App in den letzten 8 Wochen genutzt?',
      timeframe: 'In den letzten 8 Wochen',
      type: QuestionType.rating,
      options: usageFrequencyOptions,
      order: 30,
    ),
    SurveyQuestion(
      id: 'APP-4',
      domain: 'app_effectiveness',
      questionText:
          'Würden Sie die Inner Circle App anderen Personen in einer ähnlichen Situation empfehlen?',
      timeframe: 'Im Allgemeinen',
      type: QuestionType.rating,
      options: recommendationOptions,
      order: 31,
    ),
    SurveyQuestion(
      id: 'APP-5',
      domain: 'app_effectiveness',
      questionText:
          'Was hat Ihnen an der Inner Circle App am besten gefallen und was könnte verbessert werden?',
      timeframe: 'Im Allgemeinen',
      type: QuestionType.openText,
      options: [],
      isRequired: false,
      order: 32,
    ),
  ];
}
