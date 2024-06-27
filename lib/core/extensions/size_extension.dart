import 'package:flutter/cupertino.dart';

extension SizeExtension on num {
  Widget get paddingHeight => SizedBox(
        height: toDouble(),
      );

  Widget get paddingWidth => SizedBox(
        width: toDouble(),
      );
}


