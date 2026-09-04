// import 'package:edge_alert/edge_alert.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:rich_alert/rich_alert.dart';

import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Alert {
//   /// shows a toast message set [gravity] to  ToastGravity.TOP or ToastGravity.BOTTOM
//   showToast(BuildContext context,
//           {requiredString message, String title, int gravity = ToastGravity.TOP,
//           int duration = ToastLenght.LENGTH_LONG, backgroundColor: Colors.green, IconData icon}) =>
//       EdgeAlert.show(context,
//           title: title,
//           description: message,
//           icon: icon,
//           backgroundColor: Colors.green,
//           duration: (duration == ToastLenght.LENGTH_SHORT || duration == ToastLenght.LENGTH_LONG ||
//           duration == ToastLenght.LENGTH_VERY_LONG) ? duration : ToastLenght.LENGTH_LONG,
//           gravity:
//               (gravity == ToastGravity.TOP || gravity == ToastGravity.BOTTOM)
//                   ? gravity
//                   : ToastGravity.TOP);

//   showBottomDialog(BuildContext context, {int alertType = AlertType.SUCCESS, requiredString message, String title}) =>
//      showDialog(context: context,barrierDismissible: true,
//   builder: (BuildContext c) => RichAlertDialog(
//           //uses the custom alert dialog
//           alertTitle: richTitle(message),
//           actions: <Widget>[FlatButton(onPressed: ()=>{}, child: Text(''),)],
//           alertSubtitle: richSubtitle(message),
//           barrierDismissible: true,
//           alertType: (alertType == AlertType.SUCCESS ||
//                   alertType == AlertType.ERROR ||
//                   alertType == AlertType.WARNING)
//               ? alertType
//               : AlertType.SUCCESS));

  static void showFormDialog(BuildContext context,
          {required String title,
          required String message,
          List<Widget> actions = const [],
          bool barrierDismissible = false}) =>
      Platform.isIOS
          ? showCupertinoDialog(
              useRootNavigator: true,
              context: context,
              builder: (c) => CupertinoAlertDialog(
                    actions: actions,
                    title: Text(title),
                    content: Text(message),
                  ))
          : showDialog(
              context: context,
              barrierDismissible: false,
              useRootNavigator: true,
              builder: (c) => AlertDialog(
                    backgroundColor: Colors.white,
                    actions: actions,
                    title: Text(title),
                    content: Text(message),
                  ));
}

class ToastLenght {
  ///1 second
  static const int lenghtShort = 1;

  /// 2 seconds
  static const int lenghtLong = 2;

  /// 3 seconds
  static const int lenghtveryLong = 3;
}

class ToastGravity {
  static const int top = 1;
  static const int bottom = 2;
}

class AlertType {
  /// Indicates an error dialog by providing an error icon.
  static const int error = 0;

  /// Indicates a success dialog by providing a success icon.
  static const int success = 1;

  /// Indicates a warning dialog by providing a warning icon.
  static const int warning = 2;
}
