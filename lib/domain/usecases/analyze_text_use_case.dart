import 'package:dartz/dartz.dart';
import '../entities/analysis_result.dart';
import '../repositories/analysis_repository.dart';

class AnalyzeTextUseCase {
  final AnalysisRepository repository;

  AnalyzeTextUseCase(this.repository);

  Future<Either<String, AnalysisResult>> call(String text) {
    return repository.analyzeText(text);
  }
}
