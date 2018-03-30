import 'package:html/parser.dart' show parse;
import 'package:html/dom.dart';

main() {
      var reg = new RegExp(r'\n$');
      var convertContent = '''
ddddd''';
      print(reg.hasMatch(convertContent));

  var document = parse(
      '''<body>Hello world! <a href="www.html5rocks.com">HTML5 rocks! <ul> 
        <li>1</li>
        <li class="cl2">2</li>
        </ul>
      ''');
  print(document.getElementsByClassName('cl2')[0].firstChild);
}