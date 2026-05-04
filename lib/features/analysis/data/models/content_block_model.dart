import 'package:json_annotation/json_annotation.dart';
import '../../domain/entities/content_block_entity.dart';

@JsonSerializable(createFactory: false)
class ContentBlockModel extends ContentBlockEntity {
  const ContentBlockModel({
    required super.type,
    required super.content,
  });

  factory ContentBlockModel.fromJson(Map<String, dynamic> json) {
    // If the type is list, parse it correctly as List<String> instead of dynamic
    dynamic parsedContent = json['content'];
    
    if (json['type'] == 'list' && parsedContent is List) {
      parsedContent = parsedContent.map((e) => e.toString()).toList();
    }
    
    return ContentBlockModel(
      type: json['type'] as String,
      content: parsedContent,
    );
  }

  Map<String, dynamic> toJson() => {
    'type': type,
    'content': content,
  };
}
