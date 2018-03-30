import 'package:html/dom.dart' as dom;

class Node {
  dom.Element _el;

  Node firstChild;

  Node.domNode(dom.Node node) {
    _el = node as dom.Element;
    firstChild = new Node.domNode(_el.firstChild);
  }

  bool get hasSiblings => (_el.nextElementSibling != null) || (_el.previousElementSibling != null);

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
}

class RootNode {}
