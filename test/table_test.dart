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
| ----- | ----- | ----- |
| Alfreds Futterkiste | Maria Anders | Germany |
| Centro comercial Moctezuma | Francisco Chang | Mexico |
| Ernst Handel | Roland Mendel | Austria |
| Island Trading | Helen Bennett | UK |
| Laughing Bacchus Winecellars | Yoshi Tannamuri | Canada |
| Magazzini Alimentari Riuniti | Giovanni Rovelli | Italy |''') ;
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
| ----- | ----- | ----- |
| [dio\_cookie\_manager](https://github.com/flutterchina/dio/tree/master/plugins/cookie_manager) |  [![Pub](https://img.shields.io/pub/v/dio_http2_adapter.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_http2_adapter) | A cookie manager for Dio |
| [dio\_http2\_adapter](https://github.com/flutterchina/dio/tree/master/plugins/http2_adapter) |  [![Pub](https://img.shields.io/pub/v/dio_cookie_manager.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_cookie_manager) | A Dio HttpClientAdapter which support Http/2.0 |
| [dio\_flutter\_transformer](https://github.com/flutterchina/dio_flutter_transformer) |  [![Pub](https://img.shields.io/pub/v/dio_flutter_transformer.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_flutter_transformer) | A Dio transformer especially for flutter, by which the json decoding will be in background with `compute` function. |
| [dio\_http\_cache](https://github.com/hurshi/dio-http-cache) |  [![Pub](https://img.shields.io/pub/v/dio_http_cache.svg?style=flat-square)](https://pub.dartlang.org/packages/dio_http_cache) | A cache library for Dio, like [Rxcache](https://github.com/VictorAlbertos/RxCache) in Android. dio-http-cache uses [sqflite](https://github.com/tekartik/sqflite) as disk cache, and [LRU](https://github.com/google/quiver-dart) strategy as memory cache. |
| [retrofit](https://github.com/trevorwang/retrofit.dart/) |  [![Pub](https://img.shields.io/pub/v/retrofit.svg?style=flat-square)](https://pub.dartlang.org/packages/retrofit) | retrofit.dart is an dio client generator using source_gen and inspired by Chopper and Retrofit. |''') ;
    });
  });
}
