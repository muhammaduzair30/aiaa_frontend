import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/job_repository.dart';

class ScrapeJobUseCase implements UseCase<String, ScrapeJobParams> {
  final JobRepository repository;

  ScrapeJobUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(ScrapeJobParams params) async {
    return await repository.scrapeJob(params.url);
  }
}

class ScrapeJobParams extends Equatable {
  final String url;

  const ScrapeJobParams({required this.url});

  @override
  List<Object?> get props => [url];
}
