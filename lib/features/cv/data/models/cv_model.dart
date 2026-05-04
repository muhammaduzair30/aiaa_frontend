import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/cv_entity.dart';

part 'cv_model.g.dart';

@JsonSerializable()
class CVModel extends CVEntity {
  const CVModel({
    required super.id,
    @JsonKey(name: 'user_id') required super.userId,
    @JsonKey(name: 'original_filename') required super.originalFilename,
    @JsonKey(name: 'created_at') required super.createdAt,
  });

  factory CVModel.fromJson(Map<String, dynamic> json) => _$CVModelFromJson(json);

  Map<String, dynamic> toJson() => _$CVModelToJson(this);
}
