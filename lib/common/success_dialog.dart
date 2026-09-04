import 'package:flutter/material.dart';
import 'package:sevenup_mobile/constants/app_tokens.dart';

/// Approved success popup (Figma 09A / 10A / 11B): a green check in a light-green
/// circle, a title, a message, and a single full-width action button.
class AppSuccessDialog extends StatelessWidget {
  final String title;
  final String message;
  final String buttonLabel;
  final VoidCallback? onButton;

  const AppSuccessDialog({
    super.key,
    required this.title,
    required this.message,
    this.buttonLabel = 'Done',
    this.onButton,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconCircle(
              child: const Icon(Icons.check, color: AppTokens.primary, size: 40),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 22, weight: 700, color: AppTokens.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  height: 20,
                  color: AppTokens.textSecondary),
            ),
            const SizedBox(height: 22),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTokens.primary,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: onButton ?? () => Navigator.of(context).pop(),
                child: Text(
                  buttonLabel,
                  style: AppTokens.manrope(
                      size: 15, weight: 600, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Approved confirmation popup (Figma 11A): a "?" in a light-green circle, a
/// title/message, and Cancel + Confirm buttons.
class AppConfirmDialog extends StatelessWidget {
  final String title;
  final String message;
  final String cancelLabel;
  final String confirmLabel;
  final VoidCallback onCancel;
  final VoidCallback onConfirm;
  final bool loading;

  const AppConfirmDialog({
    super.key,
    required this.title,
    required this.message,
    required this.onCancel,
    required this.onConfirm,
    this.cancelLabel = 'Cancel',
    this.confirmLabel = 'Confirm',
    this.loading = false,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _IconCircle(
              child: Text(
                '?',
                style: AppTokens.manrope(
                    size: 34, weight: 700, color: AppTokens.primary),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              title,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 24, weight: 700, color: AppTokens.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: AppTokens.manrope(
                  size: 13,
                  weight: 400,
                  height: 20,
                  color: AppTokens.textSecondary),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTokens.primary),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: loading ? null : onCancel,
                      child: Text(
                        cancelLabel,
                        style: AppTokens.manrope(
                            size: 14, weight: 600, color: AppTokens.primary),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTokens.primary,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      onPressed: loading ? null : onConfirm,
                      child: loading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              confirmLabel,
                              style: AppTokens.manrope(
                                  size: 14, weight: 600, color: Colors.white),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _IconCircle extends StatelessWidget {
  final Widget child;
  const _IconCircle({required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 72,
      height: 72,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: AppTokens.lightGreen,
      ),
      child: child,
    );
  }
}
