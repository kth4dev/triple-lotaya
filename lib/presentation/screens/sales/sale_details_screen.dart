import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/screens/sales/SelectUser.dart';
import 'package:lotaya/presentation/screens/sales/widgets/insert_digit_menu_dialog.dart';
import 'package:lotaya/presentation/screens/sales/widgets/sale_details_input_box_widget.dart';



class SaleDetailsScreen extends StatefulWidget {
  final DigitMatch match;

  const SaleDetailsScreen({Key? key, required this.match}) : super(key: key);

  @override
  State<SaleDetailsScreen> createState() => _SaleDetailsScreenState();
}

class _SaleDetailsScreenState extends State<SaleDetailsScreen> {
  List<String> userTypes = ["in", "out"];
  final SelectUser selectUser=SelectUser(userType: (CacheHelper.getAccountInfo().type == "admin")? "out":"in", userName: CacheHelper.getAccountInfo().name);


  @override
  void initState() {
    super.initState();
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xfff8f6f6),
      appBar: appBarWithIcons(context, title:widget.match.matchId,actions: [
        10.paddingWidth,
        IconButton(onPressed: ()=> showInsertDigitMenuDialog(context: context), icon: const Icon(Icons.menu_book)),
        10.paddingWidth
      ] ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: SaleDetailsInputBoxWidget(selectUser: selectUser,  match: widget.match,),
        ),
      ),
    );
  }


}
