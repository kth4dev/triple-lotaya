import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/data/model/user.dart';

import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/collections.dart';

class AddMemberScreen extends StatefulWidget {
  final DigitMatch digitMatch;

  const AddMemberScreen({Key? key, required this.digitMatch}) : super(key: key);

  @override
  State<AddMemberScreen> createState() => _AddMemberScreenState();
}

class _AddMemberScreenState extends State<AddMemberScreen> {
  List<Account> accountList = [];

  @override
  void initState(){
    super.initState();
    accountList.addAll(widget.digitMatch.inAccounts);
    accountList.addAll(widget.digitMatch.outAccounts);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: defaultAppBar(context, title: widget.digitMatch.matchId),
        body: SingleChildScrollView(
          child: (MediaQuery.of(context).size.width > 1000)
              ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [Expanded(
                    flex: 2,
                      child: addPlayerWidget),Expanded(
                      flex: 3,child: accountListWidget)],
                )
              : Column(
                  children: [addPlayerWidget,accountListWidget],
                ),
        ));
  }
  bool isAccountContain(String userName){
    for(Account account in accountList){
      if(account.name == userName){
        return true;
      }
    }
    return false;
  }
  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }
  String? _selectedReferUser;
  Account? _selectedAccount;
  Widget get addPlayerWidget {
    return Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
            border: Border.all(
          width: 1,
        )),
        child: Column(
          children: [
        StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection("users").orderBy("createdDate", descending: false).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }
            if (snapshot.data!.size == 0) {
              return const DefaultText("Refer User : No Data", style: TextStyles.bodyTextStyle);
            }else{
              List<String> accountNames = [];
              List<Account> filterAccountList = [];
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                Account account = Account.fromJson(data);
                if(!isAccountContain(account.name)){
                  accountNames.add(document.id);
                  filterAccountList.add(account);
                }

              }).toList();
              if(accountNames.isNotEmpty){
                _selectedReferUser=accountNames[0];
                _selectedAccount=filterAccountList[0];
                return Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8),
                      child: UnderLineDropDownButton(
                        initialValue: accountNames[0],
                        values: accountNames,
                        label: "User",
                        onChange: (String? newValue) {
                          if (newValue != null) {
                            _selectedAccount=filterAccountList[accountNames.indexOf(newValue)];
                            _selectedReferUser=newValue;
                          }
                        },
                      ),
                    ),
                    PrimaryButton(onPressed: (){
                      if(_selectedAccount!=null){
                        if(_selectedAccount!.type=="output"){
                          widget.digitMatch.outAccounts.add(_selectedAccount!);
                        }else{
                          widget.digitMatch.inAccounts.add(_selectedAccount!);
                        }

                        showLoadingDialog(context: context, title: "Add User", content: "updating...");
                        FirebaseFirestore.instance
                            .collection(Collections.match)
                            .doc(widget.digitMatch.matchId)
                            .set(widget.digitMatch.toJson())
                            .then((value) {

                          setState(() {
                            if(_selectedAccount!=null) {
                              accountList.add(_selectedAccount!);
                            }
                          });
                          Navigator.of(context).pop();
                          Toasts.showErrorMessageToast("Created AM Match Successfully");
                        }).catchError((error) {
                          Navigator.of(context).pop();
                          Toasts.showErrorMessageToast("Failed to create AM Match: $error");
                        });
                      }

                    }, label:"Add")
                  ],
                );
              }
              return const DefaultText("New User : No Data", style: TextStyles.bodyTextStyle);
            }
          },
        )
          ],
        ));
  }

  Widget get accountListWidget {

    int index = 0;
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: DataTable(
            headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
            columns: [
              buildRowHeader("No"),
              buildRowHeader("Name"),
              buildRowHeader("Commission"),
              buildRowHeader("Percent"),
              buildRowHeader("Type"),
            ],
            rows: accountList.map((account) {
              index += 1;
              return DataRow(cells: [
                DataCell(DefaultText(
                  "$index",
                  style: TextStyles.bodyTextStyle,
                )),
                DataCell(DefaultText(
                  account.name,
                  style: TextStyles.bodyTextStyle,
                )),
                DataCell(DefaultText(
                  account.commission.toString(),
                  style: TextStyles.bodyTextStyle,
                )),
                DataCell(DefaultText(
                  account.percent.toString(),
                  style: TextStyles.bodyTextStyle,
                )),
                DataCell(DefaultText(
                  account.type,
                  style: TextStyles.bodyTextStyle,
                )),
              ]);
            }).toList()));
  }
}
