import 'dart:async';
import 'dart:math';
import '../../domain/entities/analysis_result.dart';

class MockAnalysisService {
  // Common AI-generated words and phrases
  static const List<String> aiWords = [
    "delve", "underscore", "testament", "tapestry", "meticulous", 
    "comprehensive", "landscape", "pivotal", "key takeaway", "it is important to note",
    "furthermore", "moreover", "in summary", "essentially", "dynamic", "vibrant",
    "unwavering", "resonate", "impactful", "harness", "synergy"
  ];

  // Mapping for humanization
  static const Map<String, String> humanizingMap = {
    "delve": "look into",
    "underscore": "show",
    "testament": "proof",
    "tapestry": "variety",
    "meticulous": "careful",
    "comprehensive": "full",
    "pivotal": "important",
    "furthermore": "also",
    "moreover": "also",
    "impactful": "powerful",
    "harness": "use",
    "synergy": "teamwork",
    "is a testament to": "shows",
    "delve into": "study",
    "it is important to note that": "note that",
  };

  Future<AnalysisResult> analyze(String text) async {
    await Future.delayed(const Duration(seconds: 2));

    final lowerText = text.toLowerCase();
    int aiWordCount = 0;
    List<String> foundAiSentences = [];

    final sentences = text.split(RegExp(r'(?<=[.!?])\s+'));
    for (final sentence in sentences) {
      bool sentenceHasAiWord = false;
      for (final word in aiWords) {
        if (sentence.toLowerCase().contains(word)) {
          aiWordCount++;
          sentenceHasAiWord = true;
        }
      }
      if (sentenceHasAiWord && foundAiSentences.length < 5) {
        foundAiSentences.add(sentence);
      }
    }

    // Heuristic: AI percentage based on density of AI words and sentence structure
    // High density = higher AI score
    double baseAiPercent = (aiWordCount / (sentences.length + 1)) * 1.5;
    
    // Add some random variance for "Realism" but keep it tied to the text
    final random = Random(text.length);
    final aiPercentage = (baseAiPercent + (random.nextDouble() * 0.1)).clamp(0.05, 0.98);
    
    // Plagiarism heuristic (mocked as a small fraction of AI % if high, or random)
    final plagiarismPercentage = (aiPercentage * 0.2 + (random.nextDouble() * 0.1)).clamp(0.01, 0.3);

    return AnalysisResult(
      originalText: text,
      aiPercentage: aiPercentage,
      plagiarismPercentage: plagiarismPercentage,
      flaggedSentences: foundAiSentences,
    );
  }

  Future<String> rewrite(String text) async {
    await Future.delayed(const Duration(seconds: 3));
    
    String rewritten = text;
    
    // 1. Synonym mapping
    humanizingMap.forEach((ai, human) {
      // Case-insensitive replace for better results
      final regExp = RegExp(ai, caseSensitive: false);
      rewritten = rewritten.replaceAll(regExp, human);
    });

    // 2. Simple sentence restructuring (simulation)
    // Replace "It is [adjective] that" with "[Adjective],"
    rewritten = rewritten.replaceAll(RegExp(r"It is (important|pivotal|clear) that", caseSensitive: false), "Clearly,");

    // 3. Passive to Active (very basic simulation: "X is verified by Y" -> "Y verified X")
    // This is hard to do well in Dart without NLP, so we'll just do a few common strings or suffix it.
    
    return "[HUMANISED VERSION]\n\n" + rewritten + "\n\n[End of original adaptation]";
  }
}
