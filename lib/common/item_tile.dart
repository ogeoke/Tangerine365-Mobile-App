import 'package:sevenup_mobile/views/dashboard_page.dart';
import 'package:flutter/material.dart';

import 'theme.dart';

class ItemTile extends StatelessWidget {
  final DashboardItem item;
  final bool showTitle;
  const ItemTile(this.item, {super.key, this.showTitle = true});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          color: AppTheme.env.accentColor,
          image: DecorationImage(
              fit: BoxFit.cover,
              // colorFilter: ColorFilter.mode(
              //     Theme.of(context).primaryColor, BlendMode.dstOver),
              image: AssetImage(item.backgroundImage))),
      margin: showTitle
          ? const EdgeInsets.symmetric(horizontal: 10.0, vertical: 5)
          : EdgeInsets.zero,
      child: InkWell(
          onTap: () {
            Navigator.of(context).pushNamed(item.routeName, arguments: item);
          },
          child: Hero(
            tag: Key(item.title),
            child: Stack(
              alignment: Alignment.bottomCenter,
              children: <Widget>[
                const SizedBox.expand(),
                Container(
                    color: Theme.of(context).primaryColor.withOpacity(0.2)),
                Container(
                    decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Theme.of(context).primaryColor.withOpacity(0.3),
                      Colors.black.withOpacity(0.9),
                    ],
                  ),
                )),
                if (showTitle)
                  Container(
                    padding: const EdgeInsets.all(15.0),
                    child: Text(item.title,
                        style: Theme.of(context)
                            .textTheme
                            .displayMedium
                            ?.copyWith(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white)),
                  )
              ],
            ),
          )),
    );
  }
}
