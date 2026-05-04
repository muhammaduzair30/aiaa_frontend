import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/job_application_entity.dart';

abstract class JobApplicationRepository {
  Future<Either<Failure, JobApplicationEntity>> createApplication(String cvId, String jobId, String? analysisId, String status, String? notes);
  Future<Either<Failure, List<JobApplicationEntity>>> getApplications();
  Future<Either<Failure, JobApplicationEntity>> getApplication(String id);
  Future<Either<Failure, JobApplicationEntity>> updateApplication(String id, String status, String? notes, DateTime? appliedDate);
  Future<Either<Failure, Unit>> deleteApplication(String id);
}
