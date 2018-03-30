import 'node.dart';
import 'utils.dart' as util;

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

typedef String Replacement(String content, Node node, Map options);
typedef bool FilterFn(Node node, Map options);
typedef String Append(Map options);

class Filter {
  List<String> filters;
  FilterFn filterFn;

  Filter(String filter) {
    filters = [filter];
  }

  Filter.list(this.filters);

  Filter.fn(this.filterFn);

  invoke(Node node) {
    // TODO: invoke filter
  }
}

final List<String> _references = [];

class CommonMarkRule {
  final Filter filter;
  final Replacement replacement;
  final Append append;

  CommonMarkRule(this.filter, this.replacement, {this.append});
}

var commonMarkRules = <RuleType, CommonMarkRule>{
  RuleType.paragraph:
      new CommonMarkRule(new Filter('p'), (content, node, options) {
    return '\n\n$content\n\n';
  }),
  RuleType.lineBreak:
      new CommonMarkRule(new Filter('br'), (content, node, options) {
    // TODO: options
    return '${options['br']}\n';
  }),
  RuleType.heading:
      new CommonMarkRule(new Filter.list(['h1', 'h2', 'h3', 'h4', 'h5', 'h6']),
          (content, node, options) {
    // TODO: options
    var hLevel = int.parse(node.nodeName.substring(1, 2));
    if (options['headingStyle'] == 'setext' && hLevel < 3) {
      var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
      return '\n\n$content\n$underline\n\n';
    } else {
      return '\n\n${util.repeat("#", hLevel)} $content\n\n';
    }
  }),
  RuleType.blockquote:
      new CommonMarkRule(new Filter('blockquote'), (content, node, options) {
    var convertContent = content
        .replaceAll(new RegExp(r'^\n+|\n+$'), '')
        .replaceAll(new RegExp(r'^', multiLine: true), '> ');
    return '\n\n$convertContent\n\n';
  }),
  RuleType.list: new CommonMarkRule(new Filter.list(['ul', 'ol']),
      (content, node, options) {
    if (node.parentElName == 'LI' && node.isParentLastChild) {
      return '\n$content';
    } else {
      return '\n\n$content\n\n';
    }
  }),
  RuleType.listItem:
      new CommonMarkRule(new Filter('li'), (content, node, options) {
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
  RuleType.indentedCodeBlock: new CommonMarkRule(new Filter.fn((node, options) {
    return options['codeBlockStyle'] == 'indented' &&
        node.nodeName == 'PRE' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'CODE';
  }), (content, node, options) {
    return '\n\n    ' +
        node.firstChild.textContent.replaceAll(new RegExp(r'\n'), '\n    ') +
        '\n\n';
  }),
  RuleType.fencedCodeBlock: new CommonMarkRule(new Filter.fn((node, options) {
    return options['codeBlockStyle'] == 'fenced' &&
        node.nodeName == 'PRE' &&
        node.firstChild != null &&
        node.firstChild.nodeName == 'CODE';
  }), (content, node, options) {
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
  RuleType.horizontalRule:
      new CommonMarkRule(new Filter('hr'), (content, node, options) {
    // TODO: options
    return '${options['hr']}\n';
  }),
  RuleType.inlineLink: new CommonMarkRule(new Filter.fn((node, options) {
    return options['linkStyle'] == 'inlined' &&
        node.nodeName == 'A' &&
        node.getAttribute('href') != null;
  }), (content, node, options) {
    var href = node.getAttribute('href');
    var title = node.getAttribute('title') ?? '';
    return '[' + content + '](' + href + title + ')';
  }),
  RuleType.referenceLink: new CommonMarkRule(new Filter.fn((node, options) {
    return options['linkStyle'] == 'referenced' &&
        node.nodeName == 'A' &&
        node.getAttribute('href') != null;
  }), (content, node, options) {
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
        var id = _references.length + 1;
        result = '[' + content + '][' + id.toString() + ']';
        reference = '[' + id.toString() + ']: ' + href + title;
    }
    _references.add(reference);
    return result;
  }, append: (options) {
    var result = '';
    if (_references.isNotEmpty) {
      result = '\n\n' + _references.join('\n') + '\n\n';
      _references.clear(); // Reset references
    }
    return result;
  }),
  RuleType.emphasis: new CommonMarkRule(new Filter.list(['em', 'i']),
      (content, node, options) {
    if (content == null || content.trim().isEmpty) return '';
    return options['emDelimiter'] + content + options['emDelimiter'];
  }),
  RuleType.strong: new CommonMarkRule(new Filter.list(['strong', 'b']),
      (content, node, options) {
    if (content == null || content.trim().isEmpty) return '';
    return options['strongDelimiter'] + content + options['strongDelimiter'];
  }),
  RuleType.code: new CommonMarkRule(new Filter.fn((node, options) {
    var isCodeBlock = node.nodeName == 'PRE' && !node.hasSiblings;
    return node.nodeName == 'CODE' && !isCodeBlock;
  }), (content, node, options) {
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
  RuleType.image:
      new CommonMarkRule(new Filter.list(['img']), (content, node, options) {
    var alt = node.getAttribute('alt') ?? '';
    var src = node.getAttribute('src') ?? '';
    var title = node.getAttribute('title') ?? '';
    var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';
    return src.isNotEmpty ? '![' + alt + ']' + '(' + src + titlePart + ')' : '';
  }),
};
