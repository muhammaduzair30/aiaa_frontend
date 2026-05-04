import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_application_entity.dart';
import '../repositories/job_application_repository.dart';

class GetApplicationUseCase implements UseCase<JobApplicationEntity, GetApplicationParams> {
  final JobApplicationRepository repository;

  GetApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, JobApplicationEntity>> call(GetApplicationParams params) async {
    return await repository.getApplication(params.id);
  }
}

class GetApplicationParams extends Equatable {
  final String id;

  const GetApplicationParams({required this.id});

  @override
  List<Object?> get props => [id];
}
