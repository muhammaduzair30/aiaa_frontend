import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job_entity.dart';

abstract class JobRepository {
  Future<Either<Failure, JobEntity>> createJob(String? title, String rawText, String? sourceUrl);
  Future<Either<Failure, List<JobEntity>>> getJobs();
  Future<Either<Failure, String>> scrapeJob(String url);
  Future<Either<Failure, Unit>> deleteJob(String id);
}
