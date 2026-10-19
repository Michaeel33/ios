import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

String getFormattedDateTime(num timestamp, [String pattern = 'yyyy-MM-dd']) =>
    DateFormat(pattern)
        .format(DateTime.fromMillisecondsSinceEpoch(timestamp.toInt()));

void showMsg(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
