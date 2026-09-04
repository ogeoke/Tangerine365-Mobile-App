import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/error_codes.dart' as auth_error;
import 'package:local_auth/local_auth.dart';

/// The reason a biometric attempt ended, so the UI can show the matching
/// result screen (00G enabled, 00H unsuccessful, 00N denied, 00O unavailable).
enum BiometricOutcome { success, failed, permissionDenied, unavailable }

class BiometricService {
  static final LocalAuthentication _localAuth = LocalAuthentication();

  static Future<bool> canCheckBiometrics() async =>
      await _localAuth.canCheckBiometrics;

  /// True when the device has usable, enrolled biometrics — used to decide
  /// whether to offer the "Enable biometrics" prompt at all.
  static Future<bool> isAvailable() async {
    try {
      final supported = await _localAuth.isDeviceSupported();
      if (!supported) return false;
      if (!await _localAuth.canCheckBiometrics) return false;
      final enrolled = await _localAuth.getAvailableBiometrics();
      return enrolled.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> didAuthenticate() async =>
      (await authenticate()) == BiometricOutcome.success;

  /// Runs the platform biometric prompt and classifies the result.
  static Future<BiometricOutcome> authenticate() async {
    try {
      if (!await _localAuth.isDeviceSupported()) {
        return BiometricOutcome.unavailable;
      }
      final ok = await _localAuth.authenticate(
        localizedReason: 'Please authenticate to access LMS',
        options: const AuthenticationOptions(
          useErrorDialogs: true,
          stickyAuth: true,
        ),
      );
      return ok ? BiometricOutcome.success : BiometricOutcome.failed;
    } on PlatformException catch (e) {
      if (kDebugMode) print('biometric error: ${e.code}');
      switch (e.code) {
        case auth_error.notAvailable:
        case auth_error.notEnrolled:
        case auth_error.passcodeNotSet:
          return BiometricOutcome.unavailable;
        case auth_error.lockedOut:
        case auth_error.permanentlyLockedOut:
          return BiometricOutcome.permissionDenied;
        default:
          return BiometricOutcome.failed;
      }
    } catch (e) {
      if (kDebugMode) print(e);
      return BiometricOutcome.failed;
    }
  }

  //  static Widget dialog()=>FingerprintDialog();
  static void cancel() {
    //  _localAuth.authenticateWithBiometrics();
  }
}

// class FingerprintDialog extends StatefulWidget {
//   @override
//   _FingerprintDialogState createState() => _FingerprintDialogState();
// }

// class _FingerprintDialogState extends State<FingerprintDialog> with SingleTickerProviderStateMixin {
//   TextStyle _textTheme ;
//   bool hasError = false;
//   AnimationController _controller;
//   Animation<double> _animation;
//     @override
//   void initState() {
//     _controller = AnimationController(vsync: this, duration: Duration(milliseconds: 300));
//     _animation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
//     super.initState();
//     _authenticate();
//   }
//   void _authenticate()async {
//      print('start auth auth');
//   hasError = await BiometricService.didAuthenticate();
//   if(hasError){
//     setState(() {
//       _controller.repeat();
//     });
//   }
//   print('finished auth');
//   }

//   void _animate(){
//     // _controller.value < 1 ? _controller.forward() : _controller.repeat()
//   }
//   @override
//   Widget build(BuildContext context) {
//      _textTheme = Theme.of(context).textTheme.display1.copyWith(color: Colors.black, fontSize: 18, letterSpacing: .5, fontWeight: FontWeight.w400);
//     return WillPopScope(
//       onWillPop: () async {
//         BiometricService.cancel();
//         return true;
//       },
//           child: Container(height: 350,
//                               child: Padding(
//                                 padding: const EdgeInsets.only(left: 20.0, top: 30),
//                                 child: Column(
//                                   mainAxisAlignment: MainAxisAlignment.end,
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: <Widget>[
//                                     Text('Fingerprint Authentication', style: _textTheme,),
//                                      SizedBox(height: 15),
//                                     Text('Touch Sensor', style: _textTheme.copyWith(fontSize: 15,letterSpacing: .3 )),
//                                      SizedBox(height: 10),
//                                     Text('Please authenticate to access LMS', style: _textTheme.copyWith(fontSize: 15,letterSpacing: .3 )),
//                                     Spacer(),
//                                     Center(child: AnimatedBuilder(animation: _animation, builder: (c, w)=>
//                                      Icon(Icons.fingerprint, size: 70, color: hasError ? Colors.red : Color.fromRGBO(8, 125, 10, 1)))),
//                                     SizedBox(height: 15),
//                                     Center(child: Text('Touch the fingerprint sensor', style: _textTheme.copyWith(fontSize: 12, color: Colors.black54, letterSpacing: .2),)),
//                                     Spacer(),
//                                     Container(alignment: Alignment.centerLeft,
//                                       child: FlatButton(child: Text('CANCEL',style: Theme.of(context).textTheme
//                                       .display1.copyWith(fontSize: 16,
//                                       fontWeight: FontWeight.w400, letterSpacing: .1, color: Color.fromRGBO(8, 125, 10, .9))), onPressed: ()=>Navigator.of(context).pop(),))
//                                   ],
//                                 ),
//                               ),

//                             ),
//     );
//   }
// }
