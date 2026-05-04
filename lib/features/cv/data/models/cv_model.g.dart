// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'cv_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CVModel _$CVModelFromJson(Map<String, dynamic> json) => CVModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      originalFilename: json['original_filename'] as String,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$CVModelToJson(CVModel instance) => <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'original_filename': instance.originalFilename,
      'created_at': instance.createdAt.toIso8601String(),
    };
