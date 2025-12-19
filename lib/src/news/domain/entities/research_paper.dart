import 'package:equatable/equatable.dart';

/// Research paper entity from CORE API
class ResearchPaper extends Equatable {
  final String id;
  final String title;
  final String? abstract;
  final List<String> authors;
  final String? publishedDate;
  final String? downloadUrl;
  final String? pdfUrl;
  final List<String> topics;

  const ResearchPaper({
    required this.id,
    required this.title,
    this.abstract,
    this.authors = const [],
    this.publishedDate,
    this.downloadUrl,
    this.pdfUrl,
    this.topics = const [],
  });

  @override
  List<Object?> get props => [
        id,
        title,
        abstract,
        authors,
        publishedDate,
        downloadUrl,
        pdfUrl,
        topics,
      ];
}
