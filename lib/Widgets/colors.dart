import 'package:provider/provider.dart';
import 'package:split_smart/Providers/colourProviders.dart';
import 'package:flutter/material.dart';

Color? Primary(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Primary'];
}

Color? Accent(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Accent'];
}

Color? Button(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Button'];
}

Color? Success(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Success'];
}

Color? ErrorColor(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Error'];
}

Color? Background(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Background'];
}

Color? Surface(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Surface'];
}

Color? TextPrimary(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Text Primary'];
}

Color? TextSecondary(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Text Secondary'];
}

Color? DividerColor(BuildContext context) {
  return Provider.of<colorProvider>(context).presentTheme['Divider'];
}
