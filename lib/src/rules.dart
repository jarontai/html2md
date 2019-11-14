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
  final List<String> filters;
  final FilterFn filterFn;
  final Replacement replacement;
  final Append append;
  final FilterFn _realFilterFn;

  Rule(this.name, {this.filters, this.filterFn, this.replacement, this.append})
      : _realFilterFn = _buildFilterFn(filters, filterFn);

  int get hashCode {
    int result = 17;
    result = 37 * result + name.hashCode;
    return result;
  }

  bool operator ==(dynamic other) {
    if (other is! Rule) return false;
    Rule rule = other;
    return rule.name == name;
  }

  bool _check(Node node) => _realFilterFn == null ? false : _realFilterFn(node);

  static void addIgnore(List<String> names) {
    if (names.isNotEmpty) {
      _commonMarkRules.insert(0, _BaseRules.buildIgnoreRule(names));
    }
  }

  static Rule findRule(Node node, [List<Rule> customRules]) {
    if (customRules != null) {
      var customRule = customRules.firstWhere((rule) => rule._check(node),
          orElse: () => null);
      if (customRule != null) return customRule;
    }

    if (node.isBlank) return _BaseRules.blankRule;
    return _commonMarkRules.firstWhere((rule) => rule._check(node),
        orElse: () => _BaseRules.defaultRule);
  }

  static FilterFn _buildFilterFn(List<String> filters, FilterFn filterFn) {
    FilterFn result;
    if (filters != null && filters.isNotEmpty) {
      result = (Node node) => filters.contains(node.nodeName.toLowerCase());
    }
    return result ?? filterFn;
  }
}

abstract class _BaseRules {
  static final Rule blankRule =
      new Rule('blank', filters: ['blank'], replacement: (content, node) {
    return node.isBlock ? '\n\n' : '';
  });

  static final Rule defaultRule =
      new Rule('default', filters: ['default'], replacement: (content, node) {
    return node.isBlock ? '\n\n' + content + '\n\n' : content;
  });

  static Rule buildIgnoreRule(List<String> names) {
    return new Rule('ignore', filters: names, replacement: (content, node) {
      return '';
    });
  }
}

abstract class _CommonRules {
  static final Rule paragraph =
      new Rule('paragraph', filters: ['p'], replacement: (content, node) {
    return '\n\n$content\n\n';
  });

  static final Rule lineBreak =
      new Rule('lineBreak', filters: ['br'], replacement: (content, node) {
    return '${getStyleOption('br')}\n';
  });

  static final Rule heading =
      new Rule('heading', filters: ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'],
          replacement: (content, node) {
    var hLevel = int.parse(node.nodeName.substring(1, 2));
    if (getStyleOption('headingStyle') == 'setext' && hLevel < 3) {
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
    var postfix = ((node.nextSibling != null) &&
            !new RegExp(r'\n$').hasMatch(convertContent))
        ? '\n'
        : '';
    return '$prefix$convertContent$postfix';
  });

  static final Rule indentedCodeBlock =
      new Rule('indentedCodeBlock', filterFn: (node) {
    return getStyleOption('codeBlockStyle') == 'indented' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'code';
  }, replacement: (content, node) {
    var children = node.childNodes().toList();
    if (children.length == 1) {
      return '\n\n    ' +
          children.first.textContent.replaceAll(new RegExp(r'\n'), '\n    ') +
          '\n\n';
    } else {
      var result = '\n\n    ';
      for (var child in children) {
        var text = child.textContent;
        if (child != children.last) {
          text = text.replaceAll(new RegExp(r'\n'), '\n    ');
        }
        result += text;
      }
      return result + '\n\n';
    }
  });

  static final Rule fencedCodeBlock =
      new Rule('fencedCodeBlock', filterFn: (node) {
    return getStyleOption('codeBlockStyle') == 'fenced' &&
        node.nodeName == 'pre' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'code';
  }, replacement: (content, node) {
    var className = node.firstChild.className ?? '';
    var languageMatched = new RegExp(r'language-(\S+)').firstMatch(className);
    var language =
        languageMatched != null ? languageMatched.group(1) : className;
    return '\n\n' +
        getStyleOption('fence') +
        language +
        '\n' +
        node.firstChild.textContent +
        '\n' +
        getStyleOption('fence') +
        '\n\n';
  });

  static final Rule horizontalRule =
      new Rule('horizontalRule', filters: ['hr'], replacement: (content, node) {
    return '${getStyleOption('hr')}\n';
  });

  static final Rule inlineLink = new Rule('inlineLink', filterFn: (node) {
    return getStyleOption('linkStyle') == 'inlined' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    return '[' + content + '](' + href + title + ')';
  });

  static final Rule referenceLink = new Rule('referenceLink', filterFn: (node) {
    return getStyleOption('linkStyle') == 'referenced' &&
        node.nodeName == 'a' &&
        node.getAttribute('href') != null;
  }, replacement: (content, node) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    var result, reference;
    switch (getStyleOption('linkReferenceStyle')) {
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
    return getStyleOption('emDelimiter') +
        content +
        getStyleOption('emDelimiter');
  });

  static final Rule strong = new Rule('strong', filters: ['strong', 'b'],
      replacement: (content, node) {
    if (content == null || content.trim().isEmpty) return '';
    return getStyleOption('strongDelimiter') +
        content +
        getStyleOption('strongDelimiter');
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
      while (matches.contains(delimiter)) {
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

abstract class _TableRules {
  static final Rule table =
      new Rule('table', filters: ['table'], replacement: (content, node) {
    return '\n$content\n';
  });

  static final Rule tr =
      new Rule('tr', filters: ['tr'], replacement: (content, node) {
    return '$content\n';
  });

  static final Rule tHeadBody =
      new Rule('tHeadBody', filters: ['thead', 'tbody'], replacement: (content, node) {
    return '$content';
  });

  static final Rule th =
      new Rule('th', filters: ['th'], replacement: (content, node) {
    var result = ' $content |';
    if (node.isParentFirstChild) {
      result = '| $content |';
    }
    if (node.isParentLastChild) {
      var sb = new StringBuffer('|');
      for (var i = 0; i < node.siblingNum; i++) {
        sb.write(' ----- |');
      }
      result = '$result\n${sb.toString()}';
    }
    return result;
  });

  static final Rule td =
      new Rule('td', filters: ['td'], replacement: (content, node) {
    var result = ' $content |';
    if (node.isParentFirstChild) {
      result = '| $content |';
    }
    return result;
  });
}
