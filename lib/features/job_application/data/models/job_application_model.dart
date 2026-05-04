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
    required super.status,
    @JsonKey(name: 'applied_date') super.appliedDate,
    super.notes,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory JobApplicationModel.fromJson(Map<String, dynamic> json) => _$JobApplicationModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobApplicationModelToJson(this);
}
