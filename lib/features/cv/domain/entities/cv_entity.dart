import 'package:equatable/equatable.dart';

class CVEntity extends Equatable {
  final String id;
  final String userId;
  final String originalFilename;
  final DateTime createdAt;

  const CVEntity({
    required this.id,
    required this.userId,
    required this.originalFilename,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, originalFilename, createdAt];
}
