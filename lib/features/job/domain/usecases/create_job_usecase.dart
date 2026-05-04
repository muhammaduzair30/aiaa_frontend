import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/job_entity.dart';
import '../repositories/job_repository.dart';

class CreateJobUseCase implements UseCase<JobEntity, CreateJobParams> {
  final JobRepository repository;

  CreateJobUseCase(this.repository);

  @override
  Future<Either<Failure, JobEntity>> call(CreateJobParams params) async {
    return await repository.createJob(params.title, params.rawText, params.sourceUrl);
  }
}

class CreateJobParams extends Equatable {
  final String? title;
  final String rawText;
  final String? sourceUrl;

  const CreateJobParams({this.title, required this.rawText, this.sourceUrl});

  @override
  List<Object?> get props => [title, rawText, sourceUrl];
}
