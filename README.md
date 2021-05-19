# html2md

[![Build status](https://travis-ci.org/jarontai/html2md.svg)](https://travis-ci.org/jarontai/html2md)

Convert html to markdown in Dart. A simplify version of node's [turndown](https://github.com/domchristie/turndown).

## Usage

A simple usage example:

~~~dart
import 'package:html2md/html2md.dart' as html2md;

main() {
    var html = '<h1>HTML2MD Demo</h1>';
    print(html2md.convert(html));
}
~~~

Usage caution: html2md is not a flutter widget. You should should convert html to markdown first then send it to the [flutter_markdown](https://pub.dev/packages/flutter_markdown) widget.

## Config

You can config convert style by passing `styleOptions` to `convert`, elements that should be ignored also can be set with `ignore`. If you want to customize element converting, use custom [rules](#custom-rules)!

~~~dart
html2md.convert(html,
    styleOptions: {'headingStyle': 'atx'},
    ignore: ['script'],
    rules: [Rule('custom')]);
~~~

The default and available style options:

| Name        | Default           | Options  |
| ------------- |:-------------:| -----:|
| headingStyle      | "setext" | "setext", "atx" |
| hr      | "* * *" | "* * *", "- - -", "_ _ _" |
| bulletListMarker      | "*" | "*", "-", "_" |
| codeBlockStyle      | "indented" | "indented", "fenced" |
| fence      | "\`\`\`" | "\`\`\`", "~~~" |
| emDelimiter      | "_" | "_", "*" |
| strongDelimiter      | "**" | "**", "__" |
| linkStyle      | "inlined" | "inlined", "referenced" |
| linkReferenceStyle      | "full" | "full", "collapsed", "shortcut" |

## Table support

Basic table converting is supported! 

Html table source:

    <table>
        <tr>
            <th>First Header</th>
            <th>First Header</th> 
        </tr>
        <tr>
            <td>Content Cell</td>
            <td>Content Cell</td>
        </tr>
        <tr>
            <td>Content Cell</td>
            <td>Content Cell</td>
        </tr>
    </table>

The converted markdown source:

    | First Header  | Second Header |
    | ----- | ----- |
    | Content Cell  | Content Cell  |
    | Content Cell  | Content Cell  |

The converted markdown table:

| First Header  | Second Header |
| ----- | ----- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

## Custom Rules

Want to customize element converting? Write your rules!

Rule fields explaination

~~~dart
final String name; // unique rule name
final List<String>? filters; // simple element name filters, e.g. ['aside']
final FilterFn? filterFn; // function for building complex element filter logic
final Replacement? replacement; // function for doing the replacing
final Append? append; // function for appending content
~~~

Rule example - Convert the onebox section of [discourse](https://www.discourse.org/) post to a link

~~~html
<aside class="onebox">
  <header class="source">
      <img src="https://discoursesite/uploads/default/original/1X/test.png" class="site-icon" width="32" height="32">
      <a href="https://events.google.com/io/program/content?4=topic_flutter&amp;lng=zh-CN" target="_blank" rel="noopener">Google I/O 2021</a>
  </header>
</aside>
~~~

~~~dart
Rule(
  'discourse-onebox',
  filterFn: (node) {
    // Find aside with onebox class
    if (node.nodeName == 'aside' &&
        node.className.contains('onebox')) {
        return true;
    }
    return false;
  },
  replacement: (content, node) {
    // find the first a element under header
    var header = node.firstChild;
    var link = header!
        .childNodes()
        .firstWhere((element) => element.nodeName == 'a');
    var href = link.getAttribute('href');
    if (href != null && href.isNotEmpty) {
      return '[$href]($href)'; // build the link
    }
    return '';
  },
)
~~~

## Test

    dart run test

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jarontai/html2md/issues

## License
Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/jarontai/html2md/blob/master/LICENSE).