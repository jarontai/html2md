import 'package:html/dom.dart' as dom;

class Node {
  dom.Element el;

  Node.domNode(dom.Node node) {
    el = node as dom.Element;
  }

  String get localName => el.localName.toUpperCase();
  
  String get parentElName => el.parent.localName.toUpperCase();

  dom.Element get parentLastChild => el.parent.children.last;

  int get parentChildIndex => el.parent.children.indexOf(el);

  String getParentAttribute(String name) {
    return el.parent.attributes[name];
  }
}

class RootNode {

}