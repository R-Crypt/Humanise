import 'package:dartz/dartz.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/repositories/analysis_repository.dart';
import '../services/mock_analysis_service.dart';

class AnalysisRepositoryImpl implements AnalysisRepository {
  final MockAnalysisService service;

  AnalysisRepositoryImpl(this.service);

  @override
  Future<Either<String, AnalysisResult>> analyzeText(String text) async {
    try {
      final result = await service.analyze(text);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }

  @override
  Future<Either<String, String>> rewriteText(String text) async {
    try {
      final result = await service.rewrite(text);
      return Right(result);
    } catch (e) {
      return Left(e.toString());
    }
  }
}
