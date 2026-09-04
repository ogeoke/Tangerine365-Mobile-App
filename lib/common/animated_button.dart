import 'package:sevenup_mobile/state/login/login_bloc.dart';
import 'package:flutter/material.dart';

class AnimatedButton extends StatefulWidget {
  final String label;
  final Function()? onPressed;
  final bool isLoading;
  final ShapeBorder? shape;
  final Color? backgroundColor, textColor;
  final LoginBloc? bloc;
  final double? padding;

  const AnimatedButton(
      {super.key,
      required this.label,
      required this.onPressed,
      this.isLoading = false,
      this.shape,
      this.backgroundColor,
      this.textColor,
      this.bloc,
      this.padding});
  @override
  AnimatedButtonState createState() => AnimatedButtonState();
}

class AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late ShapeBorder shape;
  late AnimationController _controller;
  // late Animation<double> _animation;
  @override
  void initState() {
    shape = widget.shape ??
        RoundedRectangleBorder(borderRadius: BorderRadius.circular(30));
    _controller = AnimationController(
      vsync: this,
    );
    // _animation = CurvedAnimation(parent: _controller, curve: Curves.bounceOut);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: widget.padding ?? 35),
      child: InkWell(
        onTap: widget.onPressed,
        child: AnimatedContainer(
          curve: Curves.easeInToLinear,
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
              color: widget.isLoading
                  ? Theme.of(context).primaryColor
                  : widget.backgroundColor ?? Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(30)),
          child: Padding(
            padding: widget.isLoading
                ? const EdgeInsets.symmetric(horizontal: 18, vertical: 8)
                : const EdgeInsets.all(14.5),
            child: widget.isLoading
                ? CircularProgressIndicator(
                    backgroundColor: Theme.of(context).primaryColor,
                    strokeWidth: 0.8,
                    valueColor:
                        ColorTween(begin: Colors.white).animate(_controller))
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      Text(widget.label,
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: widget.textColor ?? Colors.white,
                                  fontSize: 16)),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
