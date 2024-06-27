import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/styles/styles.dart';
import 'package:lotaya/data/cache/cache_helper.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/screens/sales/SelectUser.dart';
import 'package:lotaya/presentation/screens/sales/receipt.dart';
import 'package:lotaya/presentation/screens/sales/slip.dart';

import '../../../data/collections.dart';
import '../../bloc/slip_id/slip_id_bloc.dart';
import 'digit.dart';

class SaleMessageScreen extends StatefulWidget {
  final int currentSlip;
  final SelectUser selectedAccount;
  final DigitMatch selectedMatch;

  const SaleMessageScreen({Key? key, required this.currentSlip, required this.selectedAccount, required this.selectedMatch}) : super(key: key);

  @override
  State<SaleMessageScreen> createState() => _SaleMessageScreenState();
}

class _SaleMessageScreenState extends State<SaleMessageScreen> {
  Slip? _selectedSlip;
  late TextEditingController digitController;

  @override
  void initState() {
    super.initState();
    digitController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "Message"),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Container(
                    height: 600,
                    padding: const EdgeInsets.all(8),
                    child: Column(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              border: Border.all(width: 0.5)
                            ),
                            padding: const EdgeInsets.all(10),
                            child: TextFormField(
                              style: TextStyles.textFieldsTextStyle(context),
                              controller: digitController,
                              maxLines: 1000,
                              minLines: 25,
                              decoration: const InputDecoration(
                                border: InputBorder.none,
                              )
                            ),
                          ),
                        ),
                        7.paddingHeight,
                        DefaultButton(onPressed: () {
                          if(digitController.text.isNotEmpty){
                            insertValues();
                          }
                        }, label: "စာရင်းသွင်းရန်")
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                  child: Card(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      height: 600,
                      child: Column(
                children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(child: DefaultText("Slip : ${widget.currentSlip}", style: TextStyles.titleTextStyle)),
                            Expanded(child: Center(child: DefaultText(widget.selectedMatch.matchId, style: TextStyles.titleTextStyle))),
                            Expanded(
                                child: Align(
                                    alignment: Alignment.centerRight,
                                    child: DefaultText("${widget.selectedAccount.userName}[ ${widget.selectedAccount.userType.toUpperCase()} ]", style: TextStyles.titleTextStyle))),
                          ],
                        ),
                      ),
                      5.paddingHeight,
                      _buildReceiptsList,
                      const Divider(),
                      DefaultButton(onPressed: () async{
                        showLoadingDialog(context: context, title: "Save", content: "Loading...");
                        if(_selectedSlip!=null){
                          _selectedSlip!.isSave=true;
                         await FirebaseFirestore.instance
                              .collection(Collections.match)
                              .doc(widget.selectedMatch.matchId)
                              .collection(widget.selectedAccount.userType)
                              .doc("${widget.selectedAccount.userName}${widget.currentSlip}")
                              .set(_selectedSlip!.toJson())
                              .catchError((error) {}).then((value) {
                           Navigator.of(context).pop();
                           Navigator.of(context).pop();
                           BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
                         } );
                        }
                      }, label: "သိမ်းရန်")
                ],
              ),
                    ),
                  )),
            ],
          ),
        ),
      ),
    );
  }

  Widget get _buildReceiptsList => Expanded(
    child: Container(
        alignment: Alignment.center,
        child: StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance
                .collection(Collections.match)
                .doc(widget.selectedMatch.matchId)
                .collection(widget.selectedAccount.userType)
                .doc("${widget.selectedAccount.userName}${widget.currentSlip}")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasData && snapshot.data!.exists && snapshot.data!.data() != null) {
                // Access the document data
                Map<String, dynamic> data = snapshot.data!.data()! as Map<String, dynamic>;
                _selectedSlip = Slip.fromJson(data);
              } else {
                _selectedSlip = null;
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _buildHeader,
                  if (_selectedSlip != null) _buildRows,
                  if (_selectedSlip != null) DefaultText("Total : ${_selectedSlip?.totalAmount ?? ""}", style: TextStyles.subTitleTextStyle),
                ],
              );
            })),
  );

  Widget get _buildHeader => Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              color: Colors.grey,
              child: DefaultText(
                "Digit",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              color: Colors.grey,
              child: DefaultText(
                "Amount",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              color: Colors.grey,
              child: DefaultText(
                "Type",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              color: Colors.grey,
              child: DefaultText(
                "GP",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              color: Colors.grey,
              child: DefaultText(
                "One",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );

  Widget get _buildRows => Expanded(
        child: ListView.builder(
            itemCount: _selectedSlip!.receipts.length,
            itemBuilder: (context, receiptIndex) {
              return ListView.builder(
                  itemCount: _selectedSlip!.receipts[receiptIndex].digitList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, digitIndex) {
                    return _buildRow(_selectedSlip!.receipts[receiptIndex], digitIndex);
                  });
            }),
      );

  Widget _buildRow(Receipt receipt, int index) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.all(5),
            child: DefaultText(
              receipt.digitList[index].value,
              style: TextStyles.bodyTextStyle.copyWith(color: Colors.black),
            ),
          ),
        ),
        Expanded(
          flex: 3,
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            padding: const EdgeInsets.all(5),
            child: DefaultText(
              "${receipt.digitList[index].amount}",
              style: TextStyles.bodyTextStyle.copyWith(color: Colors.black),
            ),
          ),
        ),
        (index == 0 && receipt.digitList.length > 1)
            ? Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  child: DefaultText(
                    receipt.type,
                    style: TextStyles.bodyTextStyle.copyWith(color: Colors.black),
                  ),
                ),
              )
            : const Expanded(
                flex: 2,
                child: SizedBox(
                  width: 80,
                ),
              ),
        (index == 0 && receipt.digitList.length > 1)
            ? Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  child: InkWell(
                      onTap: () async {
                        if (_selectedSlip != null) {
                          Slip tempSlip = _selectedSlip!;
                          tempSlip.totalAmount -= receipt.totalAmount;
                          tempSlip.receipts.remove(receipt);

                          await FirebaseFirestore.instance
                              .collection(Collections.match)
                              .doc(widget.selectedMatch.matchId)
                              .collection(widget.selectedAccount.userType)
                              .doc("${widget.selectedAccount.userName}${widget.currentSlip}")
                              .set(tempSlip.toJson())
                              .catchError((error) {
                            Toasts.showErrorMessageToast("Faild : $error");
                          });
                        }
                      },
                      child: const Icon(
                        Icons.delete_sweep_outlined,
                        color: Colors.red,
                        size: 20,
                      )),
                ),
              )
            : const Expanded(
                child: SizedBox(),
              ),
        Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 1),
            child: InkWell(
                onTap: () async {
                  if (receipt.digitList.length == 1) {
                    _selectedSlip!.totalAmount -= receipt.totalAmount;
                    _selectedSlip!.receipts.remove(receipt);
                  } else {
                    receipt.totalAmount -= receipt.digitList[index].amount;
                    receipt.digitList.removeAt(index);
                  }
                  await FirebaseFirestore.instance
                      .collection(Collections.match)
                      .doc(widget.selectedMatch.matchId)
                      .collection(widget.selectedAccount.userType)
                      .doc("${widget.selectedAccount.userName}${widget.currentSlip}")
                      .set(_selectedSlip!.toJson())
                      .catchError((error) {
                    Toasts.showErrorMessageToast("Faild : $error");
                  });
                },
                child: const Icon(
                  Icons.delete_forever_outlined,
                  color: Colors.red,
                  size: 20,
                )),
          ),
        ),
      ],
    );
  }

  void insertValues() {
    var lines = digitController.text.split("\n");
    if (lines.isNotEmpty) {
      List<Receipt> digitList = [];
      int totalAmount = 0;
      for (var line in lines) {
        List<String> values = line.split(RegExp(r'\s+'));
        if (values.length == 2) {
          int? digit = int.tryParse(values[0]);
          int? amount = int.tryParse(values[1]);
          if (digit != null && digit < 100 && digit >= 0 && amount != null) {
            String value=digit.toString();
            if(digit<10) {
              value="0$digit";
            }

            totalAmount += amount;
            digitList.add(Receipt(
                type: value,
                digitList: [Digit(amount: amount, value:value, createdTime: DateTime.now().millisecondsSinceEpoch, createUser: CacheHelper.getAccountInfo().name)],
                totalAmount: amount));
          }
        }
      }
      FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(widget.selectedMatch.matchId)
          .collection(widget.selectedAccount.userType)
          .doc("${widget.selectedAccount.userName}${widget.currentSlip}")
          .set(Slip(totalAmount: totalAmount, receipts: digitList, userName: widget.selectedAccount.userName, id: widget.currentSlip, isSave: false).toJson())
          .catchError((error) {});
      digitController.text="";
    }
  }
}
