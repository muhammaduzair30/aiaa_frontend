import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job_application_entity.dart';
import '../../domain/repositories/job_application_repository.dart';
import '../datasources/job_application_remote_datasource.dart';

class JobApplicationRepositoryImpl implements JobApplicationRepository {
  final JobApplicationRemoteDataSource remoteDataSource;

  JobApplicationRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, JobApplicationEntity>> createApplication(String cvId, String jobId, String? analysisId, String status, String? notes) async {
    try {
      final app = await remoteDataSource.createApplication(cvId, jobId, analysisId, status, notes);
      return Right(app);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<JobApplicationEntity>>> getApplications() async {
    try {
      final apps = await remoteDataSource.getApplications();
      return Right(apps);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, JobApplicationEntity>> getApplication(String id) async {
    try {
      final app = await remoteDataSource.getApplication(id);
      return Right(app);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, JobApplicationEntity>> updateApplication(String id, String status, String? notes, DateTime? appliedDate) async {
    try {
      final app = await remoteDataSource.updateApplication(id, status, notes, appliedDate);
      return Right(app);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, Unit>> deleteApplication(String id) async {
    try {
      await remoteDataSource.deleteApplication(id);
      return const Right(unit);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }
}
