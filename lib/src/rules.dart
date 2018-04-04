import 'node.dart';
import 'utils.dart' as util;

typedef String Replacement(String content, Node node, Map options);
typedef bool FilterFn(Node node, Map<String, String> options);
typedef String Append(Map<String, String> options);

enum RuleType {
  paragraph,
  lineBreak,
  heading,
  blockquote,
  list,
  listItem,
  indentedCodeBlock,
  fencedCodeBlock,
  horizontalRule,
  inlineLink,
  referenceLink,
  emphasis,
  strong,
  code,
  image,
}

class Rule {
  final List<String> filters;
  final FilterFn filterFn;
  final Replacement replacement;
  final Append append;
  final FilterFn _realFilterFn;

  Rule({this.filters, this.filterFn, this.replacement, this.append})
      : _realFilterFn = _buildFilterFn(filters, filterFn);

  static FilterFn _buildFilterFn(List<String> filters, FilterFn filterFn) {
    FilterFn result;
    if (filters != null && filters.isNotEmpty) {
      result = (Node node, Map options) =>
          filters.contains(node.nodeName.toLowerCase()); // TODO: upper or lower
    }
    return result ?? filterFn;
  }

  bool check(Node node, Map<String, String> options) =>
      _realFilterFn == null ? false : _realFilterFn(node, options);
}

final List<String> _linkReferences = [];

final blankRule = new Rule(
    filters: ['blank'],
    replacement: (String content, Node node, Map options) {
      return node.isBlock ? '\n\n' : '';
    });
final keepRule = new Rule(
    filters: ['keep'],
    replacement: (String content, Node node, Map options) {
      return node.isBlock ? '\n\n' + node.outerHTML + '\n\n' : node.outerHTML;
    });
final defaultRule = new Rule(
    filters: ['default'],
    replacement: (String content, Node node, Map options) {
      return node.isBlock ? '\n\n' + content + '\n\n' : content;
    });

