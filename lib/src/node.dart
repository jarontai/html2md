import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

import 'utils.dart' as util;

/// Wrapper class for html node.
class Node {
  dom.Node? _node;
  dom.Element? _el;
  dom.Text? _text;
  Node(dom.Node? domNode) {
    _node = domNode;
    if (domNode is dom.Element) {
      _el = domNode;
    }
    if (domNode is dom.Text) {
      _text = domNode;
    }
  }

  factory Node.root(dynamic input, {String? rootTag}) {
    dom.Element? root;
    if (input is String) {
      var doc = parse(input);
      if (rootTag != null && rootTag.isNotEmpty) {
        root = doc.getElementsByTagName(rootTag).first;
      }
      root ??= doc.getElementsByTagName('html').first;
    } else {
      root = input as dom.Element;
      if (rootTag != null && rootTag.isNotEmpty) {
        root = root.getElementsByTagName(rootTag).first;
      }
    }
    return Node(util.prepareRoot(root));
  }

  int get childNum => _el != null ? _el!.children.length : 0;

  String get className => _el?.className ?? '';

  Node? get firstChild {
    if (_el != null && _el!.firstChild != null) {
      return Node(_el!.firstChild);
    }
    return null;
  }

  bool get hasSiblings =>
      (util.nextSibling(node!) != null) ||
      (util.previousSibling(node!) != null);

  bool get isBlank {
    return ['a', 'th', 'td'].contains(nodeName) &&
        RegExp(r'^\s*$', caseSensitive: false).hasMatch(textContent) &&
        !util.isVoid(_el) &&
        !util.hasVoid(_el);
  }

  bool get isBlock => util.isBlock(_el);

  bool get isCode {
    if (_el == null) return false;
    return _el!.localName!.toLowerCase() == 'code' ||
        (_el!.parent != null
            ? _el!.parent!.localName!.toLowerCase() == 'code'
            : false);
  }

  bool get isParentFirstChild => _node!.parent!.children.first == _el;

  bool get isParentLastChild => _node!.parent!.children.last == _el;

  dom.Node? get nextSibling => util.nextSibling(node!);

  dom.Node? get node => _node;

  String get nodeName => _el != null ? _el!.localName!.toLowerCase() : '';

  int get nodeType => _el?.nodeType ?? _node!.nodeType;

  String get outerHTML => _el?.outerHtml ?? '';

  int get parentChildIndex =>
      _node!.parent != null ? _node!.parent!.children.indexOf(_el!) : -1;

  String get parentElName => (_el != null && _el!.parent != null)
      ? _el!.parent!.localName!.toLowerCase()
      : '';

  int get siblingNum => util.countSiblingEl(node!);

  String get textContent => _text?.data ?? _el?.text ?? '';

  dom.Element? asElement() => _el;

  Iterable<Node> childNodes() sync* {
    for (var node in _el!.nodes) {
      yield Node(node);
    }
  }

  String? getAttribute(String name) {
    return _el!.attributes[name];
  }

  String? getParentAttribute(String name) {
    return _el!.parent!.attributes[name];
  }
}
