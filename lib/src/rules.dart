import 'node.dart';
import 'utils.dart' as util;

import 'options.dart' show options;

typedef String Replacement(String content, Node node);
typedef bool FilterFn(Node node);
typedef String Append();

final List<String> _linkReferences = [];

final _commonMarkRules = [
  Rules.paragraph,
  Rules.lineBreak,
  Rules.heading,
  Rules.blockquote,
  Rules.list,
  Rules.listItem,
  Rules.indentedCodeBlock,
  Rules.fencedCodeBlock,
  Rules.horizontalRule,
  Rules.inlineLink,
  Rules.referenceLink,
  Rules.emphasis,
  Rules.strong,
  Rules.code,
  Rules.image,
];

class Rule {
  final String name;
  final List<String> filters;
  final FilterFn filterFn;
  final Replacement replacement;
  final Append append;
  final FilterFn _realFilterFn;

  Rule(this.name, {this.filters, this.filterFn, this.replacement, this.append})
      : _realFilterFn = _buildFilterFn(filters, filterFn);

  static FilterFn _buildFilterFn(List<String> filters, FilterFn filterFn) {
    FilterFn result;
    if (filters != null && filters.isNotEmpty) {
      result = (Node node) => filters.contains(node.nodeName.toLowerCase());
    }
    return result ?? filterFn;
  }

  bool _check(Node node) => _realFilterFn == null ? false : _realFilterFn(node);

  static Rule findRule(Node node, [List<Rule> customRules]) {
    if (customRules != null) {
      var customRule = customRules.firstWhere((rule) => rule._check(node),
          orElse: () => null);
      if (customRule != null) return customRule;
    }

    if (node.isBlank) return Rules._blankRule;
    return _commonMarkRules.firstWhere((rule) => rule._check(node),
        orElse: () => Rules._defaultRule);
  }

  bool operator ==(dynamic other) {
    if (other is! Rule) return false;
    Rule rule = other;
    return rule.name == name;
  }

  int get hashCode {
    int result = 17;
    result = 37 * result + name.hashCode;
    return result;
  }
}

abstract class Rules {
  // static final Rule keepRule = 'keep';
  // final keepRule = new Rule(RuleType.keepRule, filters: ['keep'],
  //     replacement: (content, node) {
  //   return node.isBlock ? '\n\n' + node.outerHTML + '\n\n' : node.outerHTML;
  // });

  static final Rule _blankRule =
      new Rule('blank', filters: ['blank'], replacement: (content, node) {
    return node.isBlock ? '\n\n' : '';
  });

  static final Rule _defaultRule =
      new Rule('default', filters: ['default'], replacement: (content, node) {
    return node.isBlock ? '\n\n' + content + '\n\n' : content;
  });

  static final Rule paragraph =
      new Rule('paragraph', filters: ['p'], replacement: (content, node) {
    return '\n\n$content\n\n';
  });

  static final Rule lineBreak =
      new Rule('lineBreak', filters: ['br'], replacement: (content, node) {
    return '${options['br']}\n';
  });

  static final Rule heading =
      new Rule('heading', filters: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
          replacement: (content, node) {
    var hLevel = int.parse(node.nodeName.substring(1, 2));
    if (options['headingStyle'] == 'setext' && hLevel < 3) {
      var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
      return '\n\n$content\n$underline\n\n';
    } else {
      return '\n\n${util.repeat("#", hLevel)} $content\n\n';
    }
  });

  static final Rule blockquote = new Rule('blockquote', filters: ['blockquote'],
      replacement: (content, node) {
    var convertContent = content
        .replaceAll(new RegExp(r'^\n+|\n+$'), '')
        .replaceAll(new RegExp(r'^', multiLine: true), '> ');
    return '\n\n$convertContent\n\n';
  });

  static final Rule list =
      new Rule('list', filters: ['ul', 'ol'], replacement: (content, node) {
    if (node.parentElName == 'li' && node.isParentLastChild) {
      return '\n$content';
    } else {
      return '\n\n$content\n\n';
    }
  });

  static final Rule listItem =
      new Rule('listItem', filters: ['li'], replacement: (content, node) {
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
    if (node.nextSibling != null) {
      // TODO: ???
      // postfix = new RegExp(r'\n$').hasMatch(convertContent) ? '\n' : '\n';
      postfix = '\n';
    }
    return '$prefix$convertContent$postfix';
  });

  static final Rule indentedCodeBlock =
      new Rule('indentedCodeBlock', filterFn: (node) {
    return options['codeBlockStyle'] == 'indented' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'code';
  }, replacement: (content, node) {
    return '\n\n    ' +
        node.firstChild.textContent.replaceAll(new RegExp(r'\n'), '\n    ') +
        '\n\n';
  });

  static final Rule fencedCodeBlock =
      new Rule('fencedCodeBlock', filterFn: (node) {
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
  });

  static final Rule horizontalRule =
      new Rule('horizontalRule', filters: ['hr'], replacement: (content, node) {
    return '${options['hr']}\n';
  });

  static final Rule inlineLink = new Rule('inlineLink', filterFn: (node) {
    return options['linkStyle'] == 'inlined' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    return '[' + content + '](' + href + title + ')';
  });

  static final Rule referenceLink = new Rule('referenceLink', filterFn: (node) {
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
  }, append: () {
    var result = '';
    if (_linkReferences.isNotEmpty) {
      result = '\n\n' + _linkReferences.join('\n') + '\n\n';
      _linkReferences.clear(); // Reset references
    }
    return result;
  });

  static final Rule emphasis =
      new Rule('emphasis', filters: ['em', 'i'], replacement: (content, node) {
    if (content == null || content.trim().isEmpty) return '';
    return options['emDelimiter'] + content + options['emDelimiter'];
  });

  static final Rule strong = new Rule('strong', filters: ['strong', 'b'],
      replacement: (content, node) {
    if (content == null || content.trim().isEmpty) return '';
    return options['strongDelimiter'] + content + options['strongDelimiter'];
  });

  static final Rule code = new Rule('code', filterFn: (node) {
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
  });

  static final Rule image =
      new Rule('image', filters: ['img'], replacement: (content, node) {
    var alt = node.getAttribute('alt') ?? '';
    var src = node.getAttribute('src') ?? '';
    var title = node.getAttribute('title') ?? '';
    var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';
    return src.isNotEmpty ? '![' + alt + ']' + '(' + src + titlePart + ')' : '';
  });
}
