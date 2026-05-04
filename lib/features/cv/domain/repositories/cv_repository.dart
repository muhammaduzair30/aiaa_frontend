import 'package:dartz/dartz.dart';
import '../../../../core/errors/failures.dart';
import '../entities/cv_entity.dart';

abstract class CVRepository {
  Future<Either<Failure, CVEntity>> uploadCV(List<int> bytes, String fileName);
  Future<Either<Failure, List<CVEntity>>> getCVs();
  Future<Either<Failure, Unit>> deleteCV(String id);
}
