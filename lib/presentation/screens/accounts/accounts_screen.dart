import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/presentation/screens/accounts/widgets/accounts_list_widget.dart';
import 'package:lotaya/presentation/screens/accounts/widgets/create_account_widget.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "အကောင့်များ"),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: setUpUI(context),
          ),
        ],
      ),
    );
  }

  Widget setUpUI(BuildContext context){
    Widget createAccountWidget= CreateAccountWidget(accountsStream: FirebaseFirestore.instance.collection("users").orderBy("createdDate", descending: false).snapshots(),);
    Widget accountListWidget=AccountListWidget(accountsStream: FirebaseFirestore.instance.collection("users").orderBy("createdDate", descending: false).snapshots(),);
    double width=MediaQuery.of(context).size.width;
    if(width>1000){
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:  [
           Expanded(
              flex: 2,
              child:createAccountWidget),
          10.paddingWidth,
          Expanded(
              flex: 3,
              child: accountListWidget)
        ],
      );
    }else{
      return Column(
        children:  [
          ExpansionTile(
            initiallyExpanded: true,
              title:DefaultText("အကောင့်အသစ်ဖွင့်ခြင်း", style: TextStyles.titleTextStyle.copyWith(fontWeight: FontWeight.bold)),
              children: [Padding(
                padding: const EdgeInsets.all(8.0),
                child: createAccountWidget,
              )]),
          10.paddingHeight,
          accountListWidget
        ],
      );
    }
  }

  late Stream<QuerySnapshot> _accountsStream;
  @override
  void initState() {
    super.initState();
    _accountsStream=FirebaseFirestore.instance.collection("users").orderBy("createdDate", descending: false).snapshots();

  }
}
