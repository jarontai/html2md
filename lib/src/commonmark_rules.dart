import 'package:html/dom.dart';

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
    var hLevel = int.parse((node as Element).localName.substring(1, 2));
    if (options['headingStyle'] == 'setext' && hLevel < 3) {
      var underline = util.repeat(hLevel == 1 ? '=' : '-', content.length);
      return '\n\n$content\n$underline\n\n';
    } else {
      return '\n\n${util.repeat("#", hLevel)} $content\n\n';
    }
  }),
  RuleType.blockquote:
      new CommonMarkRule(const ['blockquote'], (content, node, options) {
    var newContent = content
        .replaceAll(new RegExp(r'^\n+|\n+$'), '')
        .replaceAll(new RegExp(r'^', multiLine: true), '> ');
    return '\n\n$newContent\n\n';
  }),
  RuleType.list:
      new CommonMarkRule(const ['ul', 'ol'], (content, node, options) {
        // TODO:
    // var parent = node.parentNode
    // if (parent.nodeName === 'LI' && parent.lastElementChild === node) {
    //   return '\n' + content
    // } else {
    //   return '\n\n' + content + '\n\n'
    // }
    // var parentEl = node.p
    // if (parentEl.localName.toLowerCase() == 'li')

    // return '\n\n$newContent\n\n';
    return '';
  }),  
};
