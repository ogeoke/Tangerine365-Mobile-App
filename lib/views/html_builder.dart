import 'package:sevenup_mobile/gen/fonts.gen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:url_launcher/url_launcher.dart';

class HtmlBuilder extends StatelessWidget {
  final String html;
  // final CustomStylesBuilder? customStylesBuilder;
  const HtmlBuilder({
    super.key,
    required this.html,
    // this.customStylesBuilder
  });

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: Theme.of(context).copyWith(
          // primaryColor: context.textColor,
          // context.isDark ? context.primaryColor : const Color(0xff1B9E4B),
          primaryColorLight: const Color(0xff1B9E4B)),
      child: Builder(builder: (context) {
        return Html(
          data: html,
          extensions: [
            TagExtension(
              tagsToExtend: {"img"},
              builder: (p0) => Image.network(p0.attributes['src'] ?? ''),
              // child:   Image.network(),
            ),
          ],
          onLinkTap: (uri, v, a) {
            launchUrl(Uri.parse(uri ?? ''));
          },
          style: {
            'body': Style(padding: HtmlPaddings.zero),
            "u": Style(
                textAlign: TextAlign.start,
                margin: Margins.only(top: 40, bottom: 0),
                padding: HtmlPaddings.only(bottom: 0),
                fontWeight: FontWeight.w500,
                fontSize: FontSize(14, Unit.px),
                // lineHeight: const LineHeight(1.9),
                // height: Height(1.6, Unit.em),
                fontFamily: FontFamily.jost,
                color: const Color(0xff1A212B)),
            "h3": Style(
                textAlign: TextAlign.start,
                margin: Margins.only(top: 40, bottom: 0),
                padding: HtmlPaddings.only(bottom: 0),
                // padding: const EdgeInsets.all(16),
                // backgroundColor: Colors.grey,
                // margin: Margins(left: Margin(0, Unit.px), right: Margin.auto()),
                // width: Width(300, Unit.px),
                fontWeight: FontWeight.w500,
                fontSize: FontSize(14, Unit.px),
                whiteSpace: WhiteSpace.normal,
                lineHeight: const LineHeight(1.0),

                // height: Height(1.6, Unit.em),
                fontFamily: FontFamily.jost,
                color: const Color.fromARGB(255, 14, 18, 23)),
            "p": Style(
                textAlign: TextAlign.start,
                padding: HtmlPaddings.only(top: 0),
                whiteSpace: WhiteSpace.normal,
                fontWeight: FontWeight.w400,
                fontSize: FontSize(14, Unit.px),
                lineHeight: const LineHeight(1.9),
                fontFamily: FontFamily.jost,
                color: const Color(0xff374151)),
          },
        );
        //   return HtmlWidget(
        //     html,

        //     customStylesBuilder: customStylesBuilder ??
        //         (element) {
        //           if ((element.getElementsByTagName('body').isNotEmpty)) {
        //             return {
        //               'margin-left': '20px',
        //               'margin-right': '20px',
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           if ((element.getElementsByTagName('li').isNotEmpty)) {
        //             return {
        //               'list-style-type': 'disc',
        //               'padding': '0',
        //               'margin-left': '0',

        //               // 'text-align': 'start'
        //               // 'line-height': '25px',
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           if (element.getElementsByTagName('strong').isNotEmpty) {
        //             return {
        //               'padding': '0',
        //               'margin-left': '.5',
        //               //   'margin-bottom': '0',
        //               // 'color': context.isDark ? '#86FF68' : '#1B9E4B',
        //               //   // 'line-height': '25px',
        //             };
        //           }
        //           if ((element.getElementsByTagName('a').isNotEmpty)) {
        //             return {
        //               'padding': '0',
        //               'margin-left': '0',
        //               'margin-bottom': '0',
        //               // 'color': context.isDark ? '#86FF68' : '#1B9E4B',
        //               'font-size': '14sp',
        //               'font-weight': '400',
        //               // 'line-height': '25px',
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           if ((element.getElementsByTagName('u').isNotEmpty)) {
        //             return {
        //               'padding': '0',
        //               'margin-left': '0',
        //               'margin-bottom': '0',
        //               // 'color': context.isDark ? '#86FF68' : '#1B9E4B',
        //               'font-size': '14sp',
        //               'font-weight': '400',
        //               // 'line-height': '25px',
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           if ((element.getElementsByTagName('h3').isNotEmpty)) {
        //             return {
        //               // 'padding': '0',
        //               // 'padding-top': '10px',
        //               // 'padding-left': '10px',
        //               // 'padding-right': '10px',
        //               // 'margin-left': '0',
        //               // 'margin-bottom': '0'
        //               // 'line-height': '25px',
        //               'padding-top': '10em',
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           if ((element.getElementsByTagName('p').isNotEmpty)) {
        //             return {
        //               'list-style-type': 'disc',
        //               'padding-top': '10px',
        //               'padding-left': '10px',
        //               'mergin-left': '10px',
        //               'padding-right': '10px',
        //               'line-height': '10sp'
        //             };
        //             // 'color': context.isDark? '#fff': '#000'
        //           }
        //           return {
        //             'padding': '10px',
        //             'line-height': '20px',
        //             'margin': '1px'
        //           };
        //         },

        //     // render a custom widget
        //     customWidgetBuilder: (element) {
        //       if (element.attributes['foo'] == 'bar') {
        //         // return FooBarWidget();
        //       }

        //       return null;
        //     },
        //     onTapUrl: (uri) async {
        //       launchUrl(Uri.parse(uri));
        //       return true;
        //     },

        //     onErrorBuilder: (context, element, error) =>
        //         Text('$element error: $error'),
        //     onLoadingBuilder: (context, element, loadingProgress) => const Center(
        //         child: SizedBox.square(
        //             dimension: 20, child: CircularProgressIndicator())),

        //     renderMode: RenderMode.listView,

        //     textStyle: context.bodySmall?.copyWith(
        //         fontSize: 14.0.sp,
        //         height: 1.6,
        //         fontFamily: FontFamily.axiforma,
        //         color: context.isDark
        //             ? context.textColor.withOpacity(.8)
        //             : const Color(0xff374151)),
        //   );
      }),
    );
  }
}
