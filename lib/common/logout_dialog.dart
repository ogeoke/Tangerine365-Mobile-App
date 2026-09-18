import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';
import 'package:sevenup_mobile/state/auth/index.dart';

const Color logoutColor = Color(0xFFE5361B);

/// The one logout confirmation used everywhere (Figma Group 406) — the side
/// menu and the Home logout button must not diverge.
///
/// [closeDrawer] pops the side menu behind the dialog when it was opened there.
void confirmLogout(BuildContext context, {bool closeDrawer = false}) {
  showDialog<void>(
    context: context,
    builder: (c) => Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 44),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('!',
                style: AppTokens.manrope(
                    size: 30, weight: 700, color: logoutColor)),
            const SizedBox(height: 4),
            Text('Log out of Tangerine365?',
                textAlign: TextAlign.center,
                style: AppTokens.manrope(
                    size: 17, weight: 700, color: AppTokens.textPrimary)),
            const SizedBox(height: 8),
            Text(
              "You'll need to enter your login details and complete "
              'verification again.',
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 12,
                  weight: 400,
                  height: 17,
                  color: AppTokens.textSecondary),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: logoutColor,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () {
                  Navigator.of(c).pop(); // dialog
                  if (closeDrawer) Navigator.of(context).pop(); // drawer
                  GetIt.I<AuthBloc>().add(const LogOut(true));
                },
                child: Text('Log out',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 44,
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTokens.primary),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                onPressed: () => Navigator.of(c).pop(),
                child: Text('Cancel',
                    style: AppTokens.manrope(
                        size: 14, weight: 600, color: AppTokens.primary)),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
