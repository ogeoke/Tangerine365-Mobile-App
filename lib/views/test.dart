import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
// import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart' as extended;

class TestPage extends StatelessWidget {
  TestPage({super.key});
  final ScrollController _scrollController = ScrollController();

  final RefreshController refreshController = RefreshController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
          //      pinnedHeaderSliverHeightBuilder: () {
          //   return 100;
          // },

          dragStartBehavior: DragStartBehavior.start,
          controller: _scrollController,
          physics: const ClampingScrollPhysics(),
          // shrinkWrap: true,
          headerSliverBuilder: (c, b) => [
                SliverAppBar(
                  primary: true,
                  expandedHeight: 200, floating: true,
                  // onStretchTrigger: ,
                  stretchTriggerOffset: 10,
                  pinned: true, stretch: false,
                  flexibleSpace: FlexibleSpaceBar(
                    title: Text('item.title',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium
                            ?.copyWith(fontSize: 20, color: Colors.white)),
                    background: Container(color: Colors.red),
                    collapseMode: CollapseMode.parallax,
                  ),
                ),

                //  SliverToBoxAdapter(child:   Container(color: Colors.redAccent, height: 40, ))
              ],
          body: Column(
            children: <Widget>[
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              Container(color: Colors.black, height: 20),
              //     body: SmartRefresher(
              // controller:  refreshController,
              // enablePullDown: true,
              // onRefresh: (){},
              // header: MaterialClassicHeader(offset: 50, height: 50, ),
              // child: SafeArea(
              //         child: Container(height: 400,
              //         color: Colors.blueAccent,
              //         child: Column(
              //           // controller: _scrollController,
              //           children: <Widget>[
              //             Flexible(child: Container(color: Colors.red, height: 20, )),
              //             Container(color: Colors.red, height: 20, ),
              //             Container(color: Colors.red, height: 20, ),
              //              Spacer(),
              //           ],
              //         )
              //       ),
              // ),
            ],
          )),
    );
  }
}
