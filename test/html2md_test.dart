import 'package:html2md/html2md.dart' as hd;
import 'package:test/test.dart';

void main() {
  group('A group of tests', () {
    String html;

    setUp(() {
      html = '<h1>Turndown Demo</h1>';
    });

    test('First Test', () {
      hd.convert(html);
    });
  });
}
