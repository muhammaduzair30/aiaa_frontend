import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/job_repository.dart';

class DeleteJobUseCase implements UseCase<Unit, DeleteJobParams> {
  final JobRepository repository;

  DeleteJobUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteJobParams params) async {
    return await repository.deleteJob(params.id);
  }
}

class DeleteJobParams extends Equatable {
  final String id;

  const DeleteJobParams({required this.id});

  @override
  List<Object?> get props => [id];
}
