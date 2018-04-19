import 'package:html2md/html2md.dart' as html2md;

main() {
  String html = '''<h1>HTML2MD Demo</h1>

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
</ul>''';
  print(html2md.convert(html));
}
