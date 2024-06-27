import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/styles/dialogs/confirm_dialog.dart';
import 'package:lotaya/presentation/screens/slips/slip_widget.dart';

import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../core/styles/toasts/toasts.dart';
import '../../../data/collections.dart';
import '../sales/digit.dart';
import '../sales/slip.dart';

class UserDigitWidget extends StatefulWidget {
  final String accountName,matchId,type,winNumber;
  const UserDigitWidget({Key? key,required this.matchId,required this.type,required this.accountName,required this.winNumber}) : super(key: key);

  @override
  State<UserDigitWidget> createState() => _UserDigitWidgetState();
}

class _UserDigitWidgetState extends State<UserDigitWidget> {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
        future: FirebaseFirestore.instance.collection(Collections.match).doc(widget.matchId).collection(widget.type).where("userName", isEqualTo: widget.accountName).get(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: Padding(
                padding: EdgeInsets.all(8.0),
                child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator()),
              ),
            );
          }

          int sum = 0;
          List<Slip> slips = [];
          snapshot.data!.docs.map((DocumentSnapshot document) {
            Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
            Slip s = Slip.fromJson(data);
            slips.add(s);
            for (var receipt in s.receipts) {
              for (var digit in receipt.digitList) {
                sum += digit.amount;
              }
            }
          }).toList();

          slips.sort((a, b) => a.id.compareTo(b.id));

          return ExpansionTile(
            title: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                DefaultText(
                  widget.accountName,
                  style: TextStyles.titleTextStyle,
                ),
                DefaultText(
                  "$sum",
                  style: TextStyles.titleTextStyle,
                ),
              ],
            ),
            children: [
              SlipWidget(slips: slips, accountName: widget.accountName, matchId: widget.matchId, type: widget.type, winNumber: widget.winNumber)
            ],
          );
        });
  }

  Widget buildRowHeader(String label, Alignment alignment) {
    return Expanded(
      child: Container(
          alignment: alignment,
          color: Colors.blue,
          padding: const EdgeInsets.all(8),
          child: DefaultText(
            label,
            style: TextStyles.subTitleTextStyle.copyWith(fontWeight: FontWeight.bold, color: Colors.white),
          )),
    );
  }

  Widget buildRow(String label, Alignment alignment) {
    return Expanded(
      child: Container(
          alignment: alignment,
          padding: const EdgeInsets.all(8),
          child: DefaultText(
            label,
            style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black),
          )),
    );
  }

  static String getTime(int timeStamp){
    return DateFormat.Hms().format(DateTime.fromMillisecondsSinceEpoch(timeStamp));
  }

}
