import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_application_entity.dart';
import '../repositories/job_application_repository.dart';

class UpdateApplicationUseCase implements UseCase<JobApplicationEntity, UpdateApplicationParams> {
  final JobApplicationRepository repository;

  UpdateApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, JobApplicationEntity>> call(UpdateApplicationParams params) async {
    return await repository.updateApplication(params.id, params.status, params.notes, params.appliedDate);
  }
}

class UpdateApplicationParams extends Equatable {
  final String id;
  final String status;
  final String? notes;
  final DateTime? appliedDate;

  const UpdateApplicationParams({required this.id, required this.status, this.notes, this.appliedDate});

  @override
  List<Object?> get props => [id, status, notes, appliedDate];
}
