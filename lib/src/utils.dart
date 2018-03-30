import 'package:html/dom.dart';

String repeat(String content, int times) {
  return new List.filled(times, content).join();
}

const kBlockElements = const [
  'address',
  'article',
  'aside',
  'audio',
  'blockquote',
  'body',
  'canvas',
  'center',
  'dd',
  'dir',
  'div',
  'dl',
  'dt',
  'fieldset',
  'figcaption',
  'figure',
  'footer',
  'form',
  'frameset',
  'h1',
  'h2',
  'h3',
  'h4',
  'h5',
  'h6',
  'header',
  'hgroup',
  'hr',
  'html',
  'isindex',
  'li',
  'main',
  'menu',
  'nav',
  'noframes',
  'noscript',
  'ol',
  'output',
  'p',
  'pre',
  'section',
  'table',
  'tbody',
  'td',
  'tfoot',
  'th',
  'thead',
  'tr',
  'ul'
];

const kVoidElements = const [
  'area',
  'base',
  'br',
  'col',
  'command',
  'embed',
  'hr',
  'img',
  'input',
  'keygen',
  'link',
  'meta',
  'param',
  'source',
  'track',
  'wbr'
];

bool isBlock(Node node) {
  return kBlockElements.indexOf((node as Element).localName.toLowerCase()) !=
      -1;
}

bool isVoid(Node node) {
  return kVoidElements.indexOf((node as Element).localName.toLowerCase()) != -1;
}
