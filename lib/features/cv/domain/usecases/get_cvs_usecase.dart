import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cv_entity.dart';
import '../repositories/cv_repository.dart';

class GetCVsUseCase implements UseCase<List<CVEntity>, NoParams> {
  final CVRepository repository;

  GetCVsUseCase(this.repository);

  @override
  Future<Either<Failure, List<CVEntity>>> call(NoParams params) async {
    return await repository.getCVs();
  }
}
