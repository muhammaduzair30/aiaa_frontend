// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'analysis_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AnalysisModel _$AnalysisModelFromJson(Map<String, dynamic> json) =>
    AnalysisModel(
      id: json['id'] as String,
      cvId: json['cv_id'] as String,
      jobId: json['job_id'] as String?,
      jdText: json['jd_text'] as String?,
      matchScore: (json['match_score'] as num).toInt(),
      matchedSkills: (json['matched_skills'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingCriticalSkills: (json['missing_critical'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      missingOptionalSkills: (json['missing_optional'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendationSummary: json['recommendation_summary'] as String,
      optimizedCvContent: (json['optimised_cv'] as List<dynamic>)
          .map((e) => ContentBlockModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      generatedCoverLetter: (json['cover_letter'] as List<dynamic>)
          .map((e) => ContentBlockModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$AnalysisModelToJson(AnalysisModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'cv_id': instance.cvId,
      'job_id': instance.jobId,
      'jd_text': instance.jdText,
      'match_score': instance.matchScore,
      'matched_skills': instance.matchedSkills,
      'missing_critical': instance.missingCriticalSkills,
      'missing_optional': instance.missingOptionalSkills,
      'recommendation_summary': instance.recommendationSummary,
      'optimised_cv':
          instance.optimizedCvContent.map((e) => e.toJson()).toList(),
      'cover_letter':
          instance.generatedCoverLetter.map((e) => e.toJson()).toList(),
      'created_at': instance.createdAt.toIso8601String(),
    };
