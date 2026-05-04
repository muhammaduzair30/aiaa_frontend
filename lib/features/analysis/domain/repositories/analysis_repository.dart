import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/analysis_entity.dart';

abstract class AnalysisRepository {
  Future<Either<Failure, AnalysisEntity>> runAnalysis(String cvId, String jdText, String? jobId);
  Future<Either<Failure, List<AnalysisEntity>>> getHistory();
  Future<Either<Failure, AnalysisEntity>> getAnalysis(String id);
}