final _commonMarkRules = <RuleType, Rule>{
  RuleType.paragraph: new Rule(
      filters: ['p'],
      replacement: (content, node, options) {
        return '\n\n$content\n\n';
      }),
  RuleType.lineBreak: new Rule(
      filters: ['br'],
      replacement: (content, node, options) {
        // TODO: options
        return '${options['br']}\n';
      }),
  RuleType.heading: new Rule(
      filters: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
      replacement: (content, node, options) {
        // TODO: options
        var hLevel = int.parse(node.nodeName.substring(1, 2));
        if (options['headingStyle'] == 'setext' && hLevel < 3) {
          var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
          return '\n\n$content\n$underline\n\n';
        } else {
          return '\n\n${util.repeat("#", hLevel)} $content\n\n';
        }
      }),
  RuleType.blockquote: new Rule(
      filters: ['blockquote'],
      replacement: (content, node, options) {
        var convertContent = content
            .replaceAll(new RegExp(r'^\n+|\n+$'), '')
            .replaceAll(new RegExp(r'^', multiLine: true), '> ');
        return '\n\n$convertContent\n\n';
      }),
  RuleType.list: new Rule(
      filters: ['ul', 'ol'],
      replacement: (content, node, options) {
        if (node.parentElName == 'LI' && node.isParentLastChild) {
          return '\n$content';
        } else {
          return '\n\n$content\n\n';
        }
      }),
  RuleType.listItem: new Rule(
      filters: ['li'],
      replacement: (content, node, options) {
        var convertContent = content
            .replaceAll(new RegExp(r'^\n+'), '')
            .replaceAll(new RegExp(r'\n+$'), '\n')
            .replaceAll(new RegExp('\n', multiLine: true), '\n    ');
        // TODO: options
        var prefix = options['bulletListMarker'] + '   ';
        if (node.parentElName == 'OL') {
          var start = -1;
          try {
            start = int.parse(node.getParentAttribute('start'));
          } catch (e) {
            print('listItem parse start error $e');
          }
          var index = (start > -1)
              ? start + node.parentChildIndex
              : node.parentChildIndex + 1;
          prefix = '$index.  ';
        }
        var postfix = '';
        if (node.nextElementSibling != null) {
          postfix = new RegExp(r'\n$').hasMatch(convertContent) ? '\n' : '';
        }
        return '$prefix$convertContent$postfix';
      }),
  RuleType.indentedCodeBlock: new Rule(filterFn: (node, options) {
    return options['codeBlockStyle'] == 'indented' &&
        node.nodeName == 'PRE' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'CODE';
  }, replacement: (content, node, options) {
    return '\n\n    ' +
        node.firstChild.textContent.replaceAll(new RegExp(r'\n'), '\n    ') +
        '\n\n';
  }),
  RuleType.fencedCodeBlock: new Rule(filterFn: (node, options) {
    return options['codeBlockStyle'] == 'fenced' &&
        node.nodeName == 'PRE' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'CODE';
  }, replacement: (content, node, options) {
    var className = node.firstChild.className ?? '';
    var language =
        new RegExp(r'language-(\S+)').firstMatch(className).group(1) ?? '';
    // TODO: options
    return '\n\n' +
        options['fence'] +
        language +
        '\n' +
        node.firstChild.textContent +
        '\n' +
        options['fence'] +
        '\n\n';
  }),
  RuleType.horizontalRule: new Rule(
      filters: ['hr'],
      replacement: (content, node, options) {
        // TODO: options
        return '${options['hr']}\n';
      }),
  RuleType.inlineLink: new Rule(filterFn: (node, options) {
    // TODO: options
    return options['linkStyle'] == 'inlined' &&
        node.nodeName == 'A' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node, options) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    return '[' + content + '](' + href + title + ')';
  }),
  RuleType.referenceLink: new Rule(filterFn: (node, options) {
    // TODO: options
    return options['linkStyle'] == 'referenced' &&
        node.nodeName == 'A' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node, options) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    var result, reference;
    // TODO: options
    switch (options['linkReferenceStyle']) {
      case 'collapsed':
        result = '[' + content + '][]';
        reference = '[' + content + ']: ' + href + title;
        break;
      case 'shortcut':
        result = '[' + content + ']';
        reference = '[' + content + ']: ' + href + title;
        break;
      default:
        var id = _linkReferences.length + 1;
        result = '[' + content + '][' + id.toString() + ']';
        reference = '[' + id.toString() + ']: ' + href + title;
    }
    _linkReferences.add(reference);
    return result;
  }, append: (options) {
    var result = '';
    if (_linkReferences.isNotEmpty) {
      result = '\n\n' + _linkReferences.join('\n') + '\n\n';
      _linkReferences.clear(); // Reset references
    }
    return result;
  }),
  RuleType.emphasis: new Rule(
      filters: ['em', 'i'],
      replacement: (content, node, options) {
        if (content == null || content.trim().isEmpty) return '';
        // TODO: options
        return options['emDelimiter'] + content + options['emDelimiter'];
      }),
  RuleType.strong: new Rule(
      filters: ['strong', 'b'],
      replacement: (content, node, options) {
        if (content == null || content.trim().isEmpty) return '';
        // TODO: options
        return options['strongDelimiter'] +
            content +
            options['strongDelimiter'];
      }),
  RuleType.code: new Rule(filterFn: (node, options) {
    var isCodeBlock = node.nodeName == 'PRE' && !node.hasSiblings;
    return node.nodeName == 'CODE' && !isCodeBlock;
  }, replacement: (content, node, options) {
    if (content == null || content.trim().isEmpty) return '';

    var delimiter = '`';
    var leadingSpace = '';
    var trailingSpace = '';
    var matches = new RegExp(r'`+')
        .allMatches(content)
        .map((match) => match.group(0))
        .toList();
    if (matches != null && matches.isNotEmpty) {
      if (new RegExp(r'^`').hasMatch(content)) leadingSpace = ' ';
      if (new RegExp(r'`$').hasMatch(content)) trailingSpace = ' ';
      while (matches.indexOf(delimiter) != -1) {
        delimiter = delimiter + '`';
      }
    }
    return delimiter + leadingSpace + content + trailingSpace + delimiter;
  }),
  RuleType.image: new Rule(
      filters: ['img'],
      replacement: (content, node, options) {
        var alt = node.getAttribute('alt') ?? '';
        var src = node.getAttribute('src') ?? '';
        var title = node.getAttribute('title') ?? '';
        var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';
        return src.isNotEmpty
            ? '![' + alt + ']' + '(' + src + titlePart + ')'
            : '';
      }),
};

findRule(Node node, [Map<String, String> options = const <String, String>{}]) {
  if (node.isBlank) return blankRule;

  return _commonMarkRules.values.firstWhere((rule) => rule.check(node, options),
      orElse: () => defaultRule);
}
