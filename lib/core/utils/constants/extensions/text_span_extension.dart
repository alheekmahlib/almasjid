import 'package:flutter/material.dart';

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

  /// دالة لبناء Widget مع معالجة أكواد HTML والأقواس والرموز الخاصة
  /// Build Widget with HTML code processing and special characters
  Widget buildTextString() {
    String text = this;

    // إزالة علامات HTML غير المرغوب فيها / Remove unwanted HTML tags
    text = text.replaceAll(RegExp(r'</?p[^>]*>'), '');
    text = text.replaceAll(RegExp(r'<hr[^>]*>'), '');

    // Insert line breaks after specific punctuation marks unless they are within square brackets
    text = text.replaceAllMapped(
        RegExp(r'(\.|\:)(?![^\[]*\])\s*'), (match) => '${match[0]}\n');

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
            fontFamily: 'naskh',
            fontWeight: FontWeight.w600,
          );
          break;
        case 'c5':
          style = const TextStyle(
            color: Color(0xff814714),
            fontFamily: 'naskh',
            fontStyle: FontStyle.italic,
          );
          break;
        case 'hamesh':
          style = const TextStyle(
            color: Color(0xff666666),
            fontSize: 12,
            fontFamily: 'naskh',
          );
          break;
        default:
          style = const TextStyle(color: Colors.black);
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

    return RichText(
      text: TextSpan(
        children: spans,
        style: const TextStyle(
          fontSize: 16.0,
          color: Colors.black,
          height: 1.5,
        ),
      ),
      textDirection: TextDirection.rtl,
      textAlign: TextAlign.justify,
    );
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
              text: preText, style: const TextStyle(color: Colors.black)));
        }

        TextStyle matchedTextStyle;
        if (isBraceMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff008000), fontFamily: 'uthmanic2');
        } else if (isParenthesesMatch) {
          matchedTextStyle =
              const TextStyle(color: Color(0xff008000), fontFamily: 'naskh');
        } else if (isCustomParenthesesMatch) {
          matchedTextStyle = const TextStyle(
              color: Color(0xff008000), fontFamily: 'uthmanic2');
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
      spans.add(TextSpan(
          text: text.substring(lastMatchEnd),
          style: const TextStyle(color: Colors.black)));
    }

    return spans;
  }

  /// دالة لبناء TextSpans مع معالجة أكواد HTML وتطبيق الأنماط
  /// Build TextSpans with HTML code processing and style application
  List<TextSpan> buildHtmlTextSpans() {
    String text = this;

    // إزالة علامات HTML غير المرغوب فيها / Remove unwanted HTML tags
    text = text.replaceAll(RegExp(r'</?p[^>]*>'), ' ');
    text = text.replaceAll(RegExp(r'<hr[^>]*>'), ' ');

    // تحويل <br> إلى \n / Convert <br> to \n
    text = text.replaceAll(RegExp(r'<br[^>]*>'), '\n');

    List<TextSpan> spans = [];

    // معالجة النص بتقسيمه لقطع وتطبيق الأنماط / Process text by splitting and applying styles
    _processHtmlText(text, spans);

    return spans;
  }

  /// دالة مساعدة لتنظيف النصوص من HTML مع الحفاظ على المسافات / Helper to clean HTML while preserving spaces
  String _cleanHtmlWithSpaces(String text) {
    // إضافة مسافة بدلاً من حذف HTML لمنع دمج الكلمات / Add space instead of removing HTML to prevent word merging
    String cleanText = text.replaceAll(RegExp(r'<[^>]*>'), ' ');
    // تنظيف المسافات المتعددة وترك مسافة واحدة / Clean multiple spaces and leave single space
    cleanText = cleanText.replaceAll(RegExp(r'\s+'), ' ').trim();
    return cleanText;
  }

  /// دالة مساعدة لمعالجة النص مع HTML / Helper function to process text with HTML
  void _processHtmlText(String text, List<TextSpan> spans) {
    if (text.isEmpty) return;

    // البحث عن أول span أو p مع class
    RegExp htmlRegex = RegExp(r'<(span|p)\s+class="([^"]*)"[^>]*>');
    Match? match = htmlRegex.firstMatch(text);

    if (match == null) {
      // لا توجد أكواد HTML، معالج النص كنص عادي
      String cleanText = text.replaceAll(RegExp(r'<br[^>]*>'), '\n');
      cleanText = _cleanHtmlWithSpaces(cleanText);
      if (cleanText.isNotEmpty) {
        spans.addAll(_processSpecialCharacters(cleanText));
      }
      return;
    }

    // إضافة النص قبل أول HTML tag
    if (match.start > 0) {
      String beforeText = text.substring(0, match.start);
      beforeText = beforeText.replaceAll(RegExp(r'<br[^>]*>'), '\n');
      beforeText = _cleanHtmlWithSpaces(beforeText);
      if (beforeText.isNotEmpty) {
        spans.addAll(_processSpecialCharacters(beforeText));
      }
    }

    // العثور على الـ closing tag المناسب
    String tagName = match.group(1)!;
    String className = match.group(2)!;

    int startPos = match.end;
    int openTags = 1;
    int endPos = startPos;

    // البحث عن الـ closing tag مع مراعاة التداخل
    RegExp openRegex = RegExp('<$tagName[^>]*>');
    RegExp closeRegex = RegExp('</$tagName>');

    String remainingText = text.substring(startPos);

    while (openTags > 0 && endPos < text.length) {
      Match? openMatch = openRegex.firstMatch(remainingText);
      Match? closeMatch = closeRegex.firstMatch(remainingText);

      if (closeMatch == null) break;

      if (openMatch != null && openMatch.start < closeMatch.start) {
        openTags++;
        remainingText = remainingText.substring(openMatch.end);
        endPos += openMatch.end;
      } else {
        openTags--;
        if (openTags == 0) {
          endPos = startPos + closeMatch.start;
          break;
        }
        remainingText = remainingText.substring(closeMatch.end);
        endPos += closeMatch.end;
      }
    }

    // استخراج المحتوى داخل الـ tag
    String content = '';
    if (endPos > startPos) {
      content = text.substring(startPos, endPos);
    }

    // تطبيق الأنماط حسب نوع الكلاس
    _applyStyleForClass(className, content, spans);

    // معالجة النص المتبقي
    int nextStart = endPos + tagName.length + 3; // </tagName>
    if (nextStart < text.length) {
      _processHtmlText(text.substring(nextStart), spans);
    }
  }

  /// تطبيق الأنماط حسب نوع الكلاس / Apply styles based on class type
  void _applyStyleForClass(
      String className, String content, List<TextSpan> spans) {
    // تحويل <br> إلى \n أولاً / Convert <br> to \n first
    content = content.replaceAll(RegExp(r'<br[^>]*>'), '\n');

    switch (className) {
      case 'special':
        // معالجة المحتوى كما في buildTextSpans / Process content like in buildTextSpans
        if (content.contains('<')) {
          // إذا كان يحتوي على HTML متداخل، معالجه بشكل خاص
          _processNestedHtml(
              content,
              spans,
              const TextStyle(
                color: Color(0xff008000),
                fontFamily: 'uthmanic2',
                fontSize: 18,
              ));
        } else {
          spans.add(TextSpan(
            text: content,
            style: const TextStyle(
              color: Color(0xff008000),
              fontFamily: 'uthmanic2',
              fontSize: 18,
            ),
          ));
        }
        break;
      case 'c2':
        if (content.contains('<')) {
          _processNestedHtml(
              content,
              spans,
              const TextStyle(
                color: Color(0xff0066cc),
                fontFamily: 'naskh',
              ));
        } else {
          spans.add(TextSpan(
            text: content,
            style: const TextStyle(
              color: Color(0xff0066cc),
              fontFamily: 'naskh',
            ),
          ));
        }
        break;
      case 'c5':
        if (content.contains('<')) {
          _processNestedHtml(
              content,
              spans,
              const TextStyle(
                color: Color(0xff814714),
                fontFamily: 'naskh',
              ));
        } else {
          spans.add(TextSpan(
            text: content,
            style: const TextStyle(
              color: Color(0xff814714),
              fontFamily: 'naskh',
            ),
          ));
        }
        break;
      case 'hamesh':
        // معالجة الهوامش مع منع دمج الكلمات / Process footnotes with word merge prevention
        String cleanContent = _cleanHtmlWithSpaces(content);
        spans.add(TextSpan(
          text: cleanContent,
          style: const TextStyle(
            color: Color(0xff666666),
            fontSize: 12,
            fontFamily: 'naskh',
          ),
        ));
        break;
      default:
        // معالجة النص العادي مع منع دمج الكلمات / Process normal text with word merge prevention
        String cleanContent = _cleanHtmlWithSpaces(content);
        if (cleanContent.isNotEmpty) {
          spans.addAll(_processSpecialCharacters(cleanContent));
        }
    }
  }

  /// معالجة HTML المتداخل / Process nested HTML
  void _processNestedHtml(
      String content, List<TextSpan> spans, TextStyle baseStyle) {
    // البحث عن span متداخل
    RegExp nestedSpanRegex =
        RegExp(r'<span\s+class="([^"]*)"[^>]*>(.*?)</span>');

    int lastIndex = 0;

    for (Match match in nestedSpanRegex.allMatches(content)) {
      // إضافة النص قبل المطابقة
      if (match.start > lastIndex) {
        String beforeText = content.substring(lastIndex, match.start);
        beforeText = _cleanHtmlWithSpaces(beforeText);
        if (beforeText.isNotEmpty) {
          spans.add(TextSpan(text: beforeText, style: baseStyle));
        }
      }

      String nestedClassName = match.group(1) ?? '';
      String nestedContent = match.group(2) ?? '';
      nestedContent = _cleanHtmlWithSpaces(nestedContent);

      // تطبيق نمط للنص المتداخل
      TextStyle nestedStyle;
      switch (nestedClassName) {
        case 'c5':
          nestedStyle = const TextStyle(
            color: Color(0xff814714),
            fontFamily: 'naskh',
          );
          break;
        case 'c2':
          nestedStyle = const TextStyle(
            color: Color(0xff0066cc),
            fontFamily: 'naskh',
          );
          break;
        default:
          nestedStyle = baseStyle;
      }

      if (nestedContent.isNotEmpty) {
        spans.add(TextSpan(text: nestedContent, style: nestedStyle));
      }

      lastIndex = match.end;
    }

    // إضافة النص المتبقي
    if (lastIndex < content.length) {
      String remainingText = content.substring(lastIndex);
      remainingText = _cleanHtmlWithSpaces(remainingText);
      if (remainingText.isNotEmpty) {
        spans.add(TextSpan(text: remainingText, style: baseStyle));
      }
    }
  }
}

