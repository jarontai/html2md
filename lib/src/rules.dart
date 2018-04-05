import 'node.dart';
import 'utils.dart' as util;

import 'options.dart' show options;

typedef String Replacement(String content, Node node);
typedef bool FilterFn(Node node);
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

  Rule(
      {this.filters,
      this.filterFn,
      this.replacement,
      this.append,
      Map<String, String> options})
      : _realFilterFn = _buildFilterFn(filters, filterFn);

  static FilterFn _buildFilterFn(List<String> filters, FilterFn filterFn) {
    FilterFn result;
    if (filters != null && filters.isNotEmpty) {
      result = (Node node) =>
          filters.contains(node.nodeName.toLowerCase()); // TODO: upper or lower
    }
    return result ?? filterFn;
  }

  bool _check(Node node) => _realFilterFn == null ? false : _realFilterFn(node);

  static Rule findRule(Node node) {
    if (node.isBlank) return blankRule;

    return _commonMarkRules.values
        .firstWhere((rule) => rule._check(node), orElse: () => defaultRule);
  }
}

final List<String> _linkReferences = [];

final blankRule = new Rule(
    filters: ['blank'],
    replacement: (content, node) {
      return node.isBlock ? '\n\n' : '';
    });
final keepRule = new Rule(
    filters: ['keep'],
    replacement: (content, node) {
      return node.isBlock ? '\n\n' + node.outerHTML + '\n\n' : node.outerHTML;
    });
final defaultRule = new Rule(
    filters: ['default'],
    replacement: (content, node) {
      return node.isBlock ? '\n\n' + content + '\n\n' : content;
    });

final _commonMarkRules = <RuleType, Rule>{
  RuleType.paragraph: new Rule(
      filters: ['p'],
      replacement: (content, node) {
        return '\n\n$content\n\n';
      }),
  RuleType.lineBreak: new Rule(
      filters: ['br'],
      replacement: (content, node) {
        return '${options['br']}\n';
      }),
  RuleType.heading: new Rule(
      filters: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
      replacement: (content, node) {
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
      replacement: (content, node) {
        var convertContent = content
            .replaceAll(new RegExp(r'^\n+|\n+$'), '')
            .replaceAll(new RegExp(r'^', multiLine: true), '> ');
        return '\n\n$convertContent\n\n';
      }),
  RuleType.list: new Rule(
      filters: ['ul', 'ol'],
      replacement: (content, node) {
        if (node.parentElName == 'li' && node.isParentLastChild) {
          return '\n$content';
        } else {
          return '\n\n$content\n\n';
        }
      }),
  RuleType.listItem: new Rule(
      filters: ['li'],
      replacement: (content, node) {
        var convertContent = content
            .replaceAll(new RegExp(r'^\n+'), '')
            .replaceAll(new RegExp(r'\n+$'), '\n')
            .replaceAll(new RegExp('\n', multiLine: true), '\n    ');
        var prefix = options['bulletListMarker'] + '   ';
        if (node.parentElName == 'ol') {
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
  RuleType.indentedCodeBlock: new Rule(filterFn: (node) {
    return options['codeBlockStyle'] == 'indented' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'code';
  }, replacement: (content, node) {
    return '\n\n    ' +
        node.firstChild.textContent.replaceAll(new RegExp(r'\n'), '\n    ') +
        '\n\n';
  }),
  RuleType.fencedCodeBlock: new Rule(filterFn: (node) {
    return options['codeBlockStyle'] == 'fenced' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'code';
  }, replacement: (content, node) {
    var className = node.firstChild.className ?? '';
    var language =
        new RegExp(r'language-(\S+)').firstMatch(className).group(1) ?? '';
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
      replacement: (content, node) {
        return '${options['hr']}\n';
      }),
  RuleType.inlineLink: new Rule(filterFn: (node) {
    return options['linkStyle'] == 'inlined' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    return '[' + content + '](' + href + title + ')';
  }),
  RuleType.referenceLink: new Rule(filterFn: (node) {
    return options['linkStyle'] == 'referenced' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    var result, reference;
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
      replacement: (content, node) {
        if (content == null || content.trim().isEmpty) return '';
        return options['emDelimiter'] + content + options['emDelimiter'];
      }),
  RuleType.strong: new Rule(
      filters: ['strong', 'b'],
      replacement: (content, node) {
        if (content == null || content.trim().isEmpty) return '';
        return options['strongDelimiter'] +
            content +
            options['strongDelimiter'];
      }),
  RuleType.code: new Rule(filterFn: (node) {
    var isCodeBlock = node.nodeName == 'pre' && !node.hasSiblings;
    return node.nodeName == 'code' && !isCodeBlock;
  }, replacement: (content, node) {
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
      replacement: (content, node) {
        var alt = node.getAttribute('alt') ?? '';
        var src = node.getAttribute('src') ?? '';
        var title = node.getAttribute('title') ?? '';
        var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';
        return src.isNotEmpty
            ? '![' + alt + ']' + '(' + src + titlePart + ')'
            : '';
      }),
};
