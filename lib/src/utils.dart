import 'package:html/dom.dart' as dom;

import 'options.dart' show removeTags;

const _kBlockElements = const [
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

const _kVoidElements = const [
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

bool hasVoid(dom.Node node) {
  return node is dom.Element &&
      _asElement(node).querySelectorAll(_kVoidElements.join(',')).isNotEmpty;
}

bool isBlock(dom.Node node) {
  return _kBlockElements.contains(_asElement(node)?.localName?.toLowerCase());
}

bool isVoid(dom.Node node) {
  return _kVoidElements.contains(_asElement(node)?.localName?.toLowerCase());
}

dom.Node nextSibling(dom.Node node) {
  if (node.parentNode == null) return null;
  var siblings = node.parentNode.nodes;
  for (int i = siblings.indexOf(node) + 1; i < siblings.length; i++) {
    var s = siblings[i];
    return s;
  }
  return null;
}

int countSiblingEl(dom.Node node) {
  if (node.parentNode == null) return 0;
  var count = 0;
  node.parentNode.nodes.forEach((node) {
    if (node is dom.Element) {
      count++;
    }
  });
  return count;
}

dom.Node prepareRoot(dom.Node rootNode) {
  dom.Node result = _collapseWhitespace(rootNode, removeTags);
  return result;
}

dom.Node previousSibling(dom.Node node) {
  if (node.parentNode == null) return null;
  var siblings = node.parentNode.nodes;
  for (int i = siblings.indexOf(node) - 1; i >= 0; i--) {
    var s = siblings[i];
    return s;
  }
  return null;
}

String repeat(String content, int times) {
  return new List.filled(times, content).join();
}

// removes extraneous whitespace from the given element.
dom.Element _asElement(dom.Node node) {
  if (node is! dom.Element) {
    return null;
  }
  return node as dom.Element;
}

dom.Node _collapseWhitespace(dom.Node domNode, List<String> removeTags) {
  if (domNode.firstChild == null || _isPre(domNode)) return domNode;

  dom.Node prev;
  dom.Text prevText;
  var prevVoid = false;
  var current = _nextNode(prev, domNode);

  while (current != domNode) {
    if (current.nodeType == 3 || current.nodeType == 4) {
      // Node.TEXT_NODE
      dom.Text textNode = current;
      var text = textNode.data.replaceAll(new RegExp(r'[ \r\n\t]+'), ' ');
      if ((prevText == null || new RegExp(r' $').hasMatch(prevText.data)) &&
          prevVoid == null &&
          text.substring(0, 1) == ' ') {
        text = text.substring(1);
      }

      if (text == null || text.isEmpty) {
        current = _remove(current);
        continue;
      }
      textNode.text = text;
      prevText = textNode;
    } else if (current.nodeType == 1) {
      // Node.ELEMENT_NODE
      dom.Element elNode = current;

      // Remove tags
      if (removeTags.contains(elNode.localName.toLowerCase())) {
        current = _remove(current);
        continue;
      }

      if (isBlock(elNode) || elNode.localName.toLowerCase() == 'br') {
        if (prevText != null) {
          prevText.data = prevText.data.replaceAll(new RegExp(r' $'), '');
        }
        prevText = null;
        prevVoid = false;
      } else if (isVoid(elNode)) {
        prevText = null;
        prevVoid = true;
      }
    } else {
      current = _remove(current);
      continue;
    }

    var next = _nextNode(prev, current);
    prev = current;
    current = next;
  }

  if (prevText != null) {
    prevText.data = prevText.data?.replaceAll(new RegExp(r' $'), '');
    if (prevText.data == null || prevText.data.isEmpty) {
      _remove(prevText);
    }
  }

  return domNode;
}

bool _isPre(dom.Node node) {
  return node is dom.Element &&
      _asElement(node).localName.toLowerCase() == 'pre';
}

dom.Node _nextNode(dom.Node prev, dom.Node current) {
  if ((prev != null && prev.parentNode == current) || _isPre(current)) {
    return nextSibling(current) ?? current.parentNode;
  }
  return current.firstChild ?? nextSibling(current) ?? current.parent;
}

dom.Node _remove(dom.Node node) {
  var next = nextSibling(node) ?? node.parentNode;
  node.remove();
  return next;
}
