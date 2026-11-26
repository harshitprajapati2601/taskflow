import 'package:flutter/material.dart';

///// Full-width button with a loading spinner.
// /// `outlined: true` gives the secondary style (e.g. "Continue with Google").
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final bool isLoading;
  final IconData? icon;
  final bool outlined;

  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.icon,
    this.outlined = false
  });

  @override
  Widget build(BuildContext context) {
    //get the app theme color
    final scheme = Theme.of(context).colorScheme;

    //Create button shape
    final shape = RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14)
    );

    //Decide what appears inside the button
    final child = isLoading
        ? SizedBox(
      height: 20,
      width: 20,
      child: CircularProgressIndicator(
        strokeWidth: 2,
        color: outlined ? scheme.primary : scheme.onPrimary,
      ),)

        : Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
            label,
          style: const TextStyle(
            fontWeight: FontWeight.w600
          ),
        )
      ],
    );

    //Handle button  during loading
    final VoidCallback tap = isLoading ? () {} : onPressed;

    return SizedBox(
      width: double.infinity,
      height: 52,

      //choose the button style
      child:outlined
      ? OutlinedButton(
          style: OutlinedButton.styleFrom(shape: shape),
          onPressed: tap,
          child: child
      )
      : FilledButton(
        style: OutlinedButton.styleFrom(shape: shape),
          onPressed: tap,
          child: child
      )
    );
  }
}
