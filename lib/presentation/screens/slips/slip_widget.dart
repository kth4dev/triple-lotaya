
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/styles/dialogs/info_dialog.dart';
import 'package:lotaya/core/styles/dialogs/loading_dialog.dart';

import '../../../core/styles/dialogs/confirm_dialog.dart';
import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../core/styles/toasts/toasts.dart';
import '../../../core/values/constants.dart';
import '../../../data/collections.dart';
import '../sales/digit.dart';
import '../sales/slip.dart';

class SlipWidget extends StatefulWidget {
  final List<Slip> slips;
  final String accountName, matchId, type, winNumber;

  const SlipWidget({Key? key, required this.slips, required this.accountName, required this.matchId, required this.type, required this.winNumber}) : super(key: key);

  @override
  State<SlipWidget> createState() => _SlipWidgetState();
}

class _SlipWidgetState extends State<SlipWidget> {
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.slips.length,
        itemBuilder: (context, index) {
          List<Digit> digitList = [];
          for (var r in widget.slips[index].receipts) {
            digitList.addAll(r.digitList);
          }
          if (widget.slips[index].totalAmount == 0) {
            return const SizedBox();
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(border: Border.all(color: Colors.black, width: 0.5), borderRadius: BorderRadius.circular(2)),
                  child: ExpansionTile(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        DefaultText(
                          "Slip ${widget.slips[index].id}",
                          style: TextStyles.titleTextStyle,
                        ),
                        DefaultText(
                         formatMoney(widget.slips[index].totalAmount),
                          style: TextStyles.titleTextStyle,
                        ),
                      ],
                    ),
                    children: [
                      buildTable(digitList, widget.slips[index].totalAmount)
                    ],
                  ),
                ),
              ),
              IconButton(
                  onPressed: () {
                    showConfirmDialog(
                        context: context,
                        title: "Delete",
                        content: "Are your sure you want to delete ( Slip ${widget.slips[index].id} )",
                        onPressedConfirm: () async {
                          Navigator.of(context).pop();
                          showLoadingDialog(context: context, title: "Delete Slip ${widget.slips[index].id}", content: "Deleting...");
                          final temp = widget.slips[index];
                          temp.receipts = [];
                          temp.totalAmount = 0;
                          await FirebaseFirestore.instance
                              .collection(Collections.match)
                              .doc(widget.matchId)
                              .collection(widget.type)
                              .doc("${widget.accountName}${widget.slips[index].id}")
                              .set(temp.toJson())
                              .catchError((error) {
                            Toasts.showErrorMessageToast("Faild : $error");
                          }).whenComplete(() {
                            Navigator.of(context).pop();
                            widget.slips.removeAt(index);
                            setState(() {});
                          }).catchError((onError) {
                            Navigator.of(context).pop();
                            showInfoDialog(context: context, title: "Failed", content: "Failed to delete");
                          });
                        });
                  },
                  icon: const Icon(
                    Icons.delete,
                    color: Colors.red,
                  ))
            ],
          );
        });
  }

  Widget buildTable(List<Digit> digitList,int totalAmount) {
    var list = digitList.map((e) {
      return DataRow(color: MaterialStateColor.resolveWith((states) =>(e.value==widget.winNumber)? Colors.green: Color(0xffffffff)), cells: [
        buildRow(value: e.value),
        buildRow(value: formatMoney(e.amount)),
        buildRow(value: getTime(e.createdTime)),
        buildRow(value: e.createUser),
      ]);
    }).toList();
    list.add(
        DataRow(color: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)), cells: [
          buildRow(value: "Total"),
          buildRow(value: formatMoney(totalAmount)),
          buildRow(value: ""),
          buildRow(value: ""),
        ])
    );
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
          headingRowColor: MaterialStateColor.resolveWith((states) => Color(0xfff5f3f3)),
          columns: [
            buildRowHeader("Digit"),
            buildRowHeader("Amount"),
            buildRowHeader("Time"),
            buildRowHeader("User"),
          ],
          rows: list,
    ));
  }

  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }

  DataCell buildRow({required String value}) {
    return DataCell(DefaultText(
      value,
      style: TextStyles.bodyTextStyle,
    ));
  }

  static String getTime(int timeStamp) {
    return DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
  }
}
