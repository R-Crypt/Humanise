import 'package:dartz/dartz.dart';
import '../repositories/analysis_repository.dart';

class RewriteTextUseCase {
  final AnalysisRepository repository;

  RewriteTextUseCase(this.repository);

  Future<Either<String, String>> call(String text) {
    return repository.rewriteText(text);
  }
}
