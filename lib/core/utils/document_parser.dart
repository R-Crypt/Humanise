import 'dart:convert';
import 'dart:typed_data';
import 'package:archive/archive.dart';

class DocumentParser {
  static String extractText(Uint8List bytes, String extension) {
    if (extension == 'txt') {
      return utf8.decode(bytes, allowMalformed: true);
    } else if (extension == 'docx') {
      return _extractFromDocx(bytes);
    } else {
      return "Unsupported file format: .$extension";
    }
  }

  static String _extractFromDocx(Uint8List bytes) {
    try {
      final archive = ZipDecoder().decodeBytes(bytes);
      final documentFile = archive.findFile('word/document.xml');
      
      if (documentFile == null) return "Could not find content in DOCX.";

      String xmlString = utf8.decode(documentFile.content as Uint8List, allowMalformed: true);
      
      // Step 1: Remove all XML tags globally (anything between < and >)
      // This is the most robust way to ensure no XML attributes or tags remain.
      String cleanText = xmlString.replaceAll(RegExp(r'<[^>]*>', multiLine: true, dotAll: true), ' ');

      // Step 2: Decode common XML entities
      cleanText = cleanText.replaceAll('&quot;', '"')
                           .replaceAll('&apos;', "'")
                           .replaceAll('&lt;', '<')
                           .replaceAll('&gt;', '>')
                           .replaceAll('&amp;', '&')
                           .replaceAll('&nbsp;', ' ');
      
      // Step 3: Collapse whitespace
      cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
      
      return cleanText.isEmpty ? "No text content found in DOCX." : cleanText;
    } catch (e) {
      return "Error parsing DOCX: $e";
    }
  }
}
