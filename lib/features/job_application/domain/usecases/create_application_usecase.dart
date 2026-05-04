import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_application_entity.dart';
import '../repositories/job_application_repository.dart';

class CreateApplicationUseCase implements UseCase<JobApplicationEntity, CreateApplicationParams> {
  final JobApplicationRepository repository;

  CreateApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, JobApplicationEntity>> call(CreateApplicationParams params) async {
    return await repository.createApplication(params.cvId, params.jobId, params.analysisId, params.status, params.notes);
  }
}

class CreateApplicationParams extends Equatable {
  final String cvId;
  final String jobId;
  final String? analysisId;
  final String status;
  final String? notes;

  const CreateApplicationParams({required this.cvId, required this.jobId, this.analysisId, required this.status, this.notes});

  @override
  List<Object?> get props => [cvId, jobId, analysisId, status, notes];
}
