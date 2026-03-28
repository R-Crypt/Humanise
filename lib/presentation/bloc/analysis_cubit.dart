import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../domain/entities/analysis_result.dart';
import '../../domain/usecases/analyze_text_use_case.dart';
import '../../domain/usecases/rewrite_text_use_case.dart';

abstract class AnalysisState extends Equatable {
  @override
  List<Object?> get props => [];
}

class AnalysisInitial extends AnalysisState {}
class AnalysisLoading extends AnalysisState {}
class AnalysisSuccess extends AnalysisState {
  final AnalysisResult result;
  AnalysisSuccess(this.result);
  @override
  List<Object?> get props => [result];
}
class AnalysisFailure extends AnalysisState {
  final String message;
  AnalysisFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class RewriteLoading extends AnalysisState {}
class RewriteSuccess extends AnalysisState {
  final AnalysisResult originalResult;
  final String rewrittenText;
  RewriteSuccess(this.originalResult, this.rewrittenText);
  @override
  List<Object?> get props => [originalResult, rewrittenText];
}

class AnalysisCubit extends Cubit<AnalysisState> {
  final AnalyzeTextUseCase analyzeUseCase;
  final RewriteTextUseCase rewriteUseCase;

  AnalysisCubit({
    required this.analyzeUseCase,
    required this.rewriteUseCase,
  }) : super(AnalysisInitial());

  Future<void> analyze(String text) async {
    emit(AnalysisLoading());
    final result = await analyzeUseCase(text);
    result.fold(
      (failure) => emit(AnalysisFailure(failure)),
      (success) => emit(AnalysisSuccess(success)),
    );
  }

  Future<void> rewrite(AnalysisResult originalResult) async {
    emit(RewriteLoading());
    final result = await rewriteUseCase(originalResult.originalText);
    result.fold(
      (failure) => emit(AnalysisFailure(failure)),
      (success) => emit(RewriteSuccess(originalResult, success)),
    );
  }

  void reset() {
    emit(AnalysisInitial());
  }
}
