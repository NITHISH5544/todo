import 'package:flutter/material.dart';
import 'package:todo/utilities/dialgos/generic_dialog.dart';

Future<void> showErrorDialog(
  BuildContext context,
  String text,
) {
  return showGenericDialog(
    context: context,
    title: 'An Error Occured',
    content: text,
    optionsBulder: () => {
      'OK': null,
    },
  );
}
