import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analysis_entity.dart';
import '../repositories/analysis_repository.dart';

class RunAnalysisUseCase implements UseCase<AnalysisEntity, RunAnalysisParams> {
  final AnalysisRepository repository;

  RunAnalysisUseCase(this.repository);

  @override
  Future<Either<Failure, AnalysisEntity>> call(RunAnalysisParams params) async {
    return await repository.runAnalysis(params.cvId, params.jdText, params.jobId);
  }
}

class RunAnalysisParams extends Equatable {
  final String cvId;
  final String jdText;
  final String? jobId;

  const RunAnalysisParams({
    required this.cvId,
    required this.jdText,
    this.jobId,
  });

  @override
  List<Object?> get props => [cvId, jdText, jobId];
}