extension TextSpanListExtension on List<TextSpan> {
  /// دالة لتمييز النص المبحوث عنه في قائمة من TextSpans
  /// Function to highlight searched text in a list of TextSpans
  List<TextSpan> highlightSearchText(String searchTerm) {
    if (searchTerm.isEmpty) return this;

    List<TextSpan> highlightedSpans = [];

    for (TextSpan span in this) {
      if (span.text != null && span.text!.isNotEmpty) {
        // تطبيق التمييز على النص باستخدام الامتداد الموجود
        // Apply highlighting to text using existing extension
        String text = span.text!;
        List<TextSpan> highlighted = text.highlightLine(searchTerm);

        // إذا كان للـ span الأصلي نمط خاص، احتفظ به للنص غير المُميز
        // If original span has special style, keep it for non-highlighted text
        if (span.style != null) {
          List<TextSpan> styledHighlighted = [];
          for (TextSpan highlightedSpan in highlighted) {
            if (highlightedSpan.style?.backgroundColor != null) {
              // هذا نص مُميز، احتفظ بنمط التمييز
              // This is highlighted text, keep highlighting style
              styledHighlighted.add(highlightedSpan);
            } else {
              // هذا نص عادي، طبق نمط الـ span الأصلي
              // This is normal text, apply original span style
              styledHighlighted.add(TextSpan(
                text: highlightedSpan.text,
                style: span.style,
              ));
            }
          }
          highlightedSpans.addAll(styledHighlighted);
        } else {
          highlightedSpans.addAll(highlighted);
        }
      } else {
        // إذا لم يكن هناك نص، أضف الـ span كما هو
        // If no text, add span as is
        highlightedSpans.add(span);
      }
    }

    return highlightedSpans;
  }
}

