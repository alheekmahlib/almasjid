import 'package:flutter/material.dart';
import 'package:get/get.dart';

// تحسينات لمعالجة النصوص العربية مع أكواد HTML والتشكيل
// Arabic text processing improvements with HTML codes and diacritics
//
// الميزات المطبقة / Applied Features:
// 1. معالجة أكواد HTML مع أنماط مختلفة / HTML code processing with different styles
// 2. فصل النص الأساسي عن الهوامش / Separating main text from footnotes
// 3. منع دمج الكلمات عند حذف أكواد HTML / Preventing word merging when removing HTML codes
// 4. تطبيق أنماط خاصة للرموز والأقواس / Applying special styles for symbols and quotes
// 5. دعم HTML المتداخل / Nested HTML support

extension TextSpanExtension on String {
  String removeHtmlTags(String htmlString) {
    final RegExp regExp =
        RegExp(r'<.*?[^\/]>', multiLine: true, caseSensitive: false);
    return htmlString.replaceAll(regExp, '');
  }

  List<TextSpan> buildTextSpans() {
    String htmlText = this;
    String text = removeHtmlTags(htmlText);

    // Insert line breaks after specific punctuation marks unless they are within square brackets
    text = text.replaceAllMapped(
        RegExp(r'(\...|\:)(?![^\[]*\])\s*'), (match) => '${match[0]}\n');

    final RegExp regExpQuotes = RegExp(r'\"(.*?)\"');
    final RegExp regExpBraces = RegExp(r'\{(.*?)\}');
    final RegExp regExpParentheses = RegExp(r'\((.*?)\)');
    final RegExp regExpSquareBrackets = RegExp(r'\[(.*?)\]');
    final RegExp regExpDash = RegExp(r'\-(.*?)\-');

    final Iterable<Match> matchesQuotes = regExpQuotes.allMatches(text);
    final Iterable<Match> matchesBraces = regExpBraces.allMatches(text);
    final Iterable<Match> matchesParentheses =
        regExpParentheses.allMatches(text);
    final Iterable<Match> matchesSquareBrackets =
        regExpSquareBrackets.allMatches(text);
    final Iterable<Match> matchesDash = regExpDash.allMatches(text);

    final List<Match> allMatches = [
      ...matchesQuotes,
      ...matchesBraces,
      ...matchesParentheses,
      ...matchesSquareBrackets,
      ...matchesDash
    ]..sort((a, b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    List<TextSpan> spans = [];

    for (final Match match in allMatches) {
      if (match.start >= lastMatchEnd && match.end <= text.length) {
        final String preText = text.substring(lastMatchEnd, match.start);
        final String matchedText = text.substring(match.start, match.end);
        final bool isBraceMatch = regExpBraces.hasMatch(matchedText);
        final bool isParenthesesMatch = regExpParentheses.hasMatch(matchedText);
        final bool isSquareBracketMatch =
            regExpSquareBrackets.hasMatch(matchedText);
        final bool isDashMatch = regExpDash.hasMatch(matchedText);

        if (preText.isNotEmpty) {
          spans.add(TextSpan(text: preText));
        }

        TextStyle matchedTextStyle;
        if (isBraceMatch) {
          matchedTextStyle =
              const TextStyle(color: Color(0xff008000), fontFamily: 'naskh');
        } else if (isParenthesesMatch) {
          matchedTextStyle =
              const TextStyle(color: Color(0xff008000), fontFamily: 'naskh');
        } else if (isSquareBracketMatch) {
          matchedTextStyle = const TextStyle(color: Color(0xff814714));
        } else if (isDashMatch) {
          matchedTextStyle = const TextStyle(color: Color(0xff814714));
        } else {
          matchedTextStyle =
              const TextStyle(color: Color(0xffa24308), fontFamily: 'naskh');
        }

        spans.add(TextSpan(
          text: matchedText,
          style: matchedTextStyle,
        ));

        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(text: text.substring(lastMatchEnd)));
    }

    return spans;
  }

  /// دالة لبناء قائمة TextSpan مع معالجة أكواد HTML والأقواس والرموز الخاصة
  /// Build List TextSpan with HTML code processing and special characters
  List<TextSpan> buildTextString() {
    String text = this;

    // إزالة علامات HTML غير المرغوب فيها / Remove unwanted HTML tags
    text = text.replaceAll(RegExp(r'</?p[^>]*>'), '');
    text = text.replaceAll(RegExp(r'<hr[^>]*>'), '');

    // إدراج سطر جديد بعد كل نقطة فقط (.) دون التأثير على الأقواس أو النقطتين
    // Insert a line break after each period (.) only, avoiding duplicate newlines
    text = text.replaceAllMapped(
      RegExp(r'\.(?!\s*\n)'),
      (match) => '.\n',
    );

    // إدراج سطر جديد قبل الأرقام المتبوعة بشرطة عندما تأتي ملتصقة بكلام قبلها
    // Example: "خطأ4-" => "خطأ\n4-"
    // يدعم الأرقام اللاتينية والعربية-الهندية
    final RegExp gluedNumberDash =
        RegExp(r'([A-Za-z\u0621-\u064A])([0-9\u0660-\u0669]+)\s*-\s*');
    text = text.replaceAllMapped(
      gluedNumberDash,
      (m) => '${m[1]}\n${m[2]}- ',
    );

    List<TextSpan> spans = [];
    int lastIndex = 0;

    // Regular expressions for HTML span classes
    final RegExp htmlSpanRegex = RegExp(
        r'<span class="([^"]*)">(.*?)</span>|<p class="([^"]*)">(.*?)</p>');

    // معالجة النص لإضافة الأنماط للـ HTML والرموز الخاصة / Process text for HTML and special characters
    for (Match match in htmlSpanRegex.allMatches(text)) {
      // إضافة النص العادي قبل المطابقة / Add normal text before match
      if (match.start > lastIndex) {
        String normalText = text.substring(lastIndex, match.start);

        // معالجة الرموز الخاصة في النص العادي / Process special characters in normal text
        List<TextSpan> normalSpans = _processSpecialCharacters(normalText);
        spans.addAll(normalSpans);
      }

      // تحديد نوع الكلاس والنص / Determine class type and text
      String className = match.group(1) ?? match.group(3) ?? '';
      String content = match.group(2) ?? match.group(4) ?? '';

      // تطبيق الأنماط حسب نوع الكلاس / Apply styles based on class type
      TextStyle style;
      switch (className) {
        case 'special':
          style = const TextStyle(
            color: Color(0xff008000),
            fontFamily: 'uthmanic2',
            fontSize: 18,
            fontWeight: FontWeight.bold,
          );
          break;
        case 'c2':
          style = const TextStyle(
            color: Color(0xff0066cc),
            fontFamily: 'cairo',
            fontSize: 18,
            fontWeight: FontWeight.w600,
          );
          break;
        case 'c5':
          style = const TextStyle(
            color: Color(0xff7A9E7E),
            fontFamily: 'cairo',
            fontSize: 18,
            fontStyle: FontStyle.italic,
          );
          break;
        case 'hamesh':
          style = const TextStyle(
            color: Color(0xff666666),
            fontSize: 18,
            fontFamily: 'cairo',
          );
          break;
        default:
          style = TextStyle(
            color: Get.context!.theme.colorScheme.inversePrimary,
            fontSize: 18,
            fontFamily: 'cairo',
          );
      }

      spans.add(TextSpan(
        text: content,
        style: style,
      ));

      lastIndex = match.end;
    }

    // إضافة النص المتبقي / Add remaining text
    if (lastIndex < text.length) {
      String remainingText = text.substring(lastIndex);
      remainingText = remainingText.replaceAll(
          RegExp(r'<[^>]*>'), ''); // إزالة أي HTML متبقي

      // معالجة الرموز الخاصة في النص المتبقي / Process special characters in remaining text
      List<TextSpan> remainingSpans = _processSpecialCharacters(remainingText);
      spans.addAll(remainingSpans);
    }

    return spans;
  }

  /// دالة مساعدة لمعالجة الرموز الخاصة / Helper function to process special characters
  List<TextSpan> _processSpecialCharacters(String text) {
    // تنظيف النص من HTML أولاً مع إضافة مسافات لمنع دمج الكلمات / Clean HTML first with spaces to prevent word merging
    text = _cleanHtmlWithSpaces(text);

    if (text.isEmpty) return [];

    final RegExp regExpQuotes = RegExp(r'\"(.*?)\"');
    final RegExp regExpBraces = RegExp(r'\{(.*?)\}');
    final RegExp regExpCustomParentheses = RegExp(r'\﴾(.*?)\﴿');
    final RegExp regExpParentheses = RegExp(r'\((.*?)\)');
    final RegExp regExpSquareBrackets = RegExp(r'\[(.*?)\]');
    final RegExp regExpDash = RegExp(r'\-(.*?)\-');

    final List<Match> allMatches = [
      ...regExpQuotes.allMatches(text),
      ...regExpBraces.allMatches(text),
      ...regExpParentheses.allMatches(text),
      ...regExpCustomParentheses.allMatches(text),
      ...regExpSquareBrackets.allMatches(text),
      ...regExpDash.allMatches(text)
    ]..sort((a, b) => a.start.compareTo(b.start));

    int lastMatchEnd = 0;
    List<TextSpan> spans = [];

    for (final Match match in allMatches) {
      if (match.start >= lastMatchEnd && match.end <= text.length) {
        final String preText = text.substring(lastMatchEnd, match.start);
        final String matchedText = text.substring(match.start, match.end);
        final bool isBraceMatch = regExpBraces.hasMatch(matchedText);
        final bool isParenthesesMatch = regExpParentheses.hasMatch(matchedText);
        final bool isCustomParenthesesMatch =
            regExpCustomParentheses.hasMatch(matchedText);
        final bool isSquareBracketMatch =
            regExpSquareBrackets.hasMatch(matchedText);
        final bool isDashMatch = regExpDash.hasMatch(matchedText);

        if (preText.isNotEmpty) {
          spans.add(TextSpan(
              text: preText,
              style: TextStyle(
                color: Get.context!.theme.colorScheme.inversePrimary,
                fontSize: 18,
                fontFamily: 'cairo',
              )));
        }

        TextStyle matchedTextStyle;
        if (isBraceMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff008000), fontSize: 18, fontFamily: 'uthmanic2');
        } else if (isParenthesesMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff008000), fontSize: 18, fontFamily: 'naskh');
        } else if (isCustomParenthesesMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff008000), fontSize: 18, fontFamily: 'uthmanic2');
        } else if (isSquareBracketMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff7A9E7E), fontSize: 18, fontFamily: 'cairo');
        } else if (isDashMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff7A9E7E), fontSize: 18, fontFamily: 'cairo');
        } else {
          matchedTextStyle = const TextStyle(
              color: Color(0xff7A9E7E), fontSize: 18, fontFamily: 'cairo');
        }

        spans.add(TextSpan(
          text: matchedText,
          style: matchedTextStyle,
        ));

        lastMatchEnd = match.end;
      }
    }

    if (lastMatchEnd < text.length) {
      spans.add(TextSpan(
          text: text.substring(lastMatchEnd),
          style: TextStyle(
              color: Get.context!.theme.colorScheme.inversePrimary,
              fontSize: 18,
              fontFamily: 'cairo')));
    }

    return spans;
  }

  /// دالة مساعدة لتنظيف النصوص من HTML مع الحفاظ على المسافات / Helper to clean HTML while preserving spaces
  String _cleanHtmlWithSpaces(String text) {
    // إضافة مسافة بدلاً من حذف HTML لمنع دمج الكلمات / Add space instead of removing HTML to prevent word merging
    String cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // الحفاظ على \n: ضغط المسافات فقط وليس الأسطر / Preserve newlines: collapse spaces only, not newlines
    cleanText = cleanText
        .replaceAll(RegExp(r'[ \t\f\r]+'), ' ')
        .replaceAll(RegExp(r' ?\n ?'), '\n')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
    return cleanText;
  }
}
