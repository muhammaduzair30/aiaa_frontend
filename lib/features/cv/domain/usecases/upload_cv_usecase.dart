import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../../../../core/errors/failures.dart';
import '../../../../core/usecases/usecase.dart';
import '../entities/cv_entity.dart';
import '../repositories/cv_repository.dart';

class UploadCVUseCase implements UseCase<CVEntity, UploadCVParams> {
  final CVRepository repository;

  UploadCVUseCase(this.repository);

  @override
  Future<Either<Failure, CVEntity>> call(UploadCVParams params) async {
    return await repository.uploadCV(params.bytes, params.fileName);
  }
}

class UploadCVParams extends Equatable {
  final List<int> bytes;
  final String fileName;

  const UploadCVParams({required this.bytes, required this.fileName});

  @override
  List<Object?> get props => [bytes, fileName];
}
