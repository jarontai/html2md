# html2md

[![Build status](https://travis-ci.org/jarontai/html2md.svg)](https://travis-ci.org/jarontai/html2md)

Convert html to markdown in Dart. A simplify version of node's [turndown](https://github.com/domchristie/turndown).

## Usage

A simple usage example:

    import 'package:html2md/html2md.dart' as html2md;

    main() {
      var html = '<h1>HTML2MD Demo</h1>';
      print(html2md.convert(html));
    }

## Config

You can config convert style by passing `styleOptions` to `convert`, elements that should be ignored also can be set with `ignore`:

    html2md.convert(html, styleOptions: { 'headingStyle': 'atx' }, ignore: ['script']);


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

## Test

    pub run test

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jarontai/html2md/issues

## License
Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/jarontai/html2md/blob/master/LICENSE).