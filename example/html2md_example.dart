import 'package:html2md/html2md.dart' as hm;

main() {
  String html = '''<h1>Turndown Demo</h1>

<p>This demonstrates <a href="https://github.com/domchristie/turndown">turndown</a> – an HTML to Markdown converter in JavaScript.</p>

<h2>Usage</h2>

<pre><code class="language-js">var turndownService = new TurndownService()
console.log(
  turndownService.turndown('&lt;h1&gt;Hello world&lt;/h1&gt;')
)</code></pre>

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
  print(hm.convert(html));
}
