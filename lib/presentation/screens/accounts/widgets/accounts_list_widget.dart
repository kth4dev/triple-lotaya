import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/styles/dialogs/confirm_dialog.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/model/user.dart';

class AccountListWidget extends StatefulWidget {
  final Stream<QuerySnapshot> accountsStream;
  const AccountListWidget({Key? key,required this.accountsStream}) : super(key: key);

  @override
  State<AccountListWidget> createState() => _AccountListWidgetState();
}

class _AccountListWidgetState extends State<AccountListWidget> {


  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: StreamBuilder<QuerySnapshot>(
          stream: widget.accountsStream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.data!.size == 0) {
              return const DefaultText("No Data", style: TextStyles.bodyTextStyle);
            }
            int index = 0;
            return DataTable(
                headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
                columns: [
                  buildRowHeader("No"),
                  buildRowHeader("Name"),
                  buildRowHeader("Password"),
                  buildRowHeader("Commission"),
                  buildRowHeader("Percent"),
                  buildRowHeader("Type"),
                  buildRowHeader("Refer"),
                  buildRowHeader("Actions"),
                ],
                rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data = document.data()! as Map<String, dynamic?>;
                  Account account = Account.fromJson(data);
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
                      account.password,
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
                    DataCell(DefaultText(
                      (account.referUser==null)?"":"${account.referUser}",
                      style: TextStyles.bodyTextStyle,
                    )),
                    DataCell(
                      Row(
                        children: [
                          if(account.type != "admin")
                              IconButton(
                            icon: const Icon(Icons.edit_rounded),
                            onPressed: () {},
                          ),
                          if(account.type != "admin")
                               IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showConfirmDialog(context:context,title: "Delete Account", content: "Are you sure you want to delete : ${account.name}", onPressedConfirm: (){
                                Navigator.of(context).pop();
                                FirebaseFirestore.instance.collection("users").doc(account.name).delete().catchError((onError){
                                  Toasts.showErrorMessageToast("Failed to Delete : $onError");
                                });
                              });

                            },
                          )
                        ],
                      )),
                  ]);
                }).toList());
          }),
    );
  }


  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }


}
