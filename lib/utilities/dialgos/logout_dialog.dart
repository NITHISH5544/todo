import 'package:flutter/material.dart';
import 'package:todo/utilities/dialgos/generic_dialog.dart';

Future<bool> showLogOutDialog(BuildContext context) {
  return showGenericDialog(
    context: context,
    title: 'Log out',
    content: 'Are you sure you want to log out?',
    optionsBulder: () => {
      'cancel': false,
      'Log out': true,
    },
  ).then((value) => value ?? false);
}
