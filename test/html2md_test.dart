import 'package:html2md/html2md.dart' as hm;
import 'package:test/test.dart';

void main() {
  group('HTML2MD tests', () {
    String rootHtml;
    String imageHtml;
    String html;
    String optionsHtml;

    setUp(() {
      optionsHtml = '<h1>HTML2MD Demo</h1>';
      rootHtml = '<out>out<hello><h1>HTML2MD Demo</h1></hello></out>';
      imageHtml = '<hello><img alt="image" src="folder/image.png" /></hello>';
      html = '''<h1>HTML2MD Demo</h1>

<p>This demonstrates <a href="https://github.com/jarontai/html2md">html2md</a> – an HTML to Markdown converter in Dart.</p>

<h2>Usage</h2>

<pre><code class="language-dart">import 'package:html2md/html2md.dart' as hm;
void main() {
  print(hm.convert('&lt;h1&gt;Hello world&lt;/h1&gt;'));
}</code></pre>

<hr />

<p>It aims to be <a href="http://commonmark.org/">CommonMark</a> compliant, and includes options to style the output. These options include:</p>

<ul>
  <li>headingStyle (setext or atx)</li>
  <li>horizontalRule (*, -, or _)</li>
  <li>bullet (*, -, or +)</li>
  <li>codeBlockStyle (indented or fenced)</li>
  <li>fence (` or ~)</li>
  <li>emDelimiter (_ or *)</li>
  <li>strongDelimiter (** or __)</li>
  <li>linkStyle (inlined or referenced)</li>
  <li>linkReferenceStyle (full, collapsed, or shortcut)</li>
</ul>''';
    });

    test('Html Test', () {
      var out = '''HTML2MD Demo
============

This demonstrates [html2md](https://github.com/jarontai/html2md) – an HTML to Markdown converter in Dart.

Usage
-----

    import 'package:html2md/html2md.dart' as hm;
    void main() {
      print(hm.convert('<h1>Hello world</h1>'));
    }

* * *

It aims to be [CommonMark](http://commonmark.org/) compliant, and includes options to style the output. These options include:

*   headingStyle (setext or atx)
*   horizontalRule (*, -, or _)
*   bullet (*, -, or +)
*   codeBlockStyle (indented or fenced)
*   fence (` or ~)
*   emDelimiter (_ or *)
*   strongDelimiter (** or __)
*   linkStyle (inlined or referenced)
*   linkReferenceStyle (full, collapsed, or shortcut)''';
      expect(hm.convert(html), out) ;
    });

    test('Root Test', () {
      expect(hm.convert(rootHtml, rootTag: 'hello'), '''HTML2MD Demo
============''');
    });

    test('Img Test', () {
      expect(hm.convert(imageHtml, imageBaseUrl: 'http://www.test.com'), '![image](http://www.test.com/folder/image.png)');
    });

    test('Options Test', () {
      expect(hm.convert(optionsHtml, styleOptions: { 'headingStyle': 'atx' }), '''# HTML2MD Demo''');
    });
  });
}
