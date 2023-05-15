import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart' show parse;

import 'utils.dart' as util;

/// Wrapper class for html node.
class Node {
  final dom.Node _node;
  final dom.Element? _el;
  final dom.Text? _text;

  const Node._(this._node, this._el, this._text);

  factory Node(dom.Node node) {
    final e = node is dom.Element ? node : null;
    final t = node is dom.Text ? node : null;
    return Node._(node, e, t);
  }

  factory Node.root(Object input, {String? rootTag}) {
    if (rootTag == null || rootTag.isEmpty) {
      rootTag = 'html';
    }
    final root = input is dom.Node ? input : parse(input).getElementsByTagName(rootTag).first;
    return Node(util.prepareRoot(root));
  }

  int get childNum => _el != null ? _el!.children.length : 0;

  String get className => _el?.className ?? '';

  Node? get firstChild {
    final child = _el?.firstChild;
    return child == null ? null : Node(child);
  }

  bool get hasSiblings =>
      (util.nextSibling(node) != null) ||
      (util.previousSibling(node) != null);

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

  bool get isParentFirstChild => _node.parent!.children.first == _el;

  bool get isParentLastChild => _node.parent!.children.last == _el;

  dom.Node? get nextSibling => util.nextSibling(node);

  dom.Node get node => _node;

  String get nodeName => _el != null ? _el!.localName!.toLowerCase() : '';

  int get nodeType => _el?.nodeType ?? _node.nodeType;

  String get outerHTML => _el?.outerHtml ?? '';

  int get parentChildIndex {
    final e = _el;
    return e == null ? -1 : (_node.parent?.children.indexOf(e) ?? -1);
  }

  String get parentElName => (_el != null && _el!.parent != null)
      ? _el!.parent!.localName!.toLowerCase()
      : '';

  int get siblingNum => util.countSiblingEl(node);

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
