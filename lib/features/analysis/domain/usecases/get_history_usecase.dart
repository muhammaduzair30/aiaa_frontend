import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/analysis_entity.dart';
import '../repositories/analysis_repository.dart';

class GetHistoryUseCase implements UseCase<List<AnalysisEntity>, NoParams> {
  final AnalysisRepository repository;

  GetHistoryUseCase(this.repository);

  @override
  Future<Either<Failure, List<AnalysisEntity>>> call(NoParams params) async {
    return await repository.getHistory();
  }
}
