import 'package:flutter/material.dart';

class AlertWidget extends StatelessWidget {
  final bool isError;
  final String message;
  const AlertWidget({super.key, this.isError = true, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 25),
      padding: const EdgeInsets.all(10.0),
      decoration: BoxDecoration(
          color: Colors.white,
          border:
              Border.all(color: isError ? Colors.red : Colors.green, width: 2)),
      child: Column(
        children: <Widget>[
          if (isError)
            Text(
              'ERROR',
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium
                  ?.copyWith(color: Colors.red, fontWeight: FontWeight.w500),
            ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(message,
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: Colors.red,
                    fontWeight: FontWeight.w400,
                    fontSize: 15,
                    letterSpacing: 2),
                textAlign: TextAlign.center),
          ),
        ],
      ),
    );
  }
}
