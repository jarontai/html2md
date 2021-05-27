import 'package:html2md/html2md.dart' as html2md;
import 'package:html2md/src/rules.dart';
import 'package:test/test.dart';

void main() {
  group('Custom rule tests', () {
    late String oneboxHtml;
    late String lightboxHtml;

    setUp(() {
      oneboxHtml =
          '''<aside class=\"onebox githubfolder\">\n  <header class=\"source\">\n      <img src=\"https://github.githubassets.com/favicons/favicon.svg\" class=\"site-icon\" width=\"32\" height=\"32\">\n      <a href=\"https://github.com/jarontai/dart-souls\" target=\"_blank\" rel=\"noopener\">github.com</a>\n  </header>\n  <article class=\"onebox-body\">\n    <div class=\"aspect-image\" style=\"--aspect-ratio:250/250;\"><img src=\"https://avatars.githubusercontent.com/u/5214514?s=400&amp;amp;v=4\" class=\"thumbnail\" width=\"250\" height=\"250\"></div>\n\n<h3><a href=\"https://github.com/jarontai/dart-souls\" target=\"_blank\" rel=\"noopener\">jarontai/dart-souls</a></h3>\n\n\n  <p><span class=\"label1\">《Dart 之魂》即 Dart 编程要点，尝试使用简单的文字归纳 Dart 语言的主要知识点. Contribute to jarontai/dart-souls development by creating an account on GitHub.</span></p>\n\n  </article>\n  <div class=\"onebox-metadata\">\n    \n    \n  </div>\n  <div style=\"clear: both\"></div>\n</aside>''';

      lightboxHtml =
          '''<div class="lightbox-wrapper"><a class="lightbox" href="https://cdn.dart-china.org/uploads/default/original/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b.jpeg" data-download-href="https://cdn.dart-china.org/uploads/default/0d40835c807a7eca2b07ee0d00feb9134a48262b" title="image"><img src="https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_690x388.jpeg" alt="image" data-base62-sha1="1Teqp0kvptzOoSyW2yIL9H000jN" width="522" height="293" class="d-lazyload" srcset="https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_690x388.jpeg, https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_1035x582.jpeg 1.5x, https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_1380x776.jpeg 2x"><div class="meta">
<svg class="fa d-icon d-icon-far-image svg-icon" aria-hidden="true"><use xlink:href="#far-image"></use></svg><span class="filename">image</span><span class="informations">1600×900 206 KB</span><svg class="fa d-icon d-icon-discourse-expand svg-icon" aria-hidden="true"><use xlink:href="#discourse-expand"></use></svg>
</div></a></div>''';
    });

    test('onebox html from discourse', () {
      expect(
          html2md.convert(oneboxHtml, rules: [
            Rule(
              'discourse-onebox',
              filterFn: (node) {
                if (node.className.contains('onebox') &&
                    node.className.contains('lazyYT')) {
                  return true;
                }
                if (node.nodeName == 'aside' &&
                    node.className.contains('onebox')) {
                  return true;
                }
                return false;
              },
              replacement: (content, node) {
                // Find the html5 video
                var last = node.childNodes().last;
                if (last.className.contains('html5-info-bar')) {
                  var link = last.firstChild?.firstChild?.firstChild;
                  if (link != null) {
                    var href = link.getAttribute('href');
                    if (href != null && href.isNotEmpty) {
                      return '[${link.textContent}]($href)';
                    }
                  }
                }

                // Find the link under header
                var frist = node.firstChild;
                if (frist != null && frist.nodeName == 'header') {
                  var link = frist
                      .childNodes()
                      .firstWhere((element) => element.nodeName == 'a');
                  var href = link.getAttribute('href');
                  if (href != null && href.isNotEmpty) {
                    return '[$href]($href)';
                  }
                }

                return '';
              },
            )
          ]),
          '''[https://github.com/jarontai/dart-souls](https://github.com/jarontai/dart-souls)''');
    });

    test('lightbox html from discourse', () {
      expect(
          html2md.convert(lightboxHtml, rules: [
            Rule(
              'discourse-lightbox',
              filterFn: (node) {
                if (node.className.contains('lightbox') &&
                    node.nodeName == 'a') {
                  return true;
                }
                return false;
              },
              replacement: (content, node) {
                var first = node.firstChild;
                if (first != null && first.nodeName == 'img') {
                  var alt = first.getAttribute('alt') ?? '';
                  var src = first.getAttribute('src') ?? '';
                  var title = first.getAttribute('title') ?? '';
                  var titlePart = title.isNotEmpty ? ' "' + title + '"' : '';

                  var size = '';
                  var width = first.getAttribute('width') ?? '';
                  var height = first.getAttribute('height') ?? '';
                  if (width.isNotEmpty && height.isNotEmpty) {
                    size = '#${width}x$height';
                  }

                  return src.isNotEmpty
                      ? '![' + alt + ']' + '(' + src + titlePart + size + ')'
                      : '';
                }
                return '';
              },
            )
          ]),
          '''![image](https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_690x388.jpeg#522x293)''');
    });
  });
}
