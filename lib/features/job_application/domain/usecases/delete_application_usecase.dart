import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/job_application_repository.dart';

class DeleteApplicationUseCase implements UseCase<Unit, DeleteApplicationParams> {
  final JobApplicationRepository repository;

  DeleteApplicationUseCase(this.repository);

  @override
  Future<Either<Failure, Unit>> call(DeleteApplicationParams params) async {
    return await repository.deleteApplication(params.id);
  }
}

class DeleteApplicationParams extends Equatable {
  final String id;

  const DeleteApplicationParams({required this.id});

  @override
  List<Object?> get props => [id];
}
