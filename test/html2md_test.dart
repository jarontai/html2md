import 'package:html2md/html2md.dart' as hd;
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    String html;

    setUp(() {
      html = '<h1>HTML2MD Demo</h1>';
    });

    test('First Test', () {
      var out = '\n\nHTML2MD Demo\n============\n\n';
      expect(hd.convert(html), out) ;
    });
  });
}
