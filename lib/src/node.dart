import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart' as dom;

import 'utils.dart' as util;

class Node {
  dom.Element _el;
  dom.Element get el => _el;

  Node firstChild;

  Node(dom.Node domNode) {
    _el = domNode as dom.Element;
    firstChild = new Node(_el.firstChild);
  }

  bool get hasSiblings =>
      (_el.nextElementSibling != null) || (_el.previousElementSibling != null);

  String get className => _el.className;

  String get textContent => _el.text;

  String get localName => _el.localName.toUpperCase();

  String get nodeName => localName;

  String get parentElName => _el.parent.localName.toUpperCase();

  dom.Element get nextElementSibling => _el.nextElementSibling;

  bool get isParentLastChild => _el.parent.children.last == _el;

  int get parentChildIndex => _el.parent.children.indexOf(_el);

  String getAttribute(String name) {
    return _el.attributes[name];
  }

  String getParentAttribute(String name) {
    return _el.parent.attributes[name];
  }

  bool get isBlock => util.isBlock(_el);

  bool get isBlank {
    return ['A', 'TH', 'TD'].indexOf(nodeName) == -1 &&
        new RegExp(r'^\s*$', caseSensitive: false).hasMatch(textContent) &&
        !util.isVoid(_el) &&
        !util.hasVoid(_el);
  }

  Map get flankingWhitespace {
    var result = {};
    if (!isBlock) {
      var hasLeading = new RegExp(r'^[ \r\n\t]').hasMatch(textContent);
      var hasTrailing = new RegExp(r'[ \r\n\t]$').hasMatch(textContent);

      if (hasLeading && !isFlankedByWhitespace('left')) {
        result['leading'] = ' ';
      }
      if (hasTrailing && !isFlankedByWhitespace('right')) {
        result['trailing'] = ' ';
      }
    }
    return result;
  }

  bool isFlankedByWhitespace(String side) {
    dom.Element sibling;
    RegExp regExp;
    bool isFlanked;

    if (side == 'left') {
      sibling = _el.previousElementSibling;
      regExp = new RegExp(r' $');
    } else {
      sibling = _el.nextElementSibling;
      regExp = new RegExp(r'^ ');
    }

    if (sibling != null) {
      if (sibling.nodeType == 3) {
        isFlanked = regExp.hasMatch(sibling.innerHtml);
      } else if (sibling.nodeType == 1 && !util.isBlock(sibling)) {
        isFlanked = regExp.hasMatch(sibling.text);
      }
    }
    return isFlanked;
  }
}

class RootNode {
  Node root;

  RootNode(String input) {
    var doc = parse('<x-html2md id="html2md-root">' + input + '</x-html2md>');
    root = new Node(doc.getElementById('html2md-root'));
  }
}
