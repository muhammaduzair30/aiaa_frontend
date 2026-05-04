import 'package:dartz/dartz.dart';
import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/cv_entity.dart';
import '../../domain/repositories/cv_repository.dart';
import '../datasources/cv_remote_datasource.dart';

class CVRepositoryImpl implements CVRepository {
  final CVRemoteDataSource remoteDataSource;

  CVRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, CVEntity>> uploadCV(List<int> bytes, String fileName) async {
    try {
      final cv = await remoteDataSource.uploadCV(bytes, fileName);
      return Right(cv);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<CVEntity>>> getCVs() async {
    try {
      final cvs = await remoteDataSource.getCVs();
      return Right(cvs);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, Unit>> deleteCV(String id) async {
    try {
      await remoteDataSource.deleteCV(id);
      return const Right(unit);
    } on AuthException catch (e) {
      return Left(AuthFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(ServerFailure(e.toString()));
    }
  }
}
