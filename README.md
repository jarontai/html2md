# html2md

Convert html to markdown in Dart. A simplify version of node's [turndown](https://github.com/domchristie/turndown).

Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/dart-lang/stagehand/blob/master/LICENSE).

## Usage

A simple usage example:

    import 'package:html2md/html2md.dart' as hm;

    main() {
      var html = '<h1>HTML2MD Demo</h1>';
      print(hm.convert(html));
    }

## Features and bugs

Please file feature requests and bugs at the [issue tracker][tracker].

[tracker]: https://github.com/jarontai/html2md/issues
