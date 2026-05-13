import 'package:dartz/dartz.dart';
import 'package:dio/dio.dart';
import '../../../../core/errors/dio_error_handler.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/analysis_entity.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../datasources/analysis_remote_datasource.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final AnalysisRemoteDataSource remoteDataSource;

  AnalysisRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, AnalysisEntity>> runAnalysis(String cvId, String jdText, String? jobId) async {
    try {
      final analysis = await remoteDataSource.runAnalysis(cvId, jdText, jobId);
      return Right(analysis);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<AnalysisEntity>>> getHistory() async {
    try {
      final history = await remoteDataSource.getHistory();
      return Right(history);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, AnalysisEntity>> getAnalysis(String id) async {
    try {
      final analysis = await remoteDataSource.getAnalysis(id);
      return Right(analysis);
    } on DioException catch (e) {
      return Left(mapDioExceptionToFailure(e));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
