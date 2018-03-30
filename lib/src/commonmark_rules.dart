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

class CommonMarkRule {
  final List<String> filters;
  final Replacement replacement;

  CommonMarkRule(this.filters, this.replacement);
}

var commonMarkRules = <RuleType, CommonMarkRule>{
  RuleType.paragraph: new CommonMarkRule(const ['p'], (content, node, options) {
    return '\n\n$content\n\n';
  }),
  RuleType.lineBreak:
      new CommonMarkRule(const ['br'], (content, node, options) {
    // TODO: options
    return '${options['br']}\n';
  }),
  RuleType.heading: new CommonMarkRule(
      const ['h1', 'h2', 'h3', 'h4', 'h5', 'h6'], (content, node, options) {
    // TODO: options
    var hLevel = int.parse(node.localName.substring(1, 2));
    if (options['headingStyle'] == 'setext' && hLevel < 3) {
      var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
      return '\n\n$content\n$underline\n\n';
    } else {
      return '\n\n${util.repeat("#", hLevel)} $content\n\n';
    }
  }),
  RuleType.blockquote:
      new CommonMarkRule(const ['blockquote'], (content, node, options) {
    var convertContent = content
        .replaceAll(new RegExp(r'^\n+|\n+$'), '')
        .replaceAll(new RegExp(r'^', multiLine: true), '> ');
    return '\n\n$convertContent\n\n';
  }),
  RuleType.list:
      new CommonMarkRule(const ['ul', 'ol'], (content, node, options) {
    if (node.parentElName == 'LI' && node.parentLastChild == node.el) {
      return '\n$content';
    } else {
      return '\n\n$content\n\n';
    }
  }),
  RuleType.listItem: new CommonMarkRule(const ['li'], (content, node, options) {
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
    if (node.el.nextElementSibling != null) {
      postfix = new RegExp(r'\n$').hasMatch(convertContent) ? '\n' : '';
    }
    return '$prefix$convertContent$postfix';
  }),
};
