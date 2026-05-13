import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/dio_error_handler.dart';
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
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<JobApplicationEntity>>> getApplications() async {
    try {
      final apps = await remoteDataSource.getApplications();
      return Right(apps);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobApplicationEntity>> getApplication(String id) async {
    try {
      final app = await remoteDataSource.getApplication(id);
      return Right(app);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, JobApplicationEntity>> updateApplication(String id, String status, String? notes, DateTime? appliedDate) async {
    try {
      final app = await remoteDataSource.updateApplication(id, status, notes, appliedDate);
      return Right(app);
    } on DioException catch (e) {
      // On Flutter Web, PATCH requests can trigger an XMLHttpRequest onError
      // (connectionError) due to CORS, even when the backend successfully
      // processes the request.  When this happens, verify the update by
      // re-fetching the resource before reporting an error.
      if (e.type == DioExceptionType.connectionError) {
        try {
          final refreshed = await remoteDataSource.getApplication(id);
          if (refreshed.status == status) {
            // Backend applied the update — return success.
            return Right(refreshed);
          }
        } catch (_) {
          // Verification fetch also failed — fall through to original error.
        }
      }
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteApplication(String id) async {
    try {
      await remoteDataSource.deleteApplication(id);
      return const Right(unit);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