extension HighlightExtension on String {
  /// دالة لتمييز النص المبحوث عنه - Function to highlight searched text
  List<TextSpan> highlightLine(String searchTerm) {
    List<TextSpan> spans = [];
    int originalStart = 0;

    // Create mapping between diacritic-free positions and original positions
    List<int> positionMapping = [];
    StringBuffer cleanBuffer = StringBuffer();

    for (int i = 0; i < length; i++) {
      String char = this[i];
      String cleanChar = searchRemoveDiacritics(char);

      if (cleanChar.isNotEmpty) {
        positionMapping.add(i);
        cleanBuffer.write(cleanChar);
      }
    }

    String lineWithoutDiacritics = cleanBuffer.toString();
    String searchTermWithoutDiacritics = searchRemoveDiacritics(searchTerm);
    int cleanIndex = 0;

    while (cleanIndex < lineWithoutDiacritics.length) {
      final startIndex = lineWithoutDiacritics.indexOf(
          searchTermWithoutDiacritics, cleanIndex);

      if (startIndex == -1) {
        if (originalStart < length) {
          spans.add(TextSpan(text: substring(originalStart)));
        }
        break;
      }

      // Add text before the match
      if (startIndex > cleanIndex) {
        int startOriginal = positionMapping[cleanIndex];
        int endOriginal = positionMapping[startIndex];
        spans.add(TextSpan(text: substring(startOriginal, endOriginal)));
      }

      // Calculate match positions in original text
      int matchStartOriginal = positionMapping[startIndex];
      int matchEndOriginal = (startIndex + searchTermWithoutDiacritics.length) <
              lineWithoutDiacritics.length
          ? positionMapping[startIndex + searchTermWithoutDiacritics.length]
          : length;

      // Add highlighted match
      spans.add(TextSpan(
        text: substring(matchStartOriginal, matchEndOriginal),
        style: const TextStyle(
            color: Color(0xffa24308), fontWeight: FontWeight.bold),
      ));

      cleanIndex = startIndex + searchTermWithoutDiacritics.length;
      originalStart = matchEndOriginal;
    }

    return spans;
  }

