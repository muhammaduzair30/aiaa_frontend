import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/user_entity.dart';
import '../repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<UserEntity, RegisterParams> {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(RegisterParams params) async {
    return await repository.register(params.email, params.fullName, params.password);
  }
}

class RegisterParams extends Equatable {
  final String email;
  final String fullName;
  final String password;

  const RegisterParams({
    required this.email,
    required this.fullName,
    required this.password,
  });

  @override
  List<Object?> get props => [email, fullName, password];
}
