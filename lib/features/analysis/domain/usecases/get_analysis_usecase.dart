import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analysis_entity.dart';
import '../repositories/analysis_repository.dart';

class GetAnalysisUseCase implements UseCase<AnalysisEntity, GetAnalysisParams> {
  final AnalysisRepository repository;

  GetAnalysisUseCase(this.repository);

  @override
  Future<Either<Failure, AnalysisEntity>> call(GetAnalysisParams params) async {
    return await repository.getAnalysis(params.id);
  }
}

class GetAnalysisParams extends Equatable {
  final String id;

  const GetAnalysisParams({required this.id});

  @override
  List<Object?> get props => [id];
}
