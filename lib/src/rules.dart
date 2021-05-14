import 'package:collection/collection.dart' show IterableExtension;

import 'node.dart';
import 'options.dart' show getStyleOption;
import 'utils.dart' as util;

final _commonMarkRules = [
  _CommonRules.paragraph,
  _CommonRules.lineBreak,
  _CommonRules.heading,
  _CommonRules.blockquote,
  _CommonRules.list,
  _CommonRules.listItem,
  _CommonRules.indentedCodeBlock,
  _CommonRules.fencedCodeBlock,
  _CommonRules.horizontalRule,
  _CommonRules.inlineLink,
  _CommonRules.referenceLink,
  _CommonRules.emphasis,
  _CommonRules.strong,
  _CommonRules.strike,
  _CommonRules.code,
  _CommonRules.image,
  _TableRules.table,
  _TableRules.tHeadBody,
  _TableRules.th,
  _TableRules.tr,
  _TableRules.td,
];

final List<String> _linkReferences = [];

typedef Append = String Function();

typedef FilterFn = bool Function(Node node);

typedef Replacement = String Function(String content, Node node);

class Rule {
  final String name;
  final List<String>? filters;
  final FilterFn? filterFn;
  final Replacement? replacement;
  final Append? append;
  final FilterFn? _realFilterFn;
  static final List<Rule> _customRules = [];

  Rule(this.name, {this.filters, this.filterFn, this.replacement, this.append})
      : _realFilterFn = _buildFilterFn(filters, filterFn);

  @override
  int get hashCode {
    var result = 17;
    result = 37 * result + name.hashCode;
    return result;
  }

  @override
  bool operator ==(dynamic other) {
    if (other is! Rule) return false;
    var rule = other;
    return rule.name == name;
  }

  bool _check(Node node) =>
      _realFilterFn == null ? false : _realFilterFn!(node);

  static void addIgnore(List<String> names) {
    if (names.isNotEmpty) {
      _commonMarkRules.insert(0, _BaseRules.buildIgnoreRule(names));
    }
  }

  static void addRules(List<Rule> rules) {
    if (rules.isNotEmpty) {
      _customRules.addAll(rules);
    }
  }

  static Rule findRule(Node node) {
    if (_customRules.isNotEmpty) {
      var customRule =
          _customRules.firstWhereOrNull((rule) => rule._check(node));
      if (customRule != null) return customRule;
    }

    if (node.isBlank) return _BaseRules.blankRule;
    return _commonMarkRules.firstWhere((rule) => rule._check(node),
        orElse: () => _BaseRules.defaultRule);
  }

  static FilterFn? _buildFilterFn(List<String>? filters, FilterFn? filterFn) {
    FilterFn? result;
    if (filters != null && filters.isNotEmpty) {
      result = (Node node) => filters.contains(node.nodeName.toLowerCase());
    }
    return result ?? filterFn;
  }
}

abstract class _BaseRules {
  static final Rule blankRule =
      Rule('blank', filters: ['blank'], replacement: (content, node) {
    return node.isBlock ? '\n\n' : '';
  });

  static final Rule defaultRule =
      Rule('default', filters: ['default'], replacement: (content, node) {
    return node.isBlock ? '\n\n' + content + '\n\n' : content;
  });

  static Rule buildIgnoreRule(List<String> names) {
    return Rule('ignore', filters: names, replacement: (content, node) {
      return '';
    });
  }
}

abstract class _CommonRules {
  static final Rule paragraph =
      Rule('paragraph', filters: ['p'], replacement: (content, node) {
    return '\n\n$content\n\n';
  });

  static final Rule lineBreak =
      Rule('lineBreak', filters: ['br'], replacement: (content, node) {
    return '${getStyleOption('br')}\n';
  });

  static final Rule heading =
      Rule('heading', filters: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
          replacement: (content, node) {
    var hLevel = int.parse(node.nodeName.substring(1, 2));
    if (getStyleOption('headingStyle') == 'setext' && hLevel < 3) {
      var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
      return '\n\n$content\n$underline\n\n';
    } else {
      return '\n\n${util.repeat("#", hLevel)} $content\n\n';
    }
  });

  static final Rule blockquote =
      Rule('blockquote', filters: ['blockquote'], replacement: (content, node) {
    var convertContent = content
        .replaceAll(RegExp(r'^\n+|\n+$'), '')
        .replaceAll(RegExp(r'^', multiLine: true), '> ');
    return '\n\n$convertContent\n\n';
  });

  static final Rule list =
      Rule('list', filters: ['ul', 'ol'], replacement: (content, node) {
    if (node.parentElName == 'li' && node.isParentLastChild) {
      return '\n$content';
    } else {
      return '\n\n$content\n\n';
    }
  });

  static final Rule listItem =
      Rule('listItem', filters: ['li'], replacement: (content, node) {
    var convertContent = content
        .replaceAll(RegExp(r'^\n+'), '')
        .replaceAll(RegExp(r'\n+$'), '\n')
        .replaceAll(RegExp('\n', multiLine: true), '\n    ');
    var prefix = getStyleOption('bulletListMarker') + '   ';
    if (node.parentElName == 'ol') {
      var start = -1;
      var startAttr = node.getParentAttribute('start');
      if (startAttr != null && startAttr.isNotEmpty) {
        try {
          start = int.parse(startAttr);
        } catch (e) {
          print('listItem parse start error $e');
        }
      }

      var index = (start > -1)
          ? start + node.parentChildIndex
          : node.parentChildIndex + 1;
      prefix = '$index.  ';
    }
    var postfix =
        ((node.nextSibling != null) && !RegExp(r'\n$').hasMatch(convertContent))
            ? '\n'
            : '';
    return '$prefix$convertContent$postfix';
  });

