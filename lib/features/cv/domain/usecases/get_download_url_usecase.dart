import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../repositories/cv_repository.dart';

class GetDownloadUrlUseCase implements UseCase<String, GetDownloadUrlParams> {
  final CVRepository repository;

  GetDownloadUrlUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(GetDownloadUrlParams params) async {
    return await repository.getDownloadUrl(params.cvId);
  }
}

class GetDownloadUrlParams {
  final String cvId;

  GetDownloadUrlParams({required this.cvId});
}
