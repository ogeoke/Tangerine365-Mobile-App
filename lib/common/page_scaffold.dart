// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart'
//     as extended;
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:sevenup_mobile/common/app_bottom_nav.dart';

import 'notification_listener.dart';

class PageScaffold extends StatelessWidget {
  final String? title;
  final Widget content;
  final Widget? backButton;
  final PreferredSizeWidget? bottom;
  final SmartRefresher? parent;

  const PageScaffold({
    super.key,
    // required this.item,
    required this.content,
    this.backButton,
    this.bottom,
    this.parent,
    this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      bottomNavigationBar: const AppBottomNav(),
      appBar: AppBar(
        backgroundColor: Theme.of(context).primaryColor,
        primary: true,
        title: Text(
          title ?? '',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w500,
              ),
        ),
        leading: const BackButton(),
      ),
      body: KNotificationListener(
        // child: S(
        // headerSliverBuilder: (c, b) => [
        //       SliverAppBar(
        //         backgroundColor: Theme.of(context).primaryColor,
        //         primary: true,
        //         leading: backButton ??
        //             IconButton(
        //                 icon: const Icon(Icons.close),
        //                 onPressed: () =>
        //                     Navigator.of(context).maybePop()),
        //         expandedHeight: 200,
        //         pinned: true,
        //         stretch: true,
        //         flexibleSpace: FlexibleSpaceBar(
        //           title: Padding(
        //             padding:
        //                 EdgeInsets.only(bottom: bottom != null ? 20 : 0),
        //             child: Text(item.title,
        //                 style: Theme.of(context)
        //                     .textTheme
        //                     .bodyLarge
        //                     ?.copyWith(fontSize: 20, color: Colors.white)),
        //           ),
        //           background: ItemTile(
        //             item,
        //             showTitle: false,
        //             key: Key(item.title),
        //           ),
        //           collapseMode: CollapseMode.parallax,
        //         ),
        //         bottom: bottom,
        //         systemOverlayStyle: SystemUiOverlayStyle.light,
        //       ),
        //     ],
        child: SmartRefresher(
          controller: parent?.controller ?? RefreshController(),
          enablePullDown: parent != null,
          onRefresh: parent?.onRefresh,
          header: const MaterialClassicHeader(),
          child: content,
        ),
      ),
    );
  }
}
