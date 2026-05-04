import 'package:equatable/equatable.dart';

class ContentBlockEntity extends Equatable {
  final String type;
  final dynamic content;

  const ContentBlockEntity({
    required this.type,
    required this.content,
  });

  @override
  List<Object?> get props => [type, content];
}
