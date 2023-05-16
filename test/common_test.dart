import 'package:html2md/html2md.dart' as html2md;
import 'package:test/test.dart';
import 'package:html/parser.dart' as parser;

void main() {
  group('Common tests', () {
    late String rootHtml;
    late String imageHtml;
    late String html;
    late String optionsHtml;
    late String removeHtml;
    late String ignoreHtml;
    late String codeblockHtml;
    late String linkWithTitleHtml;
    late String strikeHtml;

    setUp(() {
      ignoreHtml =
          '''<!DOCTYPE html><head><script>console.log("test");</script></head><body>Hello</body>''';
      removeHtml =
          '<out>out<hello><h1>HTML2MD Demo</h1></hello><noscript>Hello in noscript</noscript></out>';
      optionsHtml = '<h1>HTML2MD Demo</h1>';
      rootHtml = '<out>out<hello><h1>HTML2MD Demo</h1></hello></out>';
      imageHtml = '<hello><img alt="image" src="folder/image.png" /></hello>';
      html = '''<h1>HTML2MD Demo</h1>

<p>This demonstrates <a href="https://github.com/jarontai/html2md">html2md</a> – an HTML to Markdown converter in Dart.</p>

<h2>Usage</h2>

<pre><code class="language-dart">import 'package:html2md/html2md.dart' as html2md;
void main() {
  print(html2md.convert('&lt;h1&gt;Hello world&lt;/h1&gt;'));
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
</ul>
<pre>defaultConfig{<br>...<br>minSdkVersion 15<br>...<br>}</pre>
''';
      codeblockHtml = '''<pre><code>print('Hello, world');</code></pre>''';
      linkWithTitleHtml =
          '<a href="https://example.com" title="Example title">Example content</a>';
      strikeHtml =
          '<strike>This is strike.</strike><s>This is s.</s><del>This is del.</del> Normal Text.';
    });

    test('Basic Test', () {
      var out = '''HTML2MD Demo
============

This demonstrates [html2md](https://github.com/jarontai/html2md) – an HTML to Markdown converter in Dart.

Usage
-----

    import 'package:html2md/html2md.dart' as html2md;
    void main() {
      print(html2md.convert('<h1>Hello world</h1>'));
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
*   linkReferenceStyle (full, collapsed, or shortcut)

defaultConfig{  
...  
minSdkVersion 15  
...  
}''';
      expect(html2md.convert(html), out);
    });

    test('Root Test', () {
      expect(html2md.convert(rootHtml, rootTag: 'hello'), '''HTML2MD Demo
============''');
    });

    test('Img Test', () {
      expect(html2md.convert(imageHtml, imageBaseUrl: 'http://www.test.com'),
          '![image](http://www.test.com/folder/image.png)');
    });

    test('Options Test', () {
      expect(
          html2md.convert(optionsHtml, styleOptions: {'headingStyle': 'atx'}),
          '''# HTML2MD Demo''');
    });

    test('Remove Test', () {
      expect(
          html2md.convert(removeHtml,
              rootTag: 'hello', styleOptions: {'headingStyle': 'setext'}),
          '''HTML2MD Demo
============''');
    });

    test('Ignore Test', () {
      expect(html2md.convert(ignoreHtml, ignore: ['script']), '''Hello''');
    });

    test('CodeBlock fenced Test', () {
      expect(
          html2md.convert(codeblockHtml,
              styleOptions: {'codeBlockStyle': 'fenced'}),
          '''```
print('Hello, world');
```''');
    });

    test('Link with title Test', () {
      expect(
        html2md.convert(linkWithTitleHtml),
        '[Example content](https://example.com "Example title")',
      );
    });

    test('Referenced Link with title Test', () {
      expect(
        html2md.convert(
          linkWithTitleHtml,
          styleOptions: {
            'linkStyle': 'referenced',
          },
        ),
        '''[Example content][1]

[1]: https://example.com "Example title"''',
      );
    });

    test('Strike Test', () {
      expect(
        html2md.convert(strikeHtml),
        '~~This is strike.~~~~This is s.~~~~This is del.~~ Normal Text.',
      );
    });

    test('Html Node Test', () {
      final doc = parser.parse(ignoreHtml);
      final body = doc.body;
      body?.innerHtml = 'Hello World';
      expect(html2md.convert(body!), '''Hello World''');
    });
  });
}
