import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'utils.dart' as util;

class Node {
  dom.Node _node;
  dom.Node get node => _node;
  dom.Element _el;
  dom.Text _text;

  Node get firstChild {
    if (_el != null && _el.firstChild != null) {
      return new Node(_el.firstChild);
    }
    return null;
  }

  factory Node.root(String html) {
    var doc = parse('<x-html2md id="html2md-root">' + html + '</x-html2md>');
    return new Node(util.collapseWhitespace(doc.getElementById('html2md-root')));
  }

  Node(dom.Node domNode) {
    _node = domNode;
    if (domNode is dom.Element) {
      _el = domNode;
    }
    if (domNode is dom.Text) {
      _text = domNode;
    }
  }

  Iterable<Node> childNodes() sync* {
    for (dom.Node node in _el.nodes) {
      yield new Node(node);
    }
  }

  dom.Element asElement() => _el;

  int get nodeType => _el?.nodeType ?? _node.nodeType;

  String get outerHTML => _el.outerHtml;

  bool get hasSiblings =>
      (util.nextSibling(node) != null) || (util.previousSibling(node) != null);

  String get className => _el.className;

  String get textContent => _text?.data ?? _el?.text;

  String get nodeName => _el.localName.toLowerCase();

  String get parentElName => _el.parent.localName.toLowerCase();

  dom.Node get nextSibling => util.nextSibling(node);

  bool get isParentLastChild => _el.parent.children.last == _el;

  int get parentChildIndex => _el.parent.children.indexOf(_el);

  String getAttribute(String name) {
    return _el.attributes[name];
  }

  String getParentAttribute(String name) {
    return _el.parent.attributes[name];
  }

  bool get isBlock => util.isBlock(_el);

  bool get isCode {
    if (_el == null) return false;
    return _el.localName.toLowerCase() == 'code' ||
        (_el.parent != null
            ? _el.parent.localName.toLowerCase() == 'code'
            : false);
  }

  bool get isBlank {
    return ['a', 'th', 'td'].indexOf(nodeName) == -1 &&
        new RegExp(r'^\s*$', caseSensitive: false).hasMatch(textContent) &&
        !util.isVoid(_el) &&
        !util.hasVoid(_el);
  }
}
