import 'package:dartz/dartz.dart';
import '../entities/analysis_result.dart';

abstract class AnalysisRepository {
  Future<Either<String, AnalysisResult>> analyzeText(String text);
  Future<Either<String, String>> rewriteText(String text);
}
