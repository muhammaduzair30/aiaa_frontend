import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/analysis_entity.dart';
import 'content_block_model.dart';

part 'analysis_model.g.dart';

@JsonSerializable(explicitToJson: true)
class AnalysisModel extends AnalysisEntity {
  const AnalysisModel({
    required super.id,
    @JsonKey(name: 'cv_id') required super.cvId,
    @JsonKey(name: 'job_id') super.jobId,
    @JsonKey(name: 'jd_text') super.jdText,
    @JsonKey(name: 'match_score') required super.matchScore,
    @JsonKey(name: 'matched_skills') required super.matchedSkills,
    @JsonKey(name: 'missing_critical') required super.missingCriticalSkills,
    @JsonKey(name: 'missing_optional') required super.missingOptionalSkills,
    @JsonKey(name: 'recommendation_summary') required super.recommendationSummary,
    @JsonKey(name: 'optimised_cv') required List<ContentBlockModel> super.optimizedCvContent,
    @JsonKey(name: 'cover_letter') required List<ContentBlockModel> super.generatedCoverLetter,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory AnalysisModel.fromJson(Map<String, dynamic> json) => _$AnalysisModelFromJson(json);

  Map<String, dynamic> toJson() => _$AnalysisModelToJson(this);
}
