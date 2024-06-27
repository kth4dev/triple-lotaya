import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/routes/routes.dart';
import 'package:lotaya/core/values/images.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/presentation/screens/sales/sales_screen.dart';
import '../../../presentation/screens/login/login_screen.dart';
import '../textstyles/default_text.dart';
import '../textstyles/textstyles.dart';

AppBar defaultAppBar(BuildContext context, {required final String title}) {
  return AppBar(
    title: DefaultText(
      title,
      style: TextStyles.appBarTextStyle,
    ),
    actions: [
      PopupMenuButton(
          child: Center(child: DefaultText(CacheHelper.getAccountInfo().name.toString(), style: TextStyles.titleTextStyle)),
          itemBuilder: (context) {
            return [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Logout"),
              ),
            ];
          },
          onSelected: (value) {
            if (value == 0) {
              CacheHelper.removeLoginResponse();
              goToNextPageFinish(context, const LoginScreen());
            }
          }),
      20.paddingWidth,
      IconButton(
          onPressed: () {
            goToNextPage(context, const SalesScreen());
          },
          icon: const ImageIcon(AssetImage(Images.iconSales))),
      10.paddingWidth,
    ],
  );
}

AppBar emptyAppBar(BuildContext context, {required final String title}) {
  return AppBar(
    title: DefaultText(
      title,
      style: TextStyles.appBarTextStyle,
    ),
  );
}

AppBar appBarWithIcons(BuildContext context, {required final String title, required final List<Widget> actions}) {
  actions.insert(
    0,
    PopupMenuButton(
        child: Center(child: DefaultText(CacheHelper.getAccountInfo().name.toString(), style: TextStyles.titleTextStyle)),
        itemBuilder: (context) {
          return [
            const PopupMenuItem<int>(
              value: 0,
              child: Text("Logout"),
            ),
          ];
        },
        onSelected: (value) {
          if (value == 0) {
            CacheHelper.removeLoginResponse();
            goToNextPageFinish(context, const LoginScreen());
          }
        }),
  );
  return AppBar(
    title: DefaultText(
      title,
      style: TextStyles.appBarTextStyle,
    ),
    actions: actions,
  );
}
