# html2md

Convert html to markdown in Dart. A simplify version of node's [turndown](https://github.com/domchristie/turndown).

## Usage

A simple usage example:

    import 'package:html2md/html2md.dart' as hm;

    main() {
      var html = '<h1>HTML2MD Demo</h1>';
      print(hm.convert(html));
    }

## Config

You can config convert style by passing `styleOptions` to `convert`:

    hm.convert(html, styleOptions: { 'headingStyle': 'atx' });

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

## Test

    pub run test/html2md_test.dart

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jarontai/html2md/issues

## License
Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/jarontai/html2md/blob/master/LICENSE).