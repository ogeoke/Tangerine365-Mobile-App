import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import 'package:webview_flutter/webview_flutter.dart';

// import 'package:webviewx_plus/webviewx_plus.dart'
// hide
//     NavigationDecision,
//     NavigationDelegate,
//     WebResourceError,
//     WebResourceError,
//     NavigationRequest;

import '../common/theme.dart';
// import 'package:webview_flutter/webview_flutter.dart';

class PlayCoursePage extends StatefulWidget {
  static const routeName = '/play_course';
  final Uri url;
  final String auth;

  const PlayCoursePage({super.key, required this.url, required this.auth});

  @override
  QuickTourPageState createState() => QuickTourPageState();
}

class QuickTourPageState extends State<PlayCoursePage> {
  // late InAppWebViewController webView;
  late Uri? url;
  late WebViewController controller;
  // final flutterWebviewPlugin = new FlutterWebviewPlugin();
  final RefreshController refreshController = RefreshController(
    initialRefresh: true,
  );
  double progress = 0;
  bool isLoading = true;

  // InAppWebViewController? webViewController;
  // InAppWebViewSettings settings = InAppWebViewSettings(
  //     isInspectable: kDebugMode,
  //     mediaPlaybackRequiresUserGesture: false,
  //     allowsInlineMediaPlayback: true,
  //     iframeAllow: "camera; microphone",
  //     allowFileAccess: true,
  //     allowContentAccess: true,
  //     allowFileAccessFromFileURLs: true,
  //     iframeAllowFullscreen: true);
  @override
  void initState() {
    // webView = InAppWebViewController();
    // print(widget.url);
    _setOrientation();
    url = widget.url;
    print('console:: ${widget.url}');
    controller = WebViewController()
      ..setOnConsoleMessage((m) {
        print('console:: ${m.message}');
        if (m.message.contains('Close SCORM')) {
          Navigator.of(context).maybePop();
        }
      })
      // ..setOnJavaScriptConfirmDialog((m) async {
      //   return (await showDialog<bool>(
      //           context: context,
      //           builder: (c) => AppDialog(
      //                 message: m.message,
      //                 title: 'Alert',
      //                 actions: [
      //                   DialogAction(
      //                     title: 'Continue',
      //                     onPressed: () => Navigator.of(c).pop(true),
      //                   ),
      //                   DialogAction(
      //                     title: 'close',
      //                     onPressed: () => Navigator.of(c).pop(false),
      //                   ),
      //                 ],
      //               )) ??
      //       false);
      // })
      // ..setOnJavaScriptAlertDialog((m) async {
      //   print(m.message);
      //   //  AppDialog.showBottomSheet(context, child)
      //   showDialog(
      //       context: context,
      //       builder: (c) => AppDialog(
      //             message: m.message,
      //             title: 'Alert',
      //             actions: [
      //               DialogAction(
      //                 title: 'close',
      //               ),
      //             ],
      //           ));
      // })
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            if (progress > 95) {
              refreshController.refreshCompleted();
            }
          },
          onPageStarted: (String url) {},
          onPageFinished: (String url) {
            setState(() {
              this.url = Uri.tryParse(url);
              isLoading = false;
            });
          },
          onHttpError: (HttpResponseError error) {
            print(error.toString());
            refreshController.refreshFailed();
          },
          onWebResourceError: (error) {
            print(error.toString());
            refreshController.refreshFailed();
          },
          onUrlChange: (change) {
            print('change.url::: ${change.url}');
          },
          // url = Uri.tryParse(change.url ?? '');
          // url = url?.replace(queryParameters: {
          //   'auth': widget.auth,
          //   ...?url?.queryParameters
          // });
          // controller.loadRequest(url!);
          // },
          onNavigationRequest: (NavigationRequest request) {
            return NavigationDecision.navigate;
          },
        ),
      )
      ..clearCache()
      ..clearLocalStorage()
      ..loadRequest(widget.url);
    super.initState();
  }

  _setOrientation() {
    WidgetsBinding.instance.addPostFrameCallback((d) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    });
  }

  @override
  Widget build(BuildContext context) =>
      // InAppBrowserExampleScreen(
      //   url: widget.url,
      // ) ??
      Material(
        child: PopScope(
          onPopInvokedWithResult: (status, a) async {
            SystemChrome.setPreferredOrientations([
              DeviceOrientation.portraitUp,
            ]);
            SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
            // return status;
          },
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              // PlayCourseWebView(
              //   url: url,
              // ),
              // kIsWeb
              // ? PlayCourseWeb(url: widget.url)
              // Inset the course content within the safe area so its bottom
              // controls (e.g. the Submit button) aren't hidden behind the
              // device's system navigation bar in edge-to-edge mode.
              SafeArea(child: WebViewWidget(controller: controller)),

              // InAppWebView(
              //     // initialSettings: settings,
              //     initialUrlRequest: URLRequest(url: widget.url),
              //     // onConsoleMessage: (c, m) {
              //     //   if (m.message.contains('Close SCORM')) {
              //     //     Navigator.of(context).maybePop();
              //     //   }
              //     //   // print('console message ${m.message}');
              //     // },
              //     onWebViewCreated: (InAppWebViewController controller) {
              //       controller = controller;
              //     },
              //     // onJsAlert: (w, s) async {
              //     //   // print(s);
              //     //   // print('alert');

              //     //   if (s.message?.contains('Invalid login') == true) {
              //     //      GetIt.I<AuthBloc>().add(
              //     //         const LogOut(false, AppStrings.multipleLogins));
              //     //     Navigator.of(context).maybePop();
              //     //     return JsAlertResponse(handledByClient: true);
              //     //   }
              //     //   return JsAlertResponse(handledByClient: false);
              //     // },
              //     onLoadStart: (controller, url) {
              //       setState(() {
              //         this.url = url;
              //       });
              //     },
              //     onLoadStop: (controller, url) async {
              //       // print('load stop');
              //       // refreshController.loadComplete();
              //       setState(() {
              //         this.url = url;
              //         isLoading = false;
              //       });
              //     },
              //     // onReceivedError: (
              //     //   controller,
              //     //   uri,
              //     //   cod,
              //     // ) async {
              //     //   // print('an error occured');
              //     //   // print(uri);
              //     //   // print(cod);
              //     //   // print(message);
              //     //   refreshController.refreshFailed();
              //     //   return;
              //     // },
              //     onProgressChanged:
              //         (InAppWebViewController controller, int progress) {
              //       // print('loading complete $progress');
              //       if (progress > 95) {
              //         refreshController.refreshCompleted();
              //       }
              //     }),
              if (isLoading && !kIsWeb)
                SmartRefresher(
                  enablePullDown: true,
                  header: const MaterialClassicHeader(),
                  controller: refreshController,
                  onRefresh: () async {
                    // await webView.reload();
                  },
                  child: const SizedBox.expand(
                      // child: Container(
                      //     // color: Colors.red,
                      //     ),
                      ),
                ),
              if (!kIsWeb)
                Positioned(
                  top: 10,
                  right: 10,
                  child: SafeArea(
                    child: Material(
                      color: AppTheme.env.accentColor,
                      shape: CircleBorder(
                        side: BorderSide(
                          color: AppTheme.env.accentColor,
                          width: 1,
                        ),
                      ),
                      child: CupertinoButton(
                        minSize: 10,
                        padding: const EdgeInsets.all(8),
                        onPressed: () {
                          Navigator.of(context).maybePop();
                        },
                        child: const Icon(
                          Icons.close,
                          color: Colors.black,
                          size: 12,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      );
}

// class PlayCourseWeb extends StatefulWidget {
//   final String url;
//   const PlayCourseWeb({super.key, required this.url});

//   @override
//   State<PlayCourseWeb> createState() => _PlayCourseWebState();
// }

// class _PlayCourseWebState extends State<PlayCourseWeb> {
//   // late WebViewXController webviewController;
//   @override
//   Widget build(BuildContext context) {
//     return WebViewX(
//       initialContent: widget.url,
//       initialSourceType: SourceType.url,
//       onWebViewCreated: (controller) {
//         webviewController = controller;
//         // controller.loadContent()
//       },
//       height: MediaQuery.of(context).size.height,
//       width: MediaQuery.of(context).size.width,
//     );
//   }
// }

// controller.isLoading()
//                         if(progress > 90) refreshController.loadComplete();

// class PlayCourseWebView extends StatefulWidget {
//   /// Public API key gotten from your mono dashboard
//   final String url;

//   /// a function called when transaction succeeds
//   final Function(String code) onSuccess;

//   /// a function called when user clicks the close buton on mono's page
//   final Function onClosed;

//   /// An overlay widget to display over webview if page fails to load
//   final Widget error;

//   const PlayCourseWebView(
//       {Key? key, required this.url, this.error, this.onSuccess, this.onClosed})
//       : super(key: key);

//   @override
//   _PlayCourseWebViewState createState() => _PlayCourseWebViewState();
// }

// class _PlayCourseWebViewState extends State<PlayCourseWebView> {
//   WebViewController _webViewController;
//   bool isLoading = false;
//   bool hasError = false;
//   @override
//   void initState() {
//     if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
//     super.initState();
//   }

//   @override
//   Widget build(BuildContext context) {
//     print(widget.url);
//     return WillPopScope(
//       onWillPop: () async {
//         if (widget.onClosed != null) widget.onClosed();
//         return true;
//       },
//       child: Material(
//         child: GestureDetector(
//             onTap: () {
//               WidgetsBinding.instance.focusManager.primaryFocus?.unfocus();
//             },
//             child: SafeArea(
//               child: Stack(children: [
//                 Container(
//                   // margin: EdgeInsets.only(top: 30),
//                   decoration: BoxDecoration(
//                       border: Border.all(color: Colors.transparent)),
//                   child: WebView(
//                     initialUrl: widget.url,
//                     javascriptMode: JavascriptMode.unrestricted,
//                     onWebViewCreated: (WebViewController webViewController) {
//                       // if (!_controller.isCompleted)
//                       //   _controller.complete(webViewController);
//                       _webViewController = webViewController;
//                     },
//                     onPageStarted: (String url) {
//                       // hasFoward = await _webViewController?.canGoForward();
//                       setState(() {
//                         isLoading = true;
//                         hasError = false;
//                       });
//                     },
//                     javascriptChannels: <JavascriptChannel>[
//                       _monoJavascriptChannel(context),
//                     ].toSet(),
//                     gestureRecognizers: Set()
//                       ..add(Factory<TapGestureRecognizer>(
//                           () => TapGestureRecognizer()
//                             ..onTapDown = (tap) {
//                               SystemChannels.textInput.invokeMethod(
//                                   'TextInput.hide'); //This will hide keyboard ontapdown
//                             })),
//                     debuggingEnabled: kDebugMode,
//                     onWebResourceError: (err) async {
//                       isLoading = false;
//                       setState(() {
//                         hasError = true;
//                       });
//                     },
//                     initialMediaPlaybackPolicy:
//                         AutoMediaPlaybackPolicy.always_allow,
//                     onPageFinished: (String url) async {
//                       isLoading = false;
//                       setState(() {});
//                       // _webViewController.evaluateJavascript(
//                       //     'MonoClientInterface.postMessage("reyfhgjgf");123;');
//                     },
//                   ),
//                 ),
//                 if (isLoading)
//                   Center(
//                     child: CupertinoActivityIndicator(),
//                   ),
//                 if (hasError) widget.error ?? _error
//               ]),
//             )),
//       ),
//     );
//   }

//   /// A default overlay widget to display over webview if page fails to load
//   Widget get _error => Container(
//       alignment: Alignment.center,
//       color: Colors.white,
//       child: Column(
//         mainAxisAlignment: MainAxisAlignment.center,
//         children: [
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: RaisedButton(
//                 child: Text('Reload'),
//                 onPressed: () {
//                   _webViewController.reload();
//                 }),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(20.0),
//             child: Text(
//               'Sorry An error occured could not connect with Mono',
//               textAlign: TextAlign.center,
//             ),
//           ),
//         ],
//       ));

//   /// javascript channel for events sent by mono
//   JavascriptChannel _monoJavascriptChannel(BuildContext context) {
//     return JavascriptChannel(
//         // name: 'top',
//         name: 'MonoClientInterface',
//         onMessageReceived: (JavascriptMessage message) {
//           if (kDebugMode) print('MonoClientInterface, ${message.message}');
//           // var res = json.decode(message.message);
//           // if (kDebugMode)
//           //   print('MonoClientInterface, ${(res as Map<String, dynamic>)}');
//           // handleResponse(res as Map<String, dynamic>);
//         });
//   }

//   /// parse event from javascript channel
//   // void handleResponse(Map<String, dynamic> body) {
//   //   String key = body['type'];
//   //   if (body != null && key != null) {
//   //     switch (key) {
//   //       case 'mono.connect.widget.account_linked':
//   //       case 'mono.modal.linked':
//   //         var response = body['response'];
//   //         if (response == null) return;
//   //         var code = response['code'];
//   //         if (widget.onSuccess != null) widget.onSuccess(code);
//   //         if (mounted) Navigator.of(context).pop(code);
//   //         break;
//   //       case 'mono.connect.widget.closed':
//   //         // case 'mono.modal.closed':
//   //         if (widget.onClosed != null) widget.onClosed();
//   //         if (mounted) Navigator.of(context).pop();
//   //         break;
//   //       default:
//   //     }
//   // }
//   // }
// }
// https://wings.wemabank.com/appLms/index.php?modname=organization&op=custom_playitem&id_item=232&auth=2f0f03caeb4a6064167e8361b7561f77

// https://wings.wemabank.com/files/appLms/scorm/11840_9_1725278934_PASTRY-3.zip_content/index_lms.html?modname=organization&op=custom_playitem&id_item=232&auth=2f0f03caeb4a6064167e8361b7561f77
