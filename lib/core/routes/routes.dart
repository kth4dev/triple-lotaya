import 'package:flutter/material.dart';

void goToNextPage(BuildContext context, Widget widget) {
  Navigator.push(
      context,
      PageRouteBuilder(
        pageBuilder: (_, __, ___) => widget,
        transitionDuration: const Duration(seconds: 0),
      ));
}

void goToNextPageFinish(BuildContext context, Widget widget) {
  Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (context) => widget), (Route<dynamic> route) => false);
}

void goToNextPageReplacement(BuildContext context, Widget widget) {
  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
    return widget;
  }));
}

void goToNextPageAndRefresh(BuildContext context, Widget widget, VoidCallback refresh) {
  Route route = MaterialPageRoute(builder: (context) => widget);
  Navigator.push(context, route).then((value) => refresh());
}
