import 'package:html2md/html2md.dart' as html2md;
import 'package:html2md/src/rules.dart';
import 'package:test/test.dart';

void main() {
  group('Custom rule tests', () {
    late String oneboxHtml;
    late String lightboxHtml;
    late String mdTableHtml;

    setUp(() {
      oneboxHtml =
          '''<aside class=\"onebox githubfolder\">\n  <header class=\"source\">\n      <img src=\"https://github.githubassets.com/favicons/favicon.svg\" class=\"site-icon\" width=\"32\" height=\"32\">\n      <a href=\"https://github.com/jarontai/dart-souls\" target=\"_blank\" rel=\"noopener\">github.com</a>\n  </header>\n  <article class=\"onebox-body\">\n    <div class=\"aspect-image\" style=\"--aspect-ratio:250/250;\"><img src=\"https://avatars.githubusercontent.com/u/5214514?s=400&amp;amp;v=4\" class=\"thumbnail\" width=\"250\" height=\"250\"></div>\n\n<h3><a href=\"https://github.com/jarontai/dart-souls\" target=\"_blank\" rel=\"noopener\">jarontai/dart-souls</a></h3>\n\n\n  <p><span class=\"label1\">《Dart 之魂》即 Dart 编程要点，尝试使用简单的文字归纳 Dart 语言的主要知识点. Contribute to jarontai/dart-souls development by creating an account on GitHub.</span></p>\n\n  </article>\n  <div class=\"onebox-metadata\">\n    \n    \n  </div>\n  <div style=\"clear: both\"></div>\n</aside>''';

      lightboxHtml =
          '''<div class="lightbox-wrapper"><a class="lightbox" href="https://cdn.dart-china.org/uploads/default/original/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b.jpeg" data-download-href="https://cdn.dart-china.org/uploads/default/0d40835c807a7eca2b07ee0d00feb9134a48262b" title="image"><img src="https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_690x388.jpeg" alt="image" data-base62-sha1="1Teqp0kvptzOoSyW2yIL9H000jN" width="522" height="293" class="d-lazyload" srcset="https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_690x388.jpeg, https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_1035x582.jpeg 1.5x, https://cdn.dart-china.org/uploads/default/optimized/1X/0d40835c807a7eca2b07ee0d00feb9134a48262b_2_1380x776.jpeg 2x"><div class="meta">
<svg class="fa d-icon d-icon-far-image svg-icon" aria-hidden="true"><use xlink:href="#far-image"></use></svg><span class="filename">image</span><span class="informations">1600×900 206 KB</span><svg class="fa d-icon d-icon-discourse-expand svg-icon" aria-hidden="true"><use xlink:href="#discourse-expand"></use></svg>
</div></a></div>''';

      mdTableHtml = '''
<div class="md-table">
<table>
<thead>
<tr>
<th>home</th>
<th>topic</th>
<th>menu</th>
</tr>
</thead>
<tbody>
<tr>
<td><div class="lightbox-wrapper"><a class="lightbox" href="https://cdn.dart-china.org/uploads/default/original/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e.png" data-download-href="https://cdn.dart-china.org/uploads/default/8d434671a2dfca0d182e0953a47449a0098d4a9e" title="home"><img src="https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_231x500.png" alt="home" data-base62-sha1="k9FsvaXr6OHrkUKIEBN5gFRWn9Q" width="231" height="500" srcset="https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_231x500.png, https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_346x750.png 1.5x, https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_462x1000.png 2x" data-small-upload="https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_10x10.png"><div class="meta">
<svg class="fa d-icon d-icon-far-image svg-icon" aria-hidden="true"><use xlink:href="#far-image"></use></svg><span class="filename">home</span><span class="informations">1284×2778 476 KB</span><svg class="fa d-icon d-icon-discourse-expand svg-icon" aria-hidden="true"><use xlink:href="#discourse-expand"></use></svg>
</div></a></div></td>
<td><div class="lightbox-wrapper"><a class="lightbox" href="https://cdn.dart-china.org/uploads/default/original/1X/6a3defd01a5312c602069c235abf324b7d26f256.jpeg" data-download-href="https://cdn.dart-china.org/uploads/default/6a3defd01a5312c602069c235abf324b7d26f256" title="topic"><img src="https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_231x500.jpeg" alt="topic" data-base62-sha1="f9RjgEpmTFX107mWlAysUGsOroG" width="231" height="500" srcset="https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_231x500.jpeg, https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_346x750.jpeg 1.5x, https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_462x1000.jpeg 2x" data-small-upload="https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_10x10.png"><div class="meta">
<svg class="fa d-icon d-icon-far-image svg-icon" aria-hidden="true"><use xlink:href="#far-image"></use></svg><span class="filename">topic</span><span class="informations">1284×2778 437 KB</span><svg class="fa d-icon d-icon-discourse-expand svg-icon" aria-hidden="true"><use xlink:href="#discourse-expand"></use></svg>
</div></a></div></td>
<td><div class="lightbox-wrapper"><a class="lightbox" href="https://cdn.dart-china.org/uploads/default/original/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b.png" data-download-href="https://cdn.dart-china.org/uploads/default/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b" title="menu"><img src="https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_231x500.png" alt="menu" data-base62-sha1="2yAa3hsWLVPTFeGYDcGeK1I2Pqz" width="231" height="500" srcset="https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_231x500.png, https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_346x750.png 1.5x, https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_462x1000.png 2x" data-small-upload="https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_10x10.png"><div class="meta">
<svg class="fa d-icon d-icon-far-image svg-icon" aria-hidden="true"><use xlink:href="#far-image"></use></svg><span class="filename">menu</span><span class="informations">1284×2778 294 KB</span><svg class="fa d-icon d-icon-discourse-expand svg-icon" aria-hidden="true"><use xlink:href="#discourse-expand"></use></svg>
</div></a></div></td>
</tr>
</tbody>
</table>
</div>''';
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

    test('discourse markdown image table', () {
      expect(
          html2md.convert(mdTableHtml, rules: [
            Rule(
              'discourse-markdown-image-table',
              filterFn: (node) {
                if (node.className.contains('md-table')) {
                  if (node.outerHTML.contains('data-base62')) {
                    return true;
                  }
                }
                return false;
              },
              replacement: (content, node) {
                final first = node.childNodes().first;
                var tbody = first
                    .childNodes()
                    .firstWhere((element) => element.nodeName == 'tbody');
                final trs = tbody
                    .childNodes()
                    .where((element) => element.nodeName == 'tr');

                final images = [];
                for (var tr in trs) {
                  final tds = tr
                      .childNodes()
                      .where((element) => element.nodeName == 'td');
                  for (var td in tds) {
                    var el = td.asElement();
                    if (el != null) {
                      var img =
                          html2md.Node(el.getElementsByTagName('img').first);
                      var src = img.getAttribute('src');
                      var alt = img.getAttribute('alt');
                      images.add('![$alt]($src)');
                    }
                  }
                }

                var result = images.join('\n');
                return result;
              },
            )
          ]),
          '''![home](https://cdn.dart-china.org/uploads/default/optimized/1X/8d434671a2dfca0d182e0953a47449a0098d4a9e_2_231x500.png)
![topic](https://cdn.dart-china.org/uploads/default/optimized/1X/6a3defd01a5312c602069c235abf324b7d26f256_2_231x500.jpeg)
![menu](https://cdn.dart-china.org/uploads/default/optimized/1X/11ed20db88b0f2d12e82da8a4d13f0b2fedef34b_2_231x500.png)''');
    });
  });
}
