import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/job_entity.dart';
import '../../domain/repositories/job_repository.dart';
import '../datasources/job_remote_datasource.dart';

class JobRepositoryImpl implements JobRepository {
  final JobRemoteDataSource remoteDataSource;

  JobRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, JobEntity>> createJob(String? title, String rawText, String? sourceUrl) async {
    try {
      final job = await remoteDataSource.createJob(title, rawText, sourceUrl);
      return Right(job);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, List<JobEntity>>> getJobs() async {
    try {
      final jobs = await remoteDataSource.getJobs();
      return Right(jobs);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, String>> scrapeJob(String url) async {
    try {
      final text = await remoteDataSource.scrapeJob(url);
      return Right(text);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }

  @override
  Future<Either<Failure, Unit>> deleteJob(String id) async {
    try {
      await remoteDataSource.deleteJob(id);
      return const Right(unit);
    } on AuthException catch (e) { return Left(AuthFailure(e.message)); }
    on ServerException catch (e) { return Left(ServerFailure(e.message)); }
    on NetworkException catch (e) { return Left(NetworkFailure(e.message)); }
    catch (e) { return Left(ServerFailure(e.toString())); }
  }
}
