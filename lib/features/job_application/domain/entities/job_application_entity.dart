import 'package:equatable/equatable.dart';

class JobApplicationEntity extends Equatable {
  final String id;
  final String userId;
  final String cvId;
  final String jobId;
  final String? analysisId;
  final String status;
  final DateTime? appliedDate;
  final String? notes;
  final DateTime createdAt;

  const JobApplicationEntity({
    required this.id,
    required this.userId,
    required this.cvId,
    required this.jobId,
    this.analysisId,
    required this.status,
    this.appliedDate,
    this.notes,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, userId, cvId, jobId, analysisId, status, appliedDate, notes, createdAt];
}
