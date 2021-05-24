简体中文 | [English](./README.md)

# html2md

[![Build status](https://travis-ci.org/jarontai/html2md.svg)](https://travis-ci.org/jarontai/html2md)

将html转换为markdown的Dart库，支持CommonMark、简单表格以及自定义转换规则。

## 使用

简单示例:

~~~dart
import 'package:html2md/html2md.dart' as html2md;

main() {
    var html = '<h1>HTML2MD Demo</h1>';
    print(html2md.convert(html));
}
~~~

在flutter中, 可以使用[flutter_markdown](https://pub.dev/packages/flutter_markdown)来渲染:

~~~dart
import 'package:html2md/html2md.dart' as html2md;
import 'package:flutter_markdown/flutter_markdown.dart';

build(BuildContext context) {
    // 注意: 以下并非最佳实践，convert不应该在build中调用，转换后的markdown也应该放到state中
    var html = '<h1>HTML2MD Demo</h1>';
    var markdown = html2md.convert(html);
    return Markdown(data: markdown);
}
~~~

## 配置

通过`styleOptions`定义转换格式, 通过`ignore`忽略不需要转换的元素. 如果需要自定义转换规则，请编写[rules](#custom-rules)!

~~~dart
html2md.convert(html,
    styleOptions: {'headingStyle': 'atx'},
    ignore: ['script'],
    rules: [Rule('custom')]);
~~~

默认的转换格式:

| 名称        | 默认值           | 选项  |
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

## Table 支持

简单的Table（表格）是支持的! 

Table的html代码:

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

转换后的markdown:

    | First Header  | Second Header |
    | ----- | ----- |
    | Content Cell  | Content Cell  |
    | Content Cell  | Content Cell  |

转换后的markdown渲染效果:

| First Header  | Second Header |
| ----- | ----- |
| Content Cell  | Content Cell  |
| Content Cell  | Content Cell  |

## 自定义 Rules

需要自定义转换规则? 编写你自己的Rule!

Rule字段解释：

~~~dart
final String name; // 唯一名称
final List<String>? filters; // 简单的元素名称过滤，比如：['aside']
final FilterFn? filterFn; // 也可以编写函数来实现复杂的过滤规则
final Replacement? replacement; // 执行内容替换的函数
final Append? append; // 执行追加内容的函数
~~~

Rule示例 - 转换 [discourse](https://www.discourse.org/) 帖子中的onebox块

~~~html
<aside class="onebox">
  <header class="source">
      <img src="https://discoursesite/uploads/default/original/1X/test.png" class="site-icon" width="32" height="32">
      <a href="https://events.google.com/io/program/content?4=topic_flutter&amp;lng=zh-CN" target="_blank" rel="noopener">Google I/O 2021</a>
  </header>
</aside>
~~~

~~~dart
Rule(
  'discourse-onebox',
  filterFn: (node) {
    // Find aside with onebox class
    if (node.nodeName == 'aside' &&
        node.className.contains('onebox')) {
        return true;
    }
    return false;
  },
  replacement: (content, node) {
    // find the first a element under header
    var header = node.firstChild;
    var link = header!
        .childNodes()
        .firstWhere((element) => element.nodeName == 'a');
    var href = link.getAttribute('href');
    if (href != null && href.isNotEmpty) {
      return '[$href]($href)'; // build the link
    }
    return '';
  },
)
~~~

## 测试

    dart run test

## Bug

请将bug发送到 [issue tracker][tracker].

[tracker]: https://github.com/jarontai/html2md/issues

## 感谢

html2md的基础实现参考了Nodejs库 [turndown](https://github.com/domchristie/turndown)

## License
Created from templates made available by Stagehand under a BSD-style
[license](https://github.com/jarontai/html2md/blob/master/LICENSE).