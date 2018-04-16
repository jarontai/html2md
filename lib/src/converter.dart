import 'package:html/dom.dart' as dom;
import 'package:path/path.dart' as path;

import 'options.dart' show updateOptions;
import 'rules.dart' show Rule;
import 'utils.dart' as util;

import 'node.dart';

final _leadingNewLinesRegExp = new RegExp(r'^\n*');
final _trailingNewLinesRegExp = new RegExp(r'\n*$');

final Set<Rule> _appendRuleSet = new Set<Rule>();
final Map<String, String> _customOptions = <String, String>{};

/// Convert [html] to markdown text.
/// 
/// The root tag which should be converted can be set with [rootTag].
/// The image base url can be set with [imageBaseUrl].
/// Style options can be set with [styleOptions].
/// 
/// The default and available style options:
/// 
/// | Name        | Default           | Options  |
/// | ------------- |:-------------:| -----:|
/// | headingStyle      | "setext" | "setext", "atx" |
/// | hr      | "* * *" | "* * *", "- - -", "_ _ _" |
/// | bulletListMarker      | "*" | "*", "-", "_" |
/// | codeBlockStyle      | "indented" | "indented", "fenced" |
/// | fence      | "\`\`\`" | "\`\`\`", "~~~" |
/// | emDelimiter      | "_" | "_", "*" |
/// | strongDelimiter      | "**" | "**", "__" |
/// | linkStyle      | "inlined" | "inlined", "referenced" |
/// | linkReferenceStyle      | "full" | "full", "collapsed", "shortcut" |
/// 
String convert(String html, { String rootTag, String imageBaseUrl, Map<String, String> styleOptions }) {
  if (html == null || html.isEmpty) {
    return '';
  }
  if (imageBaseUrl != null && imageBaseUrl.isNotEmpty) {
    _customOptions['imageBaseUrl'] = imageBaseUrl;
  }
  updateOptions(styleOptions);
  var output = _process(new Node.root(html, rootTag: rootTag));
  return _postProcess(output);
}

String _postProcess(String input) {
  _appendRuleSet.forEach((rule) {
    input = _join(input, rule.append());
  });

  if (input != null && input.isNotEmpty) {
    return input
        .replaceAll(new RegExp(r'^[\t\r\n]+'), '')
        .replaceAll(new RegExp(r'[\t\r\n\s]+$'), '');
  }
  return '';
}

String _process(Node inNode) {
  var result = '';
  for (var node in inNode.childNodes()) {
    var replacement = '';
    if (node.nodeType == 3) {
      // Text
      var textContent = node.textContent;
      replacement = node.isCode ? textContent : _escape(textContent);
    } else if (node.nodeType == 1) {
      // Element
      replacement = _replacementForNode(node);
    }
    result = _join(result, replacement ?? '');
  }
  return result;
}

String _replacementForNode(Node node) {
  var rule = Rule.findRule(node);
  if (rule != null && rule.append != null) {
    _appendRuleSet.add(rule);
  }
  var content = _process(node);
  var whitespace = _getFlankingWhitespace(node);
  if (whitespace['leading'] != null || whitespace['trailing'] != null) {
    content = content.trim();
  }
  var replacement = rule.replacement(content, node);
  if (rule.name == 'image') {
    var imageSrc = node.getAttribute('src');
    var imageBaseUrl = _customOptions['imageBaseUrl'];
    if (imageSrc != null && imageBaseUrl != null) {
      var newSrc = path.join(imageBaseUrl, imageSrc);
      replacement = replacement.replaceAll(new RegExp(imageSrc), newSrc);
    }
  }
  return '${whitespace['leading'] ?? ''}${replacement}${whitespace['trailing'] ?? ''}';
}

Map<String, String> _getFlankingWhitespace(Node node) {
  Map<String, String> result = {};
  if (!node.isBlock) {
    var hasLeading = new RegExp(r'^[ \r\n\t]').hasMatch(node.textContent);
    var hasTrailing = new RegExp(r'[ \r\n\t]$').hasMatch(node.textContent);

    if (hasLeading && !_isFlankedByWhitespace(node, 'left')) {
      result['leading'] = ' ';
    }
    if (hasTrailing && !_isFlankedByWhitespace(node, 'right')) {
      result['trailing'] = ' ';
    }
  }
  return result;
}

bool _isFlankedByWhitespace(Node node, String side) {
  dom.Node sibling;
  RegExp regExp;
  bool isFlanked = false;

  if (side == 'left') {
    sibling = util.previousSibling(node.node);
    regExp = new RegExp(r' $');
  } else {
    sibling = util.nextSibling(node.node);
    regExp = new RegExp(r'^ ');
  }

  if (sibling != null) {
    if (sibling.nodeType is dom.Text) {
      isFlanked = regExp.hasMatch((sibling as dom.Text).text);
    } else if (sibling is dom.Element && !util.isBlock(sibling)) {
      isFlanked = regExp.hasMatch(sibling.innerHtml);
    }
  }
  return isFlanked;
}

// Determines the new lines between the current output and the replacement
String _separatingNewlines(String output, String replacement) {
  var newlines = [
    _trailingNewLinesRegExp.stringMatch(output),
    _leadingNewLinesRegExp.stringMatch(replacement),
  ];
  newlines.sort((a, b) => a.compareTo(b));

  var maxNewlines = newlines.last;
  return maxNewlines.length < 2 ? maxNewlines : '\n\n';
}

_join(String string1, String string2) {
  var separator = _separatingNewlines(string1, string2);
  // // Remove trailing/leading newlines and replace with separator
  string1 = string1.replaceAll(_trailingNewLinesRegExp, '');
  string2 = string2.replaceAll(_leadingNewLinesRegExp, '');
  return '$string1$separator$string2';
}

_escape(String input) {
  if (input == null) return null;
  return input
      .replaceAllMapped(new RegExp(r'\\(\S)'),
          (match) => '\\\\${match[1]}') // Escape backslash escapes!
      .replaceAllMapped(new RegExp(r'^(#{1,6} )', multiLine: true),
          (match) => '\\${match[1]}') // Escape headings
      .replaceAllMapped(new RegExp(r'^([-*_] *){3,}$', multiLine: true),
          (match) {
        return match[0].split(match[1]).join('\\${match[1]}');
      })
      .replaceAllMapped(new RegExp(r'^(\W* {0,3})(\d+)\. ', multiLine: true),
          (match) => '${match[1]}${match[2]}\\. ')
      .replaceAllMapped(new RegExp(r'^([^\\\w]*)[*+-] ', multiLine: true),
          (match) {
        return match[0].replaceAllMapped(
            new RegExp(r'([*+-])'), (match) => '\\${match[1]}');
      })
      .replaceAllMapped(
          new RegExp(r'^(\W* {0,3})> '), (match) => '${match[1]}\\> ')
      .replaceAllMapped(new RegExp(r'\*+(?![*\s\W]).+?\*+'),
          (match) => match[0].replaceAll(new RegExp(r'\*'), '\\*'))
      .replaceAllMapped(new RegExp(r'_+(?![_\s\W]).+?_+'),
          (match) => match[0].replaceAll(new RegExp(r'_'), '\\_'))
      .replaceAllMapped(new RegExp(r'`+(?![`\s\W]).+?`+'),
          (match) => match[0].replaceAll(new RegExp(r'`'), '\\`'))
      .replaceAllMapped(new RegExp(r'[\[\]]'), (match) => '\\${match[0]}');
}
