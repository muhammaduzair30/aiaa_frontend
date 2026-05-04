import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class GetJobsUseCase implements UseCase<List<JobEntity>, NoParams> {
  final JobRepository repository;

  GetJobsUseCase(this.repository);

  @override
  Future<Either<Failure, List<JobEntity>>> call(NoParams params) async {
    return await repository.getJobs();
  }
}
