import 'package:sevenup_mobile/common/app_bottom_nav.dart';
import 'package:sevenup_mobile/common/notification_listener.dart';
import 'package:sevenup_mobile/gen/assets.gen.dart';
import 'package:sevenup_mobile/state/faq_provider.dart';
import 'package:sevenup_mobile/views/faq_details.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class FaqPage extends StatefulWidget {
  static const routeName = '/faq_page';

  const FaqPage({super.key});
  @override
  FaqPageState createState() => FaqPageState();
}

class FaqPageState extends State<FaqPage> {
  late FaqProvider _provider;

  @override
  void initState() {
    _provider = FaqProvider();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        create: (_) => _provider,
        child: Scaffold(
            backgroundColor: const Color(0xffFAFAFA),
            bottomNavigationBar: const AppBottomNav(),
            appBar: AppBar(
                backgroundColor: Theme.of(context).primaryColor,
                primary: true,
                title: Text('Knowledge Repository',
                    style: Theme.of(context)
                        .textTheme
                        .headlineMedium
                        ?.copyWith(fontSize: 16, fontWeight: FontWeight.w500)),
                leading: const BackButton()),
            body: KNotificationListener(
              child: Consumer<FaqProvider>(
                builder: (context, state, _) => SmartRefresher(
                  enablePullDown: true,
                  header: const MaterialClassicHeader(),
                  controller: _provider.refreshController,
                  onRefresh: _provider.onRefresh,
                  child: _provider.faq == null
                      ? const SizedBox.shrink()
                      : _provider.faq?.isNotEmpty == true
                          ? ListView(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 19)
                                      .copyWith(top: 20, bottom: 100),
                              children: <Widget>[
                                for (var i in [...?_provider.faq])
                                  Padding(
                                    padding:
                                        const EdgeInsets.only(bottom: 20.0),
                                    child: Material(
                                      elevation: 2,
                                      color: Colors.white,
                                      child: CupertinoButton(
                                        onPressed: () {
                                          Navigator.push(
                                              context,
                                              CupertinoPageRoute(
                                                  builder: (c) =>
                                                      FaqDetails(faq: i)));
                                        },

                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 20, vertical: 14),
                                        child: Align(
                                          alignment: Alignment.centerLeft,
                                          child: Text(
                                            i.title ?? '',
                                            maxLines: 2,
                                            style: Theme.of(context)
                                                .textTheme
                                                .headlineMedium
                                                ?.copyWith(
                                                  color:
                                                      const Color(0xff757575),
                                                  fontSize: 13,

                                                  fontWeight: FontWeight.w400,
                                                  // fontFamily: AppFont.BAHNSCRIFT,
                                                  letterSpacing: .1,
                                                ),
                                            textAlign: TextAlign.start,
                                          ),
                                        ),

                                        // RichText(
                                        //     text: TextSpan(
                                        //         text: i.answer.trim(),
                                        //         style: Theme.of(context)
                                        //             .textTheme
                                        //             .headlineMedium
                                        //             ?.copyWith(
                                        //               letterSpacing: .1,
                                        //               color: Colors.black,
                                        //               fontSize: 16,
                                        //               fontWeight:
                                        //                   FontWeight.w300,
                                        //             ))),
                                      ),
                                    ),
                                  ),
                              ],
                            )
                          : const Center(
                              child: Text(
                              'Could not load Faqs',
                            )),
                ),
              ),
            )));
  }
}
