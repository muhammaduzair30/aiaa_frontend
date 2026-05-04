import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/job_entity.dart';

part 'job_model.g.dart';

@JsonSerializable()
class JobModel extends JobEntity {
  const JobModel({
    required super.id,
    @JsonKey(name: 'user_id') required super.userId,
    @JsonKey(name: 'job_title') super.jobTitle,
    @JsonKey(name: 'raw_text') required super.rawText,
    @JsonKey(name: 'source_url') super.sourceUrl,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory JobModel.fromJson(Map<String, dynamic> json) => _$JobModelFromJson(json);

  Map<String, dynamic> toJson() => _$JobModelToJson(this);
}