  /// دالة لإزالة التشكيل من النص - Function to remove diacritics
  String searchRemoveDiacritics(String input) {
    final diacriticsMap = {
      'أ': 'ا',
      'إ': 'ا',
      'آ': 'ا',
      'إٔ': 'ا',
      'إٕ': 'ا',
      'إٓ': 'ا',
      'أَ': 'ا',
      'إَ': 'ا',
      'آَ': 'ا',
      'إُ': 'ا',
      'إٌ': 'ا',
      'إً': 'ا',
      'ة': 'ه',
      'ً': '',
      'ٌ': '',
      'ٍ': '',
      'َ': '',
      'ُ': '',
      'ِ': '',
      'ّ': '',
      'ْ': '',
      'ـ': '',
      'ٰ': '',
      'ٖ': '',
      'ٗ': '',
      'ٕ': '',
      'ٓ': '',
      'ۖ': '',
      'ۗ': '',
      'ۘ': '',
      'ۙ': '',
      'ۚ': '',
      'ۛ': '',
      'ۜ': '',
      '۝': '',
      '۞': '',
      '۟': '',
      '۠': '',
      'ۡ': '',
      'ۢ': '',
    };

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      String? mappedChar = diacriticsMap[char];
      if (mappedChar != null) {
        buffer.write(mappedChar);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }

  /// دالة لإزالة التشكيل من النص - Function to remove diacritics
  String removeDiacritics(String input) {
    final diacriticsMap = {
      'إٔ': 'إ',
      'إٕ': 'إ',
      'إٓ': 'إ',
      'أَ': 'أ',
      'إَ': 'إ',
      'آَ': 'آ',
      'إُ': 'إ',
      'إٌ': 'إ',
      'إً': 'إ',
      'ة': 'ة',
      'ً': '',
      'ٌ': '',
      'ٍ': '',
      'َ': '',
      'ُ': '',
      'ِ': '',
      'ّ': '',
      'ْ': '',
      'ـ': '',
      'ٰ': '',
      'ٖ': '',
      'ٗ': '',
      'ٕ': '',
      'ٓ': '',
      'ۖ': '',
      'ۗ': '',
      'ۘ': '',
      'ۙ': '',
      'ۚ': '',
      'ۛ': '',
      'ۜ': '',
      '۝': '',
      '۞': '',
      '۟': '',
      '۠': '',
      'ۡ': '',
      'ۢ': '',
    };

    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < input.length; i++) {
      String char = input[i];
      String? mappedChar = diacriticsMap[char];
      if (mappedChar != null) {
        buffer.write(mappedChar);
      } else {
        buffer.write(char);
      }
    }
    return buffer.toString();
  }
}
