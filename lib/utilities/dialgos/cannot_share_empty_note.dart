import 'package:flutter/material.dart';
import 'package:todo/utilities/dialgos/generic_dialog.dart';

Future<void> showCannotShareEmptyNoteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'sharing',
    content: 'You cannot share empty note',
    optionsBulder: () => {
      'OK': null,
    },
  );
}
