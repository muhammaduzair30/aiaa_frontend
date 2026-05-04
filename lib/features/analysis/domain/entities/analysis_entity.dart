import 'package:equatable/equatable.dart';
import '../../data/models/content_block_model.dart';

class AnalysisEntity extends Equatable {
  final String id;
  final String cvId;
  final String? jobId;
  final String? jdText;
  final int matchScore;
  final List<String> matchedSkills;
  final List<String> missingCriticalSkills;
  final List<String> missingOptionalSkills;
  final String recommendationSummary;
  final List<ContentBlockModel> optimizedCvContent;
  final List<ContentBlockModel> generatedCoverLetter;
  final DateTime createdAt;

  const AnalysisEntity({
    required this.id,
    required this.cvId,
    this.jobId,
    this.jdText,
    required this.matchScore,
    required this.matchedSkills,
    required this.missingCriticalSkills,
    required this.missingOptionalSkills,
    required this.recommendationSummary,
    required this.optimizedCvContent,
    required this.generatedCoverLetter,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
    id, cvId, jobId, jdText, matchScore, 
    matchedSkills, missingCriticalSkills, missingOptionalSkills, 
    recommendationSummary, optimizedCvContent, generatedCoverLetter, createdAt
  ];
}
