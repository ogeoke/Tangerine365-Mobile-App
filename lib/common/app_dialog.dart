import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_html/flutter_html.dart';

class AppDialog extends StatelessWidget {
  final List<DialogAction> actions;
  final String message;
  final String title;
  final bool useHtml;
  // final BuildContext context;
  const AppDialog(
      {super.key,
      required this.actions,
      required this.message,
      required this.title,
      this.useHtml = false});

  static Future<T> bottomSheet<T>(BuildContext context, Widget child,
      {bool isScrollControlled = true}) async {
    return await showModalBottomSheet(
        context: context,
        enableDrag: true,
        isScrollControlled: isScrollControlled,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        builder: (context) => child);
  }

  @override
  Widget build(BuildContext context) {
    List<DialogAction> a = actions;
    // var html = Html(data: message);
    return Theme.of(context).platform == TargetPlatform.iOS
        ? (CupertinoAlertDialog(
            actions: [
                for (var item in a)
                  CupertinoDialogAction(
                    onPressed:
                        item.onPressed ?? () => Navigator.of(context).pop(),
                    child: Text(
                      item.title,
                      textAlign: TextAlign.center,
                    ),
                  )
              ],
            title: Text(
              title,
              textAlign: TextAlign.center,
            ),
            content:

                // useHtml
                //   ? html
                Text(
              message,
              textAlign: TextAlign.center,
            )))
        // : CupertinoPopupSurface(
        //     child: Center(
        //         child: Padding(
        //             padding: const EdgeInsets.all(8.0),
        //             child: (useHtml
        //                 ? html
        //                 : Text(
        //                     message ?? '',
        //                     textAlign: TextAlign.center,
        //                     style: Theme.of(context)
        //                         .textTheme
        //                         .bodyText1
        //                         .copyWith(
        //                             color: Colors.white, fontSize: 16),
        //                   )))),
        //     isSurfacePainted: false,
        //   ))
        : AlertDialog(
            backgroundColor: Colors.white,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            actions: [
              for (var item in a)
                TextButton(
                    onPressed:
                        item.onPressed ?? () => Navigator.of(context).pop(),
                    child: Text(item.title))
            ],
            title: Text(title),
            content: Text(message),
          );
  }

  static Future<void> showBottomSheet(BuildContext context, Widget child,
      {bool isDismissible = true, bool showBackButton = false}) {
    return showModalBottomSheet(
      context: context,
      isDismissible: isDismissible,
      isScrollControlled: true,
      clipBehavior: Clip.antiAlias,
      backgroundColor: const Color(0xff242D4F).withOpacity(.16),
      builder: (c) => Container(
        color: Colors.white,
        height: MediaQuery.of(context).size.height,
        // padding: EdgeInsets.only(top: 50),
        child: Stack(
          children: [
            Container(margin: const EdgeInsets.only(top: 20), child: child),
            if (showBackButton)
              const Positioned(
                  top: 30,
                  left: 0,
                  child: Padding(
                      padding: EdgeInsets.only(right: 20), child: BackButton()
                      // ?? CloseButton(onPressed: () => Navigator.of(c).pop()),
                      ))
          ],
        ),
      ),
    );
  }

  static void buildErrorDialog(BuildContext context, String message,
      {Function()? retry}) {
    showDialog(
        context: context,
        builder: (c) => AppDialog(
              title: '',
              message: message, //?? 'Something went wrong',
              // title: 'Oops!',
              actions: [
                DialogAction(
                  title: 'close',
                ),
                if (retry != null)
                  DialogAction(title: 'close', onPressed: retry),
              ],
            ));
  }
}

/// action for a alert dialog, onpressed defaults to navigator.pop
class DialogAction {
  final String title;
  final Function()? onPressed;

  DialogAction({required this.title, this.onPressed});
}

typedef BuildWidget = Widget Function(BuildContext c);
