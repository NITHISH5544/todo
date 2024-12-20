import 'package:flutter/material.dart';
import 'package:todo/utilities/dialgos/generic_dialog.dart';

Future<bool> showDeleteDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Delete',
    content: 'Are you sure you want to delete this item?',
    optionsBulder: () => {
      'cancel': false,
      'Yes': true,
    },
  ).then((value) => value ?? false);
}