  static final Rule indentedCodeBlock =
      Rule('indentedCodeBlock', filterFn: (node) {
    return getStyleOption('codeBlockStyle') == 'indented' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild!.nodeName == 'code';
  }, replacement: (content, node) {
    var children = node.childNodes().toList();
    if (children.length == 1) {
      return '\n\n    ' +
          children.first.textContent.replaceAll(RegExp(r'\n'), '\n    ') +
          '\n\n';
    } else {
      var result = '\n\n    ';
      for (var child in children) {
        var text = child.textContent;
        if (child != children.last) {
          text = text.replaceAll(RegExp(r'\n'), '\n    ');
        }
        result += text;
      }
      return result + '\n\n';
    }
  });

  static final Rule fencedCodeBlock = Rule('fencedCodeBlock', filterFn: (node) {
    return getStyleOption('codeBlockStyle') == 'fenced' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild!.nodeName == 'code';
  }, replacement: (content, node) {
    var className = node.firstChild!.className;
    var languageMatched = RegExp(r'language-(\S+)').firstMatch(className);
    var language =
        languageMatched != null ? languageMatched.group(1)! : className;
    return '\n\n' +
        getStyleOption('fence') +
        language +
        '\n' +
        node.firstChild!.textContent +
        '\n' +
        getStyleOption('fence') +
        '\n\n';
  });

  static final Rule horizontalRule =
      Rule('horizontalRule', filters: ['hr'], replacement: (content, node) {
    return '${getStyleOption('hr')}\n';
  });

  static final Rule inlineLink = Rule('inlineLink', filterFn: (node) {
    return getStyleOption('linkStyle') == 'inlined' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href')!;
    var title = node.getAttribute('title') ?? '';
    var renderedTitle = title.isEmpty ? title : ' "$title"';
    return '[' + content + '](' + href + renderedTitle + ')';
  });

  static final Rule referenceLink = Rule('referenceLink', filterFn: (node) {
    return getStyleOption('linkStyle') == 'referenced' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    var renderedTitle = title.isEmpty ? title : ' "$title"';
    var result, reference;
    switch (getStyleOption('linkReferenceStyle')) {
      case 'collapsed':
        result = '[' + content + '][]';
        reference = '[' + content + ']: ' + href! + renderedTitle;
        break;
      case 'shortcut':
        result = '[' + content + ']';
        reference = '[' + content + ']: ' + href! + renderedTitle;
        break;
      default:
        var id = _linkReferences.length + 1;
        result = '[' + content + '][' + id.toString() + ']';
        reference = '[' + id.toString() + ']: ' + href! + renderedTitle;
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
      Rule('emphasis', filters: ['em', 'i'], replacement: (content, node) {
    if (content.trim().isEmpty) return '';
    return getStyleOption('emDelimiter') +
        content +
        getStyleOption('emDelimiter');
  });

  static final Rule strong =
      Rule('strong', filters: ['strong', 'b'], replacement: (content, node) {
    if (content.trim().isEmpty) return '';
    return getStyleOption('strongDelimiter') +
        content +
        getStyleOption('strongDelimiter');
  });

  static final Rule strike = Rule('strike', filters: ['strike', 's', 'del'],
      replacement: (content, node) {
    if (content.trim().isEmpty) return '';
    return '~~' + content + '~~';
  });

  static final Rule code = Rule('code', filterFn: (node) {
    var isCodeBlock = node.nodeName == 'pre' && !node.hasSiblings;
    return node.nodeName == 'code' && !isCodeBlock;
  }, replacement: (content, node) {
    if (content.trim().isEmpty) return '';

    var delimiter = '`';
    var leadingSpace = '';
    var trailingSpace = '';
    var matches = RegExp(r'`+')
        .allMatches(content)
        .map((match) => match.group(0))
        .toList();
    if (matches.isNotEmpty) {
      if (RegExp(r'^`').hasMatch(content)) leadingSpace = ' ';
      if (RegExp(r'`$').hasMatch(content)) trailingSpace = ' ';
      while (matches.contains(delimiter)) {
        delimiter = delimiter + '`';
      }
    }
    return delimiter + leadingSpace + content + trailingSpace + delimiter;
  });

  static final Rule image =
      Rule('image', filters: ['img'], replacement: (content, node) {
    var alt = node.getAttribute('alt') ?? '';
    var src = node.getAttribute('src') ?? '';
    var title = node.getAttribute('title') ?? '';
    var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';
    return src.isNotEmpty ? '![' + alt + ']' + '(' + src + titlePart + ')' : '';
  });
}

abstract class _TableRules {
  static final Rule table =
      Rule('table', filters: ['table'], replacement: (content, node) {
    return '\n$content\n';
  });

  static final Rule tr =
      Rule('tr', filters: ['tr'], replacement: (content, node) {
    return '$content\n';
  });

  static final Rule tHeadBody = Rule('tHeadBody', filters: ['thead', 'tbody'],
      replacement: (content, node) {
    return '$content';
  });

  static final Rule th =
      Rule('th', filters: ['th'], replacement: (content, node) {
    var result = ' $content |';
    if (node.isParentFirstChild) {
      result = '| $content |';
    }
    if (node.isParentLastChild) {
      var sb = StringBuffer('|');
      for (var i = 0; i < node.siblingNum; i++) {
        sb.write(' ----- |');
      }
      result = '$result\n${sb.toString()}';
    }
    return result;
  });

  static final Rule td =
      Rule('td', filters: ['td'], replacement: (content, node) {
    var result = ' $content |';
    if (node.isParentFirstChild) {
      result = '| $content |';
    }
    return result;
  });
}
