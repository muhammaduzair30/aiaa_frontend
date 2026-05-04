import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_application_entity.dart';
import '../repositories/job_application_repository.dart';

class GetApplicationsUseCase implements UseCase<List<JobApplicationEntity>, NoParams> {
  final JobApplicationRepository repository;

  GetApplicationsUseCase(this.repository);

  @override
  Future<Either<Failure, List<JobApplicationEntity>>> call(NoParams params) async {
    return await repository.getApplications();
  }
}
