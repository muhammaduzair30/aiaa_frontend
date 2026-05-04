// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobModel _$JobModelFromJson(Map<String, dynamic> json) => JobModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      jobTitle: json['job_title'] as String?,
      rawText: json['raw_text'] as String,
      sourceUrl: json['source_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$JobModelToJson(JobModel instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'job_title': instance.jobTitle,
      'raw_text': instance.rawText,
      'source_url': instance.sourceUrl,
      'created_at': instance.createdAt.toIso8601String(),
    };
