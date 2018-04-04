import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

import 'package:html2md/html2md.dart' as hd;

main() {
  // var document = parse(
  //     '''<text>Hello world! <a href="www.html5rocks.com">HTML5 rocks! <ul>
  //       <li>1</li>
  //       <li class="cl2">2</li>
  //       </ul>
  //       <img alt="hh">
  //       </text>
  //     ''');
  // print(document.getElementsByTagName('text')[0].innerHtml);
  // print(document.getElementsByTagName('img')[0].attributes['alt']);

  // String clazz = 'language-javascript';
  // RegExp reg = new RegExp(r'language-(\S+)');
  // print(reg.firstMatch(clazz).group(1));

  // var matches = new RegExp(r'r+')
  //     .allMatches('r3rr64r')
  //     .toList()
  //     .map((match) => match.group(0));
  // print(matches);

  String html = '<h1>Turndown Demo</h1>';
  print('--------------');
  print(hd.convert(html));
}
