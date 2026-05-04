import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cv_repository.dart';

class DeleteCVUseCase implements UseCase<Unit, DeleteCVParams> {
  final CVRepository repository;

  DeleteCVUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteCVParams params) async {
    return await repository.deleteCV(params.id);
  }
}

class DeleteCVParams extends Equatable {
  final String id;

  const DeleteCVParams({required this.id});

  @override
  List<Object?> get props => [id];
}
