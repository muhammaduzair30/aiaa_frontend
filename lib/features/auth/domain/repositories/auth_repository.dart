import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/user_entity.dart';

abstract class AuthRepository {
  Future<Either<Failure, UserEntity>> login(String email, String password);
  Future<Either<Failure, UserEntity>> register(String email, String fullName, String password);
  Future<Either<Failure, Unit>> logout();
  Future<Either<Failure, UserEntity>> getCurrentUser();
}
