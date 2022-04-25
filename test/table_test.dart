import 'package:html2md/html2md.dart' as html2md;
import 'package:test/test.dart';

void main() {
  group('Table tests', () {
    test('Basic Test', () {
      var html = '''<table>
  <tr>
    <th>Company</th>
    <th>Contact</th>
    <th>Country</th>
  </tr>
  <tr>
    <td>Alfreds Futterkiste</td>
    <td>Maria Anders</td>
    <td>Germany</td>
  </tr>
  <tr>
    <td>Centro comercial Moctezuma</td>
    <td>Francisco Chang</td>
    <td>Mexico</td>
  </tr>
  <tr>
    <td>Ernst Handel</td>
    <td>Roland Mendel</td>
    <td>Austria</td>
  </tr>
  <tr>
    <td>Island Trading</td>
    <td>Helen Bennett</td>
    <td>UK</td>
  </tr>
  <tr>
    <td>Laughing Bacchus Winecellars</td>
    <td>Yoshi Tannamuri</td>
    <td>Canada</td>
  </tr>
  <tr>
    <td>Magazzini Alimentari Riuniti</td>
    <td>Giovanni Rovelli</td>
    <td>Italy</td>
  </tr>
</table>''';
      expect(html2md.convert(html), '''| Company | Contact | Country |
| --- | --- | --- |
| Alfreds Futterkiste | Maria Anders | Germany |
| Centro comercial Moctezuma | Francisco Chang | Mexico |
| Ernst Handel | Roland Mendel | Austria |
| Island Trading | Helen Bennett | UK |
| Laughing Bacchus Winecellars | Yoshi Tannamuri | Canada |
| Magazzini Alimentari Riuniti | Giovanni Rovelli | Italy |''');
    });

    test('Complex Test', () {
      var html = '''<table>
    <thead>
        <tr>
            <th>Plugins</th>
            <th>Status</th>
            <th>Description</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td><a href="https://github.com/flutterchina/dio/tree/master/plugins/cookie_manager">dio_cookie_manager</a></td>
            <td>
                <a href="https://pub.dartlang.org/packages/dio_http2_adapter"><img src="https://img.shields.io/pub/v/dio_http2_adapter.svg?style=flat-square" alt="Pub"></a>
            </td>
            <td>A cookie manager for Dio</td>
        </tr>
        <tr>
            <td><a href="https://github.com/flutterchina/dio/tree/master/plugins/http2_adapter">dio_http2_adapter</a></td>
            <td>
                <a href="https://pub.dartlang.org/packages/dio_cookie_manager"><img src="https://img.shields.io/pub/v/dio_cookie_manager.svg?style=flat-square" alt="Pub"></a>
            </td>
            <td>A Dio HttpClientAdapter which support Http/2.0</td>
        </tr>
        <tr>
            <td><a href="https://github.com/flutterchina/dio_flutter_transformer">dio_flutter_transformer</a></td>
            <td>
                <a href="https://pub.dartlang.org/packages/dio_flutter_transformer"><img src="https://img.shields.io/pub/v/dio_flutter_transformer.svg?style=flat-square" alt="Pub"></a>
            </td>
            <td>A Dio transformer especially for flutter, by which the json decoding will be in background with <code>compute</code> function.</td>
        </tr>
        <tr>
            <td><a href="https://github.com/hurshi/dio-http-cache">dio_http_cache</a></td>
            <td>
                <a href="https://pub.dartlang.org/packages/dio_http_cache"><img src="https://img.shields.io/pub/v/dio_http_cache.svg?style=flat-square" alt="Pub"></a>
            </td>
            <td>A cache library for Dio, like <a href="https://github.com/VictorAlbertos/RxCache">Rxcache</a> in Android. dio-http-cache uses <a href="https://github.com/tekartik/sqflite">sqflite</a> as disk cache, and <a href="https://github.com/google/quiver-dart">LRU</a> strategy as memory cache.</td>
        </tr>
        <tr>
            <td><a href="https://github.com/trevorwang/retrofit.dart/">retrofit</a></td>
            <td>
                <a href="https://pub.dartlang.org/packages/retrofit"><img src="https://img.shields.io/pub/v/retrofit.svg?style=flat-square" alt="Pub"></a>
            </td>
            <td>retrofit.dart is an dio client generator using source_gen and inspired by Chopper and Retrofit.</td>
        </tr>
    </tbody>
</table>''';
      expect(html2md.convert(html), r'''| Plugins | Status | Description |
| --- | --- | --- |
| [dio\_cookie\_manager](https://github.com/flutterchina/dio/tree/master/plugins/cookie_manager) | [![Pub](https://img.shields.io/pub/v/dio_http2_adapter.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_http2_adapter) | A cookie manager for Dio |
| [dio\_http2\_adapter](https://github.com/flutterchina/dio/tree/master/plugins/http2_adapter) | [![Pub](https://img.shields.io/pub/v/dio_cookie_manager.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_cookie_manager) | A Dio HttpClientAdapter which support Http/2.0 |
| [dio\_flutter\_transformer](https://github.com/flutterchina/dio_flutter_transformer) | [![Pub](https://img.shields.io/pub/v/dio_flutter_transformer.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_flutter_transformer) | A Dio transformer especially for flutter, by which the json decoding will be in background with `compute` function. |
| [dio\_http\_cache](https://github.com/hurshi/dio-http-cache) | [![Pub](https://img.shields.io/pub/v/dio_http_cache.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_http_cache) | A cache library for Dio, like [Rxcache](https://github.com/VictorAlbertos/RxCache) in Android. dio-http-cache uses [sqflite](https://github.com/tekartik/sqflite) as disk cache, and [LRU](https://github.com/google/quiver-dart) strategy as memory cache. |
| [retrofit](https://github.com/trevorwang/retrofit.dart/) | [![Pub](https://img.shields.io/pub/v/retrofit.svg?style=flat-square)](https://pub.dartlang.org/packages/retrofit) | retrofit.dart is an dio client generator using source_gen and inspired by Chopper and Retrofit. |''');
    });

    test('basic table', () {
      final input = '''<table>
  <thead>
    <tr>
      <th>Column 1</th>
      <th>Column 2</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Row 1, Column 1</td>
      <td>Row 1, Column 2</td>
    </tr>
    <tr>
      <td>Row 2, Column 1</td>
      <td>Row 2, Column 2</td>
    </tr>
  </tbody>
  <tfoot>
    <tr>
      <td>Row 3, Column 1</td>
      <td>Row 3, Column 2</td>
    </tr>
  </tfoot>
</table>''';
      final expected = '''| Column 1 | Column 2 |
| --- | --- |
| Row 1, Column 1 | Row 1, Column 2 |
| Row 2, Column 1 | Row 2, Column 2 |
| Row 3, Column 1 | Row 3, Column 2 |''';
      expect(html2md.convert(input), expected);
    });

    test('cell alignment', () {
      final input = '''<table>
  <thead>
    <tr>
      <th align="left">Column 1</th>
      <th align="center">Column 2</th>
      <th align="right">Column 3</th>
      <th align="foo">Column 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>Row 1, Column 1</td>
      <td>Row 1, Column 2</td>
      <td>Row 1, Column 3</td>
      <td>Row 1, Column 4</td>
    </tr>
    <tr>
      <td>Row 2, Column 1</td>
      <td>Row 2, Column 2</td>
      <td>Row 2, Column 3</td>
      <td>Row 2, Column 4</td>
    </tr>
  </tbody>
</table>''';
      final expected = '''| Column 1 | Column 2 | Column 3 | Column 4 |
| :-- | :-: | --: | --- |
| Row 1, Column 1 | Row 1, Column 2 | Row 1, Column 3 | Row 1, Column 4 |
| Row 2, Column 1 | Row 2, Column 2 | Row 2, Column 3 | Row 2, Column 4 |''';
      expect(html2md.convert(input), expected);
    });

    test('empty cells', () {
      final input = '''<table>
  <thead>
    <tr>
      <th align="left">Column 1</th>
      <th align="center">Column 2</th>
      <th align="right">Column 3</th>
      <th align="foo">Column 4</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td></td>
      <td>Row 1, Column 2</td>
      <td>Row 1, Column 3</td>
      <td>Row 1, Column 4</td>
    </tr>
    <tr>
      <td>Row 2, Column 1</td>
      <td></td>
      <td>Row 2, Column 3</td>
      <td>Row 2, Column 4</td>
    </tr>
    <tr>
      <td>Row 3, Column 1</td>
      <td>Row 3, Column 2</td>
      <td></td>
      <td>Row 3, Column 4</td>
    </tr>
    <tr>
      <td>Row 4, Column 1</td>
      <td>Row 4, Column 2</td>
      <td>Row 4, Column 3</td>
      <td></td>
    </tr>
    <tr>
      <td></td>
      <td></td>
      <td></td>
      <td>Row 5, Column 4</td>
    </tr>
  </tbody>
</table>''';
      final expected = '''| Column 1 | Column 2 | Column 3 | Column 4 |
| :-- | :-: | --: | --- |
|  | Row 1, Column 2 | Row 1, Column 3 | Row 1, Column 4 |
| Row 2, Column 1 |  | Row 2, Column 3 | Row 2, Column 4 |
| Row 3, Column 1 | Row 3, Column 2 |  | Row 3, Column 4 |
| Row 4, Column 1 | Row 4, Column 2 | Row 4, Column 3 |  |
|  |  |  | Row 5, Column 4 |''';
      expect(html2md.convert(input), expected);
    });

    test('empty rows', () {
      final input = '''<table>
  <thead>
    <td>Heading 1</td>
    <td>Heading 2</td>
  </thead>
  <tbody>
    <tr>
      <td>Row 1</td>
      <td>Row 1</td>
    </tr>
    <tr>
      <td></td>
      <td></td>
    </tr>
    <tr>
      <td>Row 3</td>
      <td>Row 3</td>
    </tr>
  </tbody>
</table>''';
      final expected = '''| Heading 1 | Heading 2 |
| --- | --- |
| Row 1 | Row 1 |
|  |  |
| Row 3 | Row 3 |''';
      expect(html2md.convert(input), expected);
    });

    test('th in first row', () {
      final input = '''<table>
  <tr>
    <th>Heading</th>
  </tr>
  <tr>
    <td>Content</td>
  </tr>
</table>''';
      final expected = '''| Heading |
| --- |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('th first row in tbody', () {
      final input = '''<table>
  <tbody>
    <tr>
      <th>Heading</th>
    </tr>
    <tr>
      <td>Content</td>
    </tr>
  </tbody>
</table>''';
      final expected = '''| Heading |
| --- |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('table with two tbodies', () {
      final input = '''<table>
  <tbody>
    <tr>
      <th>Heading</th>
    </tr>
    <tr>
      <td>Content</td>
    </tr>
  </tbody>
  <tbody>
    <tr>
      <th>Heading</th>
    </tr>
    <tr>
      <td>Content</td>
    </tr>
  </tbody>
</table>''';
      final expected = '''| Heading |
| --- |
| Content |
| Heading |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('heading cells in both thead and tbody', () {
      final input = '''<table>
  <thead><tr><th>Heading</th></tr></thead>
  <tbody><tr><th>Cell</th></tr></tbody>
</table>''';
      final expected = '''| Heading |
| --- |
| Cell |''';
      expect(html2md.convert(input), expected);
    });

    test('empty head content (minimum table)', () {
      final input = '''<table>
  <thead><tr><th></th></tr></thead>
</table>''';
      final expected = '''|  |
| --- |''';
      expect(html2md.convert(input), expected);
    });

    test('no cell in first row', () {
      final input = '''<table>
  <thead><tr></tr></thead>
</table>''';
      final expected = '''''';
      expect(html2md.convert(input), expected);
    });

    test('non-definitive heading row', () {
      final input = '''<table>
  <tr><td>Row 1 Cell 1</td><td>Row 1 Cell 2</td></tr>
  <tr><td>Row 2 Cell 1</td><td>Row 2 Cell 2</td></tr>
</table>''';
      final expected = '''| Row 1 Cell 1 | Row 1 Cell 2 |
| --- | --- |
| Row 2 Cell 1 | Row 2 Cell 2 |''';
      expect(html2md.convert(input), expected);
    });

    test('non-definitive heading row with th', () {
      final input = '''<table>
  <tr>
    <th>Heading</th>
    <td>Not a heading</td>
  </tr>
  <tr>
    <td>Heading</td>
    <td>Not a heading</td>
  </tr>
</table>''';
      final expected = '''| Heading | Not a heading |
| --- | --- |
| Heading | Not a heading |''';
      expect(html2md.convert(input), expected);
    });

    test('Pipe to be escaped', () {
      final input = '''<table>
  <tr>
    <th>Heading 1 | Heading 2</th>
  </tr>
  <tr>
    <td>Content 1 | Content 2</td>
  </tr>
</table>''';
      final expected = '''| Heading 1 \\| Heading 2 |
| --- |
| Content 1 \\| Content 2 |''';
      expect(html2md.convert(input), expected);
    });

    test('Multi lines header and body', () {
      final input = '''<table>
  <tr>
    <th>
      Heading 1
      Heading 2
    </th>
  </tr>
  <tr>
    <td>
      <p>Paragraph 1</p>
      <p>Paragraph 2</p>
    </td>
  </tr>
</table>''';
      final expected = '''| Heading 1 Heading 2 |
| --- |
|   Paragraph 1  Paragraph 2   |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with caption (at start) and colgroup', () {
      final input = '''<table>
  <caption>Caption</caption>
  <colgroup>
    <col style="background-color:yellow">
  </colgroup>
  <tr>
    <th>Heading</th>
  </tr>
  <tr>
    <td>Content</td>
  </tr>
</table>''';
      final expected = '''Caption 
| Heading |
| --- |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with caption (at end)', () {
      final input = '''<table>
  <tr>
    <th>Heading</th>
  </tr>
  <tr>
    <td>Content</td>
  </tr>
  <caption>Caption</caption>
</table>''';
      final expected = '''| Heading |
| --- |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with caption (at start) in 1 line', () {
      final input = '''<table>
  <caption>Caption</caption><tr><th>Heading</th></tr><tr>
    <td>Content</td>
  </tr>
</table>''';
      final expected = '''Caption
| Heading |
| --- |
| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with caption and no row', () {
      final input = '''<table>
  <caption>Caption</caption>
</table>''';
      final expected = '''Caption''';
      expect(html2md.convert(input), expected);
    });

    test('Table with no row', () {
      final input = '''<table>
</table>''';
      final expected = '''''';
      expect(html2md.convert(input), expected);
    });

    test('Table with no td on first line', () {
      final input = '''<table>
  <tr></tr>
  <tr><td>Content</td></tr>
</table>''';
      final expected = '''| Content |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with no td on second line', () {
      final input = '''<table>
  <tr><th>Heading</th></tr>
  <tr></tr>
</table>''';
      final expected = '''| Heading |
| --- |''';
      expect(html2md.convert(input), expected);
    });

    test('Table with rows using colspan', () {
      final input = '''<table>
  <tr>
    <th>Heading 1</th>
    <th colspan="1">Heading 2</th>
    <th colspan="0">Heading 3</th>
    <th colspan="-1">Heading 4</th>
    <th colspan="a">Heading 5</th>
    <th colspan="2">Heading 6-7</th>
    <th colspan="">Heading 8</th>
    <th colspan="1.7">Heading 9</th>
    <th colspan="1.2">Heading 10</th>
    <th>Last Heading</th>
  </tr>
  <tr>
    <td>Content 1</td>
    <td colspan="1">Content 2</td>
    <td colspan="0">Content 3</td>
    <td colspan="-1">Content 4</td>
    <td colspan="a">Content 5</td>
    <td colspan="2">Content 6-7</td>
    <td colspan="">Content 8</td>
    <td colspan="1.7">Content 9</td>
    <td colspan="1.2">Content 10</td>
    <td>Last Content</td>
  </tr>
  <tr>
    <td>Content 1</td>
    <td>Content 2</td>
    <td>Content 3</td>
    <td>Content 4</td>
    <td>Content 5</td>
    <td>Content 6</td>
    <td>Content 7</td>
    <td>Content 8</td>
    <td>Content 9</td>
    <td>Content 10</td>
    <td>Last Content</td>
  </tr>
</table>''';
      final expected = '''| Heading 1 | Heading 2 | Heading 3 | Heading 4 | Heading 5 | Heading 6-7 |  | Heading 8 | Heading 9 | Heading 10 | Last Heading |
| --- | --- | --- | --- | --- | --- | --- | --- | --- | --- | --- |
| Content 1 | Content 2 | Content 3 | Content 4 | Content 5 | Content 6-7 |  | Content 8 | Content 9 | Content 10 | Last Content |
| Content 1 | Content 2 | Content 3 | Content 4 | Content 5 | Content 6 | Content 7 | Content 8 | Content 9 | Content 10 | Last Content |''';
      expect(html2md.convert(input), expected);
    });

    test('Nested table', () {
      final input = '''<table>
  <tr>
    <th>Heading</th>
  </tr>
  <tr>
    <td>Content</td>
  </tr>
  <tr>
    <td>
      <table>
        <tr>
          <th>Nested Heading</th>
        </tr>
        <tr>
          <td>Nested Content</td>
        </tr>
      </table>
    </td>
  </tr>
</table>''';
      final expected = '''| Heading |
| --- |
| Content |
|   <table><tbody><tr><th>Nested Heading</th></tr><tr><td>Nested Content</td></tr></tbody></table>   |''';
      expect(html2md.convert(input), expected);
    });
  });
}
