import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/buttons/primary_button.dart';
import 'package:lotaya/data/model/digit_permission.dart';

import '../../../core/styles/dialogs/confirm_dialog.dart';
import '../../../core/styles/dialogs/info_dialog.dart';
import '../../../core/styles/dialogs/loading_dialog.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/collections.dart';
import '../../../data/model/match.dart';
import '../../../data/model/user.dart';

class DigitPermissionListWidget extends StatelessWidget {
  final DigitMatch selectedMatch;

  const DigitPermissionListWidget({Key? key, required this.selectedMatch}) : super(key: key);

  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
        stream: FirebaseFirestore.instance.collection(Collections.match).doc(selectedMatch.matchId).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.exists && snapshot.data!.data() != null) {
            // Access the document data
            int index = 0;
            Map<String, dynamic> data = snapshot.data!.data()!;
            var digitPermission = DigitMatch.fromJson(data).digitPermission;
            selectedMatch.digitPermission = digitPermission;
            return SizedBox(
              height: MediaQuery.of(context).size.height-200,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DataTable(
                      headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
                      columns: [
                        buildRowHeader("No"),
                        buildRowHeader("Name"),
                        buildRowHeader("၁ကွက် ထိုးကြေး"),
                        buildRowHeader("ထိုးကြေး စုစုပေါင်း"),
                        buildRowHeader(""),
                      ],
                      rows: digitPermission.map((DigitPermission digitPermission) {
                        index += 1;
                        return DataRow(cells: [
                          DataCell(DefaultText(
                            "$index",
                            style: TextStyles.bodyTextStyle,
                          )),
                          DataCell(DefaultText(
                            digitPermission.user.toString(),
                            style: TextStyles.bodyTextStyle,
                          )),
                          DataCell(DefaultText(
                            digitPermission.digitPermission.toString(),
                            style: TextStyles.bodyTextStyle,
                          )),
                          DataCell(DefaultText(
                            digitPermission.totalPermission.toString(),
                            style: TextStyles.bodyTextStyle,
                          )),
                          DataCell(IconButton(
                            icon: const Icon(
                              Icons.delete_forever,
                              color: Colors.red,
                            ),
                            onPressed: () {
                              showConfirmDialog(
                                  context: context,
                                  title: "Digit Permission",
                                  content: "Are you sure you want to delete",
                                  onPressedConfirm: () {
                                    Navigator.of(context).pop();
                                    selectedMatch.digitPermission.remove(digitPermission);
                                    updateMatches(context);
                                  });
                            },
                          )),
                        ]);
                      }).toList()),
                  DefaultButton(onPressed: () {
                    showConfirmDialog(
                        context: context,
                        title: "Delete All Permission",
                        content: "Are you sure you want to delete all.",
                        onPressedConfirm: () {
                          Navigator.of(context).pop();
                          selectedMatch.digitPermission=[];
                          updateMatches(context);
                        });
                  }, label: "Delete All"),
                ],
              ),
            );
          }
          return const SizedBox();
        });
  }

  Future<void> updateMatches(BuildContext context) async {
    showLoadingDialog(context: context, title: "Delete Permission", content: "Loading...");
    FirebaseFirestore.instance.collection(Collections.match).doc(selectedMatch.matchId).set(selectedMatch.toJson()).then((value) {
      Navigator.of(context).pop();
    }).catchError((error) {
      showInfoDialog(context: context, title: "Failed", content: "Failed to delete permission");
      Navigator.of(context).pop();
    });
  }
}
