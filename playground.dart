import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

main() {
  var document = parse(
      '''<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks! <ul> 
        <li>1</li>
        <li class="cl2">2</li>
        </ul>
        <img alt="hh">
        </body>
      ''');
  print(document.getElementsByClassName('cl2')[0].firstChild);
  print(document.getElementsByTagName('img')[0].attributes['alt']);

  String clazz = 'language-javascript';
  RegExp reg = new RegExp(r'language-(\S+)');
  print(reg.firstMatch(clazz).group(1));

  var matches = new RegExp(r'r+')
      .allMatches('r3rr64r')
      .toList()
      .map((match) => match.group(0));
  print(matches);
}
