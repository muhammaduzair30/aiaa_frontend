import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/job_application_entity.dart';

part 'job_application_model.g.dart';

@JsonSerializable()
class JobApplicationModel extends JobApplicationEntity {
  const JobApplicationModel({
    required super.id,
    @JsonKey(name: 'user_id') required super.userId,
    @JsonKey(name: 'cv_id') required super.cvId,
    @JsonKey(name: 'job_id') required super.jobId,
    @JsonKey(name: 'analysis_id') super.analysisId,
    @JsonKey(name: 'cv', readValue: _readCvFilename) super.cvFilename,
    @JsonKey(name: 'job', readValue: _readJobTitle) super.jobTitle,
    required super.status,
    @JsonKey(name: 'applied_date') super.appliedDate,
    super.notes,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  static Object? _readCvFilename(Map json, String key) {
    return (json[key] as Map<String, dynamic>?)?['original_filename'];
  }

  static Object? _readJobTitle(Map json, String key) {
    return (json[key] as Map<String, dynamic>?)?['job_title'];
  }

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) => _$JobApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobApplicationModelToJson(this);
}
