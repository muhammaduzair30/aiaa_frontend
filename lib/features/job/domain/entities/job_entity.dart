import 'package:equatable/equatable.dart';

class JobEntity extends Equatable {
  final String id;
  final String userId;
  final String? jobTitle;
  final String rawText;
  final String? sourceUrl;
  final DateTime createdAt;

  const JobEntity({
    required this.id,
    required this.userId,
    this.jobTitle,
    required this.rawText,
    this.sourceUrl,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, jobTitle, rawText, sourceUrl, createdAt];
}
