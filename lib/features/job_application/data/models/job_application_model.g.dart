// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'job_application_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

JobApplicationModel _$JobApplicationModelFromJson(Map<String, dynamic> json) =>
    JobApplicationModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      cvId: json['cv_id'] as String,
      jobId: json['job_id'] as String,
      analysisId: json['analysis_id'] as String?,
      status: json['status'] as String,
      appliedDate: json['applied_date'] == null
          ? null
          : DateTime.parse(json['applied_date'] as String),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$JobApplicationModelToJson(
        JobApplicationModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'cv_id': instance.cvId,
      'job_id': instance.jobId,
      'analysis_id': instance.analysisId,
      'status': instance.status,
      'applied_date': instance.appliedDate?.toIso8601String(),
      'notes': instance.notes,
      'created_at': instance.createdAt.toIso8601String(),
    };
