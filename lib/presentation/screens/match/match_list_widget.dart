import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/routes/routes.dart';
import 'package:lotaya/core/styles/dialogs/confirm_dialog.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/collections.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/screens/match/add_player_screen.dart';


class MatchListScreen extends StatefulWidget {
  const MatchListScreen({Key? key}) : super(key: key);

  @override
  State<MatchListScreen> createState() => _MatchListScreenState();
}

class _MatchListScreenState extends State<MatchListScreen> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection(Collections.match).orderBy("createdDate", descending: false).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }
              if (snapshot.data!.size == 0) {
                return const DefaultText("No Data", style: TextStyles.bodyTextStyle);
              }
              int index = 0;
              return DataTable(
                  headingRowColor: MaterialStateColor.resolveWith((states) => const Color(0xfff5f3f3)),
                  columns: [
                    buildRowHeader("No"),
                    buildRowHeader("Name"),
                    buildRowHeader("Break Amount"),
                    buildRowHeader("Status"),
                    buildRowHeader("Close"),
                    buildRowHeader("Players"),
                    buildRowHeader("Delete"),
                  ],
                  rows: snapshot.data!.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
                    DigitMatch currentMatch = DigitMatch.fromJson(data);
                    index += 1;
                    return DataRow(cells: [
                      DataCell(DefaultText(
                        "$index",
                        style: TextStyles.bodyTextStyle,
                      )),
                      DataCell(DefaultText(
                        document.id,
                        style: TextStyles.bodyTextStyle,
                      )),
                      DataCell(DefaultText(
                        "${currentMatch.breakAmount}",
                        style: TextStyles.bodyTextStyle,
                      )),
                      DataCell(Checkbox(value: currentMatch.isActive, onChanged: (bool? newValue) {
                        showConfirmDialog(context: context, title: (newValue!)? "Open Match":"Close Match", content: "Are you sure you want to update match", onPressedConfirm: (){
                          Navigator.of(context).pop();
                          showLoadingDialog(context: context, title:  (newValue)? "Open Match":"Close Match", content: "Updating...");
                          currentMatch.isActive=newValue;
                          FirebaseFirestore.instance
                              .collection(Collections.match)
                              .doc(document.id)
                              .set(currentMatch
                              .toJson())
                              .then((value) {
                            Navigator.of(context).pop();
                            Toasts.showErrorMessageToast("Updated Match Successfully");
                          }).catchError((error) {
                            Navigator.of(context).pop();
                            Toasts.showErrorMessageToast("Failed to update Match: $error");
                          });
                        });
                      })),
                      DataCell(DefaultText(
                        DateFormat.Hm().format(DateTime.fromMillisecondsSinceEpoch(currentMatch.closeTime)),
                        style: TextStyles.bodyTextStyle,
                      )),
                      DataCell(IconButton(onPressed: (){
                        goToNextPage(context, AddMemberScreen(digitMatch: currentMatch));
                      }, icon: const Icon(Icons.group))),
                      DataCell(IconButton(onPressed: (){
                        showConfirmDialog(context: context, title: "Delete Match", content: "Are you sure you want to delete", onPressedConfirm: (){
                          Navigator.of(context).pop();
                          showDialog(context: context, builder: (context){
                            TextEditingController masterKeyController=TextEditingController();
                            return AlertDialog(
                             content: Column(
                               mainAxisSize: MainAxisSize.min,
                               children: [
                                 DefaultText("You need master key to delete ${currentMatch.matchId}", style: TextStyles.bodyTextStyle),
                                 10.paddingHeight,
                                 OutLinedTextField(controller: masterKeyController, label: "Master Key", textInputType: TextInputType.text),
                                 PrimaryButton(onPressed: () async{
                                   if(masterKeyController.text=="THA@123"){
                                     showLoadingDialog(context: context, title: "Delete ${currentMatch.matchId}", content: "Deleting...");
                                     QuerySnapshot inSnapshot = await FirebaseFirestore.instance.collection(Collections.match).doc(currentMatch.matchId).collection("in").get();
                                     for (DocumentSnapshot doc in inSnapshot.docs) {
                                       await doc.reference.delete();
                                     }

                                     QuerySnapshot outSnapshot = await FirebaseFirestore.instance.collection(Collections.match).doc(currentMatch.matchId).collection("out").get();
                                     for (DocumentSnapshot doc in outSnapshot.docs) {
                                       await doc.reference.delete();
                                     }

                                     QuerySnapshot messageSnapshot = await FirebaseFirestore.instance.collection(Collections.match).doc(currentMatch.matchId).collection("message").get();
                                     for (DocumentSnapshot doc in messageSnapshot.docs) {
                                       await doc.reference.delete();
                                     }

                                      FirebaseFirestore.instance.collection(Collections.match).doc(currentMatch.matchId).delete().whenComplete((){
                                        Navigator.of(context).pop();// dismiss dialog
                                        Navigator.of(context).pop();// dismiss dialog
                                      }).catchError((onError){
                                        showInfoDialog(context: context, title: "Failed!", content: "Check your internet connection!");
                                      });
                                   }else{
                                     showInfoDialog(context: context, title: "Failed!", content: "wrong master key!");
                                   }
                                 }, label: "Continue")
                               ],
                             ),
                            );
                          });
                        });
                      }, icon: const Icon(Icons.delete,color: Colors.red,))),
                    ]);
                  }).toList());
            }));
  }

  DataColumn buildRowHeader(String label) {
    return DataColumn(
        label: DefaultText(
      label,
      style: TextStyles.bodyTextStyle.copyWith(fontWeight: FontWeight.bold),
    ));
  }


}
