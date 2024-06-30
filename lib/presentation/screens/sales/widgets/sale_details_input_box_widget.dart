import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/routes/routes.dart';
import 'package:lotaya/core/styles/dialogs/error_dialog.dart';
import 'package:lotaya/core/utils/digit_utils.dart';
import 'package:lotaya/core/values/constants.dart';
import 'package:lotaya/data/model/digit_permission.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/data/model/message.dart';
import 'package:lotaya/presentation/bloc/receipt/receipt_list_bloc.dart';
import 'package:lotaya/presentation/bloc/slip_id/slip_id_bloc.dart';
import 'package:lotaya/presentation/screens/sales/SelectUser.dart';
import 'package:lotaya/presentation/screens/sales/sale_message_screen.dart';
import 'package:oktoast/oktoast.dart';

import '../../../../core/styles/buttons/primary_button.dart';
import '../../../../core/styles/dialogs/loading_dialog.dart';
import '../../../../core/styles/dropdowns/under_line_drop_down_button.dart';
import '../../../../core/styles/textstyles/default_text.dart';
import '../../../../core/styles/textstyles/textstyles.dart';
import '../../../../core/styles/toasts/toasts.dart';
import '../../../../core/values/sizes.dart';
import '../../../../data/cache/cache_helper.dart';
import '../../../../data/collections.dart';
import '../../../../data/model/user.dart';
import '../digit.dart';
import '../receipt.dart';
import '../slip.dart';

class SaleDetailsInputBoxWidget extends StatefulWidget {
  final SelectUser selectUser;
  final DigitMatch match;

  const SaleDetailsInputBoxWidget(
      {Key? key, required this.selectUser, required this.match})
      : super(key: key);

  @override
  State<SaleDetailsInputBoxWidget> createState() =>
      _SaleDetailsInputBoxWidgetState();
}

class _SaleDetailsInputBoxWidgetState extends State<SaleDetailsInputBoxWidget> {
  late TextEditingController digitController;
  late TextEditingController amountController;
  late TextEditingController rAmountController;
  late TextEditingController currentSlipController;
  late TextEditingController lastSlipController, userTotalAmountController;
  final ScrollController _scrollController = ScrollController();
  List<String> userTypes = ["in", "out"];
  Slip? _selectedSlip;

  void _scrollDown() {
    _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
  }

  @override
  void initState() {
    super.initState();
    digitController = TextEditingController();
    amountController = TextEditingController();
    rAmountController = TextEditingController();
    currentSlipController = TextEditingController();
    lastSlipController = TextEditingController();
    userTotalAmountController = TextEditingController();
  }

  @override
  void dispose() {
    super.dispose();
    rAmountController.dispose();
    digitController.dispose();
    amountController.dispose();
    currentSlipController.dispose();
    lastSlipController.dispose();
    userTotalAmountController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.of(context).size.width > 1100) {
      return Row(
        children: [
          const Expanded(child: SizedBox()),
          Expanded(
              flex: 2,
              child:
                  Card(child: SizedBox(height: 670, child: _buildInputView))),
          Expanded(
              child: (CacheHelper.getAccountInfo().type == "admin")
                  ? Card(child: SizedBox(height: 670, child: _buildOverNumber))
                  : 0.paddingHeight),
        ],
      );
    } else {
      if (CacheHelper.getAccountInfo().type == "admin") {
        return Column(
          children: [
            Card(child: SizedBox(height: 670, child: _buildInputView)),
            Card(child: SizedBox(height: 670, child: _buildOverNumber)),
          ],
        );
      } else {
        return SizedBox(
            height: MediaQuery.of(context).size.height - 120,
            child: _buildInputView);
      }
    }
  }

  Widget get _buildOverNumber => StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(widget.match.matchId)
          .collection("out")
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return DefaultText("No Internet Connection",
              style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: SizedBox(
                  width: 50, height: 50, child: CircularProgressIndicator()));
        }

        List<int> outDigits = List.generate(1000, (index) => 0);
        snapshot.data!.docs.map((DocumentSnapshot document) {
          Map<String, dynamic> data = document.data()! as Map<String, dynamic>;
          Slip s = Slip.fromJson(data);
          for (var receipt in s.receipts) {
            for (var digit in receipt.digitList) {
              outDigits[int.parse(digit.value)] =
                  outDigits[int.parse(digit.value)] + digit.amount;
            }
          }
        }).toList();

        return StreamBuilder(
            stream: FirebaseFirestore.instance
                .collection(Collections.match)
                .doc(widget.match.matchId)
                .collection("in")
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return DefaultText("No Internet Connection",
                    style: TextStyles.bodyTextStyle
                        .copyWith(color: Colors.orange));
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(
                    child: SizedBox(
                        width: 50,
                        height: 50,
                        child: CircularProgressIndicator()));
              }

              List<int> inDigits = List.generate(1000, (index) => 0);
              snapshot.data!.docs.map((DocumentSnapshot document) {
                Map<String, dynamic> data =
                    document.data()! as Map<String, dynamic>;
                Slip s = Slip.fromJson(data);
                for (var receipt in s.receipts) {
                  for (var digit in receipt.digitList) {
                    inDigits[int.parse(digit.value)] =
                        inDigits[int.parse(digit.value)] + digit.amount;
                  }
                }
              }).toList();

              List<Digit> overDigitList = []; // just use value and amount
              int totalOverAmount = 0;

              for (int i = 0; i < 1000; i++) {
                int value = inDigits[i] - outDigits[i];
                if (value > widget.match.breakAmount) {
                  totalOverAmount += value - widget.match.breakAmount;
                  overDigitList.add(Digit(
                      amount: value - widget.match.breakAmount,
                      value: (i < 10) ? "00$i" : (i<100)? "0$i":"$i",
                      createdTime: 0,
                      createUser: ""));
                }
              }

              overDigitList.sort((a, b) => b.amount.compareTo(a.amount));

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            padding: const EdgeInsets.all(5),
                            child: DefaultText(
                              "Digit",
                              style: TextStyles.bodyTextStyle.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 1),
                            padding: const EdgeInsets.all(5),
                            child: DefaultText(
                              "Amount",
                              style: TextStyles.bodyTextStyle.copyWith(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                              align: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const Divider(),
                    Expanded(
                      child: ListView.builder(
                          itemCount: overDigitList.length,
                          itemBuilder: (context, index) {
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        padding: const EdgeInsets.all(5),
                                        child: DefaultText(
                                          overDigitList[index].value,
                                          style: TextStyles.bodyTextStyle
                                              .copyWith(color: Colors.black),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                            horizontal: 1),
                                        padding: const EdgeInsets.all(5),
                                        child: DefaultText(
                                          formatMoney(overDigitList[index].amount),
                                          style: TextStyles.bodyTextStyle
                                              .copyWith(color: Colors.black),
                                          align: TextAlign.right,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Container(height: 0.3,width: double.maxFinite,color: Colors.grey,)
                              ],
                            );
                          }),
                    ),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        DefaultText("${overDigitList.length} - ",
                            style: TextStyles.subTitleTextStyle
                                .copyWith(color: Colors.black)),
                        Center(
                            child: DefaultText(
                                "Over-Max  ${totalOverAmount.toString()}",
                                style: TextStyles.subTitleTextStyle
                                    .copyWith(color: Colors.red))),
                      ],
                    ),
                    const Divider(),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 100,
                            child: DefaultButton(
                                onPressed: () {
                                  String result = "";
                                  for (var i in overDigitList) {
                                    result += "${i.value}  ${i.amount}\n";
                                  }
                                  Clipboard.setData(
                                      ClipboardData(text: result));
                                },
                                label: "Copy"),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 100,
                            child: DefaultButton(
                                onPressed: () {
                                  goToNextPage(
                                      context,
                                      SaleMessageScreen(
                                          currentSlip: int.parse(
                                              currentSlipController.text),
                                          selectedAccount: widget.selectUser,
                                          selectedMatch: widget.match));
                                },
                                label: "Message"),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            });
      });

  Widget get _buildInputView => Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            _buildSelectUserView,
            _buildHotNumbers,
            _buildReceiptsList,
            _buildCurrentSlip,
            _buildInputBox,
            _buildSaveButton
          ],
        ),
      );

  void showCloseMatch() {
    showErrorDialog(
        context: context, title: "Close", content: "This Match is closed");
  }

  Widget get _buildHotNumbers => StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(widget.match.matchId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData &&
            snapshot.data!.exists &&
            snapshot.data!.data() != null) {
          // Access the document data
          Map<String, dynamic> data = snapshot.data!.data()!;
          DigitMatch updatedMatch = DigitMatch.fromJson(data);
          if (!updatedMatch.isActive) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              showCloseMatch();
            });
          }
          widget.match.isActive = updatedMatch.isActive;
          widget.match.hotNumbers = updatedMatch.hotNumbers;
          return Row(
            children: [
              8.paddingWidth,
              DefaultText("Hot :",
                  style: TextStyles.bodyTextStyle.copyWith(
                      color: Colors.red, fontWeight: FontWeight.bold)),
              Wrap(
                children: widget.match.hotNumbers
                        ?.map((e) => Card(
                              color: Colors.red,
                              child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: DefaultText(e.toString(),
                                    style: TextStyles.bodyTextStyle
                                        .copyWith(color: Colors.white)),
                              ),
                            ))
                        .toList() ??
                    [],
              ),
            ],
          );
        }
        return const SizedBox();
      });

  Widget get _buildReceiptsList => Expanded(
        child: BlocBuilder<ReceiptListBloc, ReceiptListState>(
          builder: (context, state) {
            return StreamBuilder<DocumentSnapshot>(
                stream: FirebaseFirestore.instance
                    .collection(Collections.match)
                    .doc(widget.match.matchId)
                    .collection(widget.selectUser.userType)
                    .doc(
                        "${widget.selectUser.userName}${currentSlipController.text}")
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasData &&
                      snapshot.data!.exists &&
                      snapshot.data!.data() != null) {
                    // Access the document data
                    Map<String, dynamic> data =
                        snapshot.data!.data()! as Map<String, dynamic>;
                    _selectedSlip = Slip.fromJson(data);
                  } else {
                    _selectedSlip = null;
                  }
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      _buildHeader,
                      if (_selectedSlip != null) _buildRows,
                      if (_selectedSlip != null) _buildReceiptTotalAmount,
                    ],
                  );
                });
          },
        ),
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
                "SG",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.white),
              ),
            ),
          ),
        ],
      );

  Widget get _buildRows => Expanded(
        child: ListView.builder(
            controller: _scrollController,
            itemCount: _selectedSlip!.receipts.length,
            itemBuilder: (context, receiptIndex) {
              return ListView.builder(
                  itemCount:
                      _selectedSlip!.receipts[receiptIndex].digitList.length,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, digitIndex) {
                    return _buildRow(
                        _selectedSlip!.receipts[receiptIndex], digitIndex);
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
        (index == 0)
            ? Expanded(
                flex: 2,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  padding: const EdgeInsets.all(5),
                  width: 80,
                  child: DefaultText(
                    receipt.type,
                    style:
                        TextStyles.bodyTextStyle.copyWith(color: Colors.black),
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
                        _selectedSlip!.totalAmount -= receipt.totalAmount;
                        _selectedSlip!.receipts.remove(receipt);

                        int? currentSlipId =
                            int.tryParse(currentSlipController.text);
                        if (currentSlipId != null) {
                          await FirebaseFirestore.instance
                              .collection(Collections.match)
                              .doc(widget.match.date)
                              .collection(widget.selectUser.userType)
                              .doc(
                                  "${widget.selectUser.userName}${currentSlipController.text}")
                              .set(_selectedSlip!.toJson())
                              .catchError((error) {
                            Toasts.showErrorMessageToast("Faild : $error");
                            currentSlipController.text =
                                currentSlipId.toString();
                            BlocProvider.of<ReceiptListBloc>(context)
                                .add(ChangeReceiptListEvent());
                          }).whenComplete(() {
                            if (int.parse(lastSlipController.text) + 1 ==
                                int.parse(currentSlipController.text)) {
                              BlocProvider.of<SlipIdBloc>(context)
                                  .add(RefreshSlipIdEvent());
                            }

                            if (DateTime.now().millisecondsSinceEpoch >
                                widget.match.closeTime) {
                              showNoticeToast(message: "Over Time");
                            }

                            FirebaseFirestore.instance
                                .collection(Collections.match)
                                .doc(widget.match.date)
                                .collection(Collections.message)
                                .add(Message(
                                        title: overTimeDeleteMessage,
                                        content:
                                            "${CacheHelper.getAccountInfo().name} --> [${receipt.type}]  ${widget.selectUser.userName}(slip ${currentSlipController.text})",
                                        matchId: widget.match.matchId,
                                        slipId:
                                            "${widget.selectUser.userName}${currentSlipController.text}",
                                        slipUserId: widget.selectUser.userName,
                                        updatedUserId:
                                            CacheHelper.getAccountInfo().name,
                                        createdTimed: DateTime.now()
                                            .millisecondsSinceEpoch)
                                    .toJson());
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
                    _selectedSlip!.totalAmount -=
                        receipt.digitList[index].amount;
                    receipt.totalAmount -= receipt.digitList[index].amount;
                    receipt.digitList.removeAt(index);
                  }
                  int? currentSlipId = int.tryParse(currentSlipController.text);
                  if (currentSlipId != null) {
                    await FirebaseFirestore.instance
                        .collection(Collections.match)
                        .doc(widget.match.date)
                        .collection(widget.selectUser.userType)
                        .doc(
                            "${widget.selectUser.userName}${currentSlipController.text}")
                        .set(_selectedSlip!.toJson())
                        .catchError((error) {
                      Toasts.showErrorMessageToast("Failed : $error");
                      currentSlipController.text = currentSlipId.toString();
                      BlocProvider.of<ReceiptListBloc>(context)
                          .add(ChangeReceiptListEvent());
                    }).whenComplete(() {
                      if (int.parse(lastSlipController.text) + 1 ==
                          int.parse(currentSlipController.text)) {
                        BlocProvider.of<SlipIdBloc>(context)
                            .add(RefreshSlipIdEvent());
                      }
                      if (DateTime.now().millisecondsSinceEpoch >
                          widget.match.closeTime) {
                        showNoticeToast(message: "Over Time");
                      }
                      FirebaseFirestore.instance
                          .collection(Collections.match)
                          .doc(widget.match.date)
                          .collection(Collections.message)
                          .add(Message(
                                  title: overTimeDeleteMessage,
                                  content:
                                      "${CacheHelper.getAccountInfo().name} deleted [${receipt.digitList[index].value}]  ${widget.selectUser.userName}( slip ${currentSlipController.text} )",
                                  matchId: widget.match.matchId,
                                  slipId:
                                      "${widget.selectUser.userName}${currentSlipController.text}",
                                  slipUserId: widget.selectUser.userName,
                                  updatedUserId:
                                      CacheHelper.getAccountInfo().name,
                                  createdTimed:
                                      DateTime.now().millisecondsSinceEpoch)
                              .toJson());
                    });
                  }
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

  void showNoticeToast({required String message}) {
    showToast(message, position: ToastPosition.top);
  }

  void showHotNoticeToast({required String message}) {
    showToast(message, position: ToastPosition.center);
  }

  void showPermissionNoticeToast({required String message}) {
    showToast(message, position: ToastPosition.bottom);
  }

  Widget get _buildReceiptTotalAmount => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Expanded(
            flex: 2,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              child: DefaultText(
                "Total",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.black),
              ),
            ),
          ),
          Expanded(
            flex: 7,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 1),
              padding: const EdgeInsets.all(5),
              child: DefaultText(
                "${getCurrentSlipTotalAmount()}",
                style: TextStyles.bodyTextStyle.copyWith(color: Colors.black),
              ),
            ),
          ),
        ],
      );

  Widget get _buildInputBox => Container(
        margin: const EdgeInsets.only(top: formFieldsPaddingTopSize),
        height: 45,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
                child: TextFormField(
              style: TextStyles.textFieldsTextStyle(context),
              textInputAction: TextInputAction.next,
              controller: digitController,
              keyboardType: TextInputType.phone,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(),
                hintText: "Digits",
              ),
            )),
            10.paddingWidth,
            Expanded(
                child: TextFormField(
              onFieldSubmitted: (value) {
                if (digitController.text.isNotEmpty &&
                    amountController.text.isNotEmpty) {
                  if (widget.match.isActive) {
                    insertValues();
                  }
                }
              },
              style: TextStyles.textFieldsTextStyle(context),
              textInputAction: TextInputAction.previous,
              controller: amountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(),
                hintText: "Amount",
              ),
            )),
            10.paddingWidth,
            Expanded(
                child: TextFormField(
              onFieldSubmitted: (value) {
                if (widget.match.isActive) {
                  insertRValues();
                }
              },
              style: TextStyles.textFieldsTextStyle(context),
              textInputAction: TextInputAction.done,
              controller: rAmountController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                  border: OutlineInputBorder(),
                  hintText: "R",
                  labelText: "R"),
            )),
          ],
        ),
      );

  Widget get _buildSaveButton => SizedBox(
        width: 100,
        child: DefaultButton(
            onPressed: () {
              if (_selectedSlip != null && _selectedSlip!.receipts.isNotEmpty) {
                uploadSlip();
              } else {
                Toasts.showErrorMessageToast("Please Fill Completely");
              }
            },
            label: "Save"),
      );

  int getCurrentSlipTotalAmount() {
    int result = 0;
    for (var r in _selectedSlip!.receipts) {
      result += r.totalAmount;
    }
    return result;
  }

  void insertValues() {
    String inputs = digitController.text.toString();
    List<Receipt> currentReceipts = [];

    if (inputs == "**") {
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var f = 0; f < 10; f++) {
        totalAmount += int.parse(amountController.text);
        digitList.add(Digit(
            amount: int.parse(amountController.text),
            value: "$f$f$f",
            createdTime: DateTime.now().millisecondsSinceEpoch,
            createUser: CacheHelper.getAccountInfo().name));
      }
      Receipt receipt =
      Receipt(type: "**", digitList: digitList, totalAmount: totalAmount);
      currentReceipts.add(receipt);
    }  else if (inputs.endsWith("+")) {
      var digitList = digitController.text.replaceAll("+", "").split(".");
      for (var digit in digitList) {
        final d = DigitUtils.convertToListOfDigits(digit);
        final rValues = DigitUtils.generateRValues(d);
        int? value = int.tryParse(digit);
        if (value != null && value < 1000 && value >= 0) {
          Receipt receipt = Receipt(
              type: "$digit+",
              digitList: rValues.map((value)=>  Digit(
                  amount: int.parse(amountController.text),
                  value: value,
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                  createUser: CacheHelper.getAccountInfo().name)).toList(),
              totalAmount: int.parse(amountController.text) * rValues.length);
          currentReceipts.add(receipt);
        }
      }
    } else {
      var digitList = digitController.text.split(".");
      for (var digit in digitList) {
        int? value = int.tryParse(digit);
        if (digit.length == 3 && value != null && value < 1000 && value >= 0) {
          Receipt receipt = Receipt(
              type: digit,
              digitList: [
                Digit(
                    amount: int.parse(amountController.text),
                    value: digit,
                    createdTime: DateTime.now().millisecondsSinceEpoch,
                    createUser: CacheHelper.getAccountInfo().name),
              ],
              totalAmount: int.parse(amountController.text));
          currentReceipts.add(receipt);
        }
      }
    }

    //contain formula
   /* if (inputs == "-") {
      final nk = ["07", "18", "24", "35", "42", "53", "69", "70", "81", "96"];
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var digit in nk) {
        digitList.add(Digit(
            amount: int.parse(amountController.text),
            value: digit,
            createdTime: DateTime.now().millisecondsSinceEpoch,
            createUser: CacheHelper.getAccountInfo().name));
        totalAmount += int.parse(amountController.text);
      }
      if (digitList.isNotEmpty) {
        Receipt receipt =
            Receipt(type: "-", digitList: digitList, totalAmount: totalAmount);
        currentReceipts.add(receipt);
      }
    } else if (inputs == "*") {
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var f = 0; f < 10; f++) {
        int power = f + 5;
        int s = (power < 10) ? power : (power - 10);
        digitList.add(Digit(
            amount: int.parse(amountController.text),
            value: "$f$s",
            createdTime: DateTime.now().millisecondsSinceEpoch,
            createUser: CacheHelper.getAccountInfo().name));
        totalAmount += int.parse(amountController.text);
      }
      if (digitList.isNotEmpty) {
        Receipt receipt =
            Receipt(type: "*", digitList: digitList, totalAmount: totalAmount);
        currentReceipts.add(receipt);
      }
    } else if (inputs == "**") {
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var f = 0; f < 10; f++) {
        totalAmount += int.parse(amountController.text);
        digitList.add(Digit(
            amount: int.parse(amountController.text),
            value: "$f$f$f",
            createdTime: DateTime.now().millisecondsSinceEpoch,
            createUser: CacheHelper.getAccountInfo().name));
      }
      Receipt receipt =
          Receipt(type: "**", digitList: digitList, totalAmount: totalAmount);
      currentReceipts.add(receipt);
    } else if (inputs.endsWith("-+")) {
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var f = 0; f < 10; f++) {
        if (f % 2 != 0) {
          for (var s = 0; s < 10; s++) {
            if (s % 2 == 0) {
              totalAmount += int.parse(amountController.text);
              digitList.add(Digit(
                  amount: int.parse(amountController.text),
                  value: "$f$s",
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                  createUser: CacheHelper.getAccountInfo().name));
            }
          }
        }
      }
      if (digitList.isNotEmpty) {
        Receipt receipt =
            Receipt(type: "-+", digitList: digitList, totalAmount: totalAmount);
        currentReceipts.add(receipt);
      }
    } else if (inputs.endsWith("+-")) {
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (var f = 0; f < 10; f++) {
        if (f % 2 == 0) {
          for (var s = 0; s < 10; s++) {
            if (s % 2 != 0) {
              totalAmount += int.parse(amountController.text);
              digitList.add(Digit(
                  amount: int.parse(amountController.text),
                  value: "$f$s",
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                  createUser: CacheHelper.getAccountInfo().name));
            }
          }
        }
      }
      if (digitList.isNotEmpty) {
        Receipt receipt =
            Receipt(type: "+-", digitList: digitList, totalAmount: totalAmount);
        currentReceipts.add(receipt);
      }
    } else if (inputs.endsWith("-")) {
      int? roundNumber = int.tryParse(digitController.text.replaceAll("-", ""));
      if (roundNumber != null) {
        List<Digit> digitList = [];
        int totalAmount = 0;
        for (var f = 0; f < 10; f++) {
          totalAmount += int.parse(amountController.text);
          digitList.add(Digit(
              amount: int.parse(amountController.text),
              value: "$f$roundNumber",
              createdTime: DateTime.now().millisecondsSinceEpoch,
              createUser: CacheHelper.getAccountInfo().name));
          if (f != roundNumber) {
            totalAmount += int.parse(amountController.text);
            digitList.add(Digit(
                amount: int.parse(amountController.text),
                value: "$roundNumber$f",
                createdTime: DateTime.now().millisecondsSinceEpoch,
                createUser: CacheHelper.getAccountInfo().name));
          }
        }
        if (digitList.isNotEmpty) {
          Receipt receipt = Receipt(
              type: "$roundNumber-",
              digitList: digitList,
              totalAmount: totalAmount);
          currentReceipts.add(receipt);
        }
      }
    } else if (inputs.endsWith("*")) {
      int? firstNumber = int.tryParse(digitController.text.replaceAll("*", ""));
      if (firstNumber != null) {
        List<Digit> digitList = [];
        int totalAmount = 0;
        for (var s = 0; s < 10; s++) {
          totalAmount += int.parse(amountController.text);
          digitList.add(Digit(
              amount: int.parse(amountController.text),
              value: "$firstNumber$s",
              createdTime: DateTime.now().millisecondsSinceEpoch,
              createUser: CacheHelper.getAccountInfo().name));
        }
        if (digitList.isNotEmpty) {
          Receipt receipt = Receipt(
              type: "$firstNumber*",
              digitList: digitList,
              totalAmount: totalAmount);
          currentReceipts.add(receipt);
        }
      }
    } else if (inputs.startsWith("*")) {
      int? secondNumber =
          int.tryParse(digitController.text.replaceAll("*", ""));
      if (secondNumber != null) {
        List<Digit> digitList = [];
        int totalAmount = 0;
        for (var f = 0; f < 10; f++) {
          totalAmount += int.parse(amountController.text);
          digitList.add(Digit(
              amount: int.parse(amountController.text),
              value: "$f$secondNumber",
              createdTime: DateTime.now().millisecondsSinceEpoch,
              createUser: CacheHelper.getAccountInfo().name));
        }
        if (digitList.isNotEmpty) {
          Receipt receipt = Receipt(
              type: "*$secondNumber",
              digitList: digitList,
              totalAmount: totalAmount);
          currentReceipts.add(receipt);
        }
      }
    } else if (inputs.endsWith("+")) {
      var digitList = digitController.text.replaceAll("+", "").split(".");
      for (var digit in digitList) {
        int? value = int.tryParse(digit);
        if (value != null && value < 100 && value >= 0) {
          Receipt receipt = Receipt(
              type: "$digit+",
              digitList: [
                Digit(
                    amount: int.parse(amountController.text) ~/ 2,
                    value: digit,
                    createdTime: DateTime.now().millisecondsSinceEpoch,
                    createUser: CacheHelper.getAccountInfo().name),
                Digit(
                    amount: int.parse(amountController.text) ~/ 2,
                    value: reverseString(digit),
                    createdTime: DateTime.now().millisecondsSinceEpoch,
                    createUser: CacheHelper.getAccountInfo().name),
              ],
              totalAmount: int.parse(amountController.text));
          currentReceipts.add(receipt);
        }
      }
    } else if (inputs.endsWith("/")) {
      int? breakNumber = int.tryParse(digitController.text.replaceAll("/", ""));
      if (breakNumber != null) {
        List<Digit> digitList = [];
        int totalAmount = 0;
        for (var f = 0; f < 10; f++) {
          for (var s = 0; s < 10; s++) {
            if ((f + s) == breakNumber ||
                (f + s).toString().endsWith(breakNumber.toString())) {
              totalAmount += int.parse(amountController.text);
              digitList.add(Digit(
                  amount: int.parse(amountController.text),
                  value: "$f$s",
                  createdTime: DateTime.now().millisecondsSinceEpoch,
                  createUser: CacheHelper.getAccountInfo().name));
            }
          }
        }
        if (digitList.isNotEmpty) {
          Receipt receipt = Receipt(
              type: "$breakNumber/",
              digitList: digitList,
              totalAmount: totalAmount);
          currentReceipts.add(receipt);
        }
      }
    } else {
      var digitList = digitController.text.split(".");
      for (var digit in digitList) {
        int? value = int.tryParse(digit);
        if (value != null && value < 100 && value >= 0) {
          Receipt receipt = Receipt(
              type: digit,
              digitList: [
                Digit(
                    amount: int.parse(amountController.text),
                    value: digit,
                    createdTime: DateTime.now().millisecondsSinceEpoch,
                    createUser: CacheHelper.getAccountInfo().name),
              ],
              totalAmount: int.parse(amountController.text));
          currentReceipts.add(receipt);
        }
      }
    }*/

    int? currentSlip = int.tryParse(currentSlipController.text);
    int tempTotal = int.tryParse(userTotalAmountController.text) ?? 0;
    List<int> userDigitAmounts = selectUserDigitAmounts;

    if (currentSlip != null && currentReceipts.isNotEmpty) {
      if (_selectedSlip == null) {
        //new slip
        int tAmount = 0;
        for (var r in currentReceipts) {
          tAmount += r.totalAmount;
        }
        FirebaseFirestore.instance
            .collection(Collections.match)
            .doc(widget.match.date)
            .collection(widget.selectUser.userType)
            .doc("${widget.selectUser.userName}$currentSlip")
            .set(Slip(
                    totalAmount: tAmount,
                    receipts: currentReceipts,
                    userName: widget.selectUser.userName,
                    id: currentSlip,
                    isSave: false)
                .toJson())
            .catchError((error) {})
            .whenComplete(() {
          checkDigitPermission(currentReceipts, userDigitAmounts, tempTotal);
          if (DateTime.now().millisecondsSinceEpoch > widget.match.closeTime) {
            showNoticeToast(message: "Over Time");
            FirebaseFirestore.instance
                .collection(Collections.match)
                .doc(widget.match.date)
                .collection(Collections.message)
                .add(Message(
                        title: overTimeInsertMessage,
                        content:
                            "${CacheHelper.getAccountInfo().name} -->  ${widget.selectUser.userName}(slip $currentSlip)",
                        matchId: widget.match.matchId,
                        slipId: "${widget.selectUser.userName}$currentSlip",
                        slipUserId: widget.selectUser.userName,
                        updatedUserId: CacheHelper.getAccountInfo().name,
                        createdTimed: DateTime.now().millisecondsSinceEpoch)
                    .toJson());
          }
        });
      } else {
        int tAmount = 0;
        int tempTotal = int.tryParse(userTotalAmountController.text) ?? 0;
        List<int> userDigitAmounts = selectUserDigitAmounts;
        for (var r in currentReceipts) {
          tAmount += r.totalAmount;
        }
        _selectedSlip!.totalAmount += tAmount;
        _selectedSlip!.receipts.addAll(currentReceipts);

        FirebaseFirestore.instance
            .collection(Collections.match)
            .doc(widget.match.date)
            .collection(widget.selectUser.userType)
            .doc("${widget.selectUser.userName}$currentSlip")
            .set(_selectedSlip!.toJson())
            .catchError((error) {
          Toasts.showErrorMessageToast("Faild : $error");
        }).whenComplete(() {
          checkDigitPermission(currentReceipts, userDigitAmounts, tempTotal);
          if (DateTime.now().millisecondsSinceEpoch > widget.match.closeTime) {
            showNoticeToast(message: "Over Time");
            FirebaseFirestore.instance
                .collection(Collections.match)
                .doc(widget.match.date)
                .collection(Collections.message)
                .add(Message(
                        title: overTimeInsertMessage,
                        content:
                            "${CacheHelper.getAccountInfo().name} --> ${widget.selectUser.userName} (slip $currentSlip)",
                        matchId: widget.match.matchId,
                        slipId: "${widget.selectUser.userName}$currentSlip",
                        slipUserId: widget.selectUser.userName,
                        updatedUserId: CacheHelper.getAccountInfo().name,
                        createdTimed: DateTime.now().millisecondsSinceEpoch)
                    .toJson());
          }
        });
        if (int.parse(lastSlipController.text) + 1 ==
            int.parse(currentSlipController.text)) {
          BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
        }
      }
      digitController.text = "";
      amountController.text = "";
    }
  }

  String reverseString(String input) {
    var chars = input.split('');
    var reversedChars = chars.reversed;
    var reversedString = reversedChars.join('');
    return reversedString;
  }

  void checkDigitPermission(List<Receipt> newReceipt,
      List<int> userDigitsAmounts, int userDigitsTotalAmount) {
    _scrollDown();
    String hotsNumber = "";
    for (var receipt in newReceipt) {
      for (var digit in receipt.digitList) {
        if ((widget.match.hotNumbers ?? [])
            .contains(int.tryParse(digit.value))) {
          if (hotsNumber.isNotEmpty) {
            hotsNumber += ", ";
          }
          hotsNumber += digit.value;
        }
      }
    }

    if (hotsNumber.isNotEmpty) {
      showHotNoticeToast(message: "$addHotNumberMessage  [$hotsNumber]");
      FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(widget.match.date)
          .collection(Collections.message)
          .add(Message(
                  title: "$addHotNumberMessage  [$hotsNumber]",
                  content:
                      "${CacheHelper.getAccountInfo().name}  -->  ${widget.selectUser.userName} (slip ${currentSlipController.text})",
                  matchId: widget.match.matchId,
                  slipId:
                      "${widget.selectUser.userName}${currentSlipController.text}",
                  slipUserId: widget.selectUser.userName,
                  updatedUserId: CacheHelper.getAccountInfo().name,
                  createdTimed: DateTime.now().millisecondsSinceEpoch)
              .toJson());
    }

    //////// Digit Permission ////////////
    int userDigitPermissionIndex = getUserDigitPermission();
    int allDigitPermissionIndex = getAllDigitPermission();
    DigitPermission? digitPermission;
    if (userDigitPermissionIndex != -1) {
      digitPermission = widget.match.digitPermission[userDigitPermissionIndex];
    } else if (allDigitPermissionIndex != -1) {
      digitPermission = widget.match.digitPermission[allDigitPermissionIndex];
    }
    if (digitPermission != null) {
      /////// total /////////
      int tempTotal = 0;
      for (var r in newReceipt) {
        tempTotal += r.totalAmount;
      }
      int allTotal = tempTotal + userDigitsTotalAmount;
      if (allTotal > digitPermission.totalPermission!) {
        showPermissionNoticeToast(
            message: "Over Total [ ${widget.selectUser.userName} ]");
        FirebaseFirestore.instance
            .collection(Collections.match)
            .doc(widget.match.date)
            .collection(Collections.message)
            .add(Message(
                    title: "Over Total [ ${widget.selectUser.userName} ]",
                    content:
                        "${CacheHelper.getAccountInfo().name} make over total amount. Current Total = $allTotal | Permission = [${digitPermission.totalPermission} ] | Over = ${allTotal - digitPermission.totalPermission!}",
                    matchId: widget.match.matchId,
                    slipId:
                        "${widget.selectUser.userName}${currentSlipController.text}",
                    slipUserId: widget.selectUser.userName,
                    updatedUserId: CacheHelper.getAccountInfo().name,
                    createdTimed: DateTime.now().millisecondsSinceEpoch)
                .toJson());
      }
      /////// digit permission //////////
      for (var receipt in newReceipt) {
        for (var digit in receipt.digitList) {
          num tempDigitTotal =
              userDigitsAmounts[int.parse(digit.value)] + digit.amount;
          if (tempDigitTotal > digitPermission.digitPermission!) {
            showPermissionNoticeToast(
                message:
                    "Over - ${digit.value} [ ${widget.selectUser.userName} ]");
            FirebaseFirestore.instance
                .collection(Collections.match)
                .doc(widget.match.date)
                .collection(Collections.message)
                .add(Message(
                        title:
                            "Over - ${digit.value} [ ${widget.selectUser.userName} ]",
                        content:
                            "${CacheHelper.getAccountInfo().name} make over digit amount. Current Total = $tempDigitTotal | Permission = [${digitPermission.digitPermission} ] | Over = ${tempDigitTotal - digitPermission.digitPermission!}",
                        matchId: widget.match.matchId,
                        slipId:
                            "${widget.selectUser.userName}${currentSlipController.text}",
                        slipUserId: widget.selectUser.userName,
                        updatedUserId: CacheHelper.getAccountInfo().name,
                        createdTimed: DateTime.now().millisecondsSinceEpoch)
                    .toJson());
          }
        }
      }
    }
  }

  int getUserDigitPermission() {
    for (int i = 0; i < widget.match.digitPermission.length; i++) {
      if (widget.match.digitPermission[i].user == widget.selectUser.userName) {
        return i;
      }
    }
    return -1;
  }

  int getAllDigitPermission() {
    for (int i = 0; i < widget.match.digitPermission.length; i++) {
      if (widget.match.digitPermission[i].user?.toLowerCase() == "all") {
        return i;
      }
    }
    return -1;
  }

  void insertRValues() {
    String numberStr = digitController.text.toString();
    int? inputs = int.tryParse(numberStr);
    if (inputs != null && inputs < 1000) {
      List<Receipt> currentReceipts = [];
      List<int> digits = DigitUtils.convertToListOfDigits(numberStr);
      List<String> rValues = DigitUtils.generateRValues(digits);
      List<Digit> digitList = [];
      int totalAmount = 0;
      for (int i = 0; i < rValues.length; i++) {
        int amount = int.parse(
            (i == 0) ? amountController.text : rAmountController.text);
        totalAmount += amount;
        digitList.add(Digit(
          amount: amount,
          value: rValues[i],
          createdTime: DateTime.now().millisecondsSinceEpoch,
          createUser: CacheHelper.getAccountInfo().name,
        ));
      }
      currentReceipts.add(Receipt(
        type: "$inputs+",
        digitList: digitList,
        totalAmount: totalAmount,
      ));
      int? currentSlip = int.tryParse(currentSlipController.text);
      if (currentSlip != null && currentReceipts.isNotEmpty) {
        if (_selectedSlip == null) {
          int tAmount = 0;
          int tempTotal = int.tryParse(userTotalAmountController.text) ?? 0;
          List<int> userDigitAmounts = selectUserDigitAmounts;
          for (var r in currentReceipts) {
            tAmount += r.totalAmount;
          }
          FirebaseFirestore.instance
              .collection(Collections.match)
              .doc(widget.match.date)
              .collection(widget.selectUser.userType)
              .doc("${widget.selectUser.userName}$currentSlip")
              .set(Slip(
                      totalAmount: tAmount,
                      receipts: currentReceipts,
                      userName: widget.selectUser.userName,
                      id: currentSlip,
                      isSave: false)
                  .toJson())
              .catchError((error) {})
              .whenComplete(() {
            checkDigitPermission(currentReceipts, userDigitAmounts, tempTotal);
            if (DateTime.now().millisecondsSinceEpoch >
                widget.match.closeTime) {
              showNoticeToast(message: "Over Time");
              FirebaseFirestore.instance
                  .collection(Collections.match)
                  .doc(widget.match.date)
                  .collection(Collections.message)
                  .add(Message(
                          title: overTimeInsertMessage,
                          content:
                              "${CacheHelper.getAccountInfo().name} --> ${widget.selectUser.userName} (slip $currentSlip)]",
                          matchId: widget.match.matchId,
                          slipId: "${widget.selectUser.userName}$currentSlip",
                          slipUserId: widget.selectUser.userName,
                          updatedUserId: CacheHelper.getAccountInfo().name,
                          createdTimed: DateTime.now().millisecondsSinceEpoch)
                      .toJson());
            }
          });
        } else {
          int tAmount = 0;
          int tempTotal = int.tryParse(userTotalAmountController.text) ?? 0;
          List<int> userDigitAmounts = selectUserDigitAmounts;
          for (var r in currentReceipts) {
            tAmount += r.totalAmount;
          }
          _selectedSlip!.totalAmount += tAmount;
          _selectedSlip!.receipts.insertAll(0, currentReceipts);
          FirebaseFirestore.instance
              .collection(Collections.match)
              .doc(widget.match.date)
              .collection(widget.selectUser.userType)
              .doc("${widget.selectUser.userName}$currentSlip")
              .set(_selectedSlip!.toJson())
              .catchError((error) {
            Toasts.showErrorMessageToast("Failed : $error");
          }).whenComplete(() {
            checkDigitPermission(currentReceipts, userDigitAmounts, tempTotal);
            if (DateTime.now().millisecondsSinceEpoch >
                widget.match.closeTime) {
              showNoticeToast(message: "Over Time");
              FirebaseFirestore.instance
                  .collection(Collections.match)
                  .doc(widget.match.date)
                  .collection(Collections.message)
                  .add(Message(
                          title: overTimeInsertMessage,
                          content:
                              "${CacheHelper.getAccountInfo().name} --> ${widget.selectUser.userName} (slip $currentSlip)",
                          matchId: widget.match.matchId,
                          slipId: "${widget.selectUser.userName}$currentSlip",
                          slipUserId: widget.selectUser.userName,
                          updatedUserId: CacheHelper.getAccountInfo().name,
                          createdTimed: DateTime.now().millisecondsSinceEpoch)
                      .toJson());
            }
          });
        }
        digitController.text = "";
        amountController.text = "";
        rAmountController.text = "";
      }
    }
  }

  void uploadSlip() {
    int? currentSlip = int.tryParse(currentSlipController.text);
    if (currentSlip != null && _selectedSlip != null) {
      showLoadingDialog(
          context: context, title: widget.match.date, content: "saving...");
      FirebaseFirestore.instance
          .collection(Collections.match)
          .doc(widget.match.date)
          .collection(widget.selectUser.userType)
          .doc("${widget.selectUser.userName}$currentSlip")
          .set(Slip(
                  totalAmount: getCurrentSlipTotalAmount(),
                  receipts: _selectedSlip!.receipts,
                  userName: widget.selectUser.userName,
                  id: currentSlip,
                  isSave: true)
              .toJson())
          .then((value) {
        Navigator.of(context).pop();
        BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
      }).catchError((error) {
        Navigator.of(context).pop();
        //   Toasts.showErrorMessageToast("Failed to save slip: $error");
      }).whenComplete(() {
        if (DateTime.now().millisecondsSinceEpoch > widget.match.closeTime) {
          showNoticeToast(message: "Over Time");
          FirebaseFirestore.instance
              .collection(Collections.match)
              .doc(widget.match.date)
              .collection(Collections.message)
              .add(Message(
                      title: overTimeSaveMessage,
                      content:
                          "${CacheHelper.getAccountInfo().name} saved ${widget.selectUser.userName}(Slip $currentSlip)",
                      matchId: widget.match.matchId,
                      slipId: "${widget.selectUser.userName}$currentSlip",
                      slipUserId: widget.selectUser.userName,
                      updatedUserId: CacheHelper.getAccountInfo().name,
                      createdTimed: DateTime.now().millisecondsSinceEpoch)
                  .toJson());
        }
      });
    }
  }

  ////////////////////////////// User /////////////////////////////////

  Widget get _buildSelectUserView => Container(
        height: 50,
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Row(
          children: [
            Expanded(flex: 1, child: _buildUserType),
            10.paddingWidth,
            Expanded(flex: 2, child: _buildUserListDropDownButton),
          ],
        ),
      );

  Widget get _buildUserType => UnderLineDropDownButton(
        initialValue: widget.selectUser.userType,
        values: userTypes,
        label: "Type",
        onChange: (String? newValue) {
          if (newValue != null) {
            setState(() {
              widget.selectUser.userType = newValue;
              BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
            });
          }
        },
      );

  Widget get _buildUserListDropDownButton => FutureBuilder<List<String>>(
      key: UniqueKey(),
      future: getUser(),
      builder: (context, data) {
        if (data.hasData) {
          return UnderLineDropDownButton(
            initialValue: widget.selectUser.userName,
            values: data.data!,
            label: "User",
            onChange: (String? newValue) {
              if (newValue != null) {
                widget.selectUser.userName = newValue;
                BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
              }
            },
          );
        } else if (data.hasError) {
          print(data.error.toString());
          return DefaultText("fail to get users",
              style:
                  TextStyles.footerTextStyle.copyWith(color: Colors.redAccent));
        }

        return const SizedBox(
          width: 35,
          height: 35,
          child: CircularProgressIndicator(),
        );
      });

  Future<List<String>> getUser() async {
    List<Account> accountsList = [];
    List<String> filteredAccountsNameList = [];
    if (widget.selectUser.userType == "out") {
      accountsList = widget.match.outAccounts;
    } else {
      accountsList = widget.match.inAccounts
          .where((element) => (element.type == "input"))
          .toList();
    }

    for (var account in accountsList) {
      if (account.name == CacheHelper.getAccountInfo().name ||
          account.referUser == CacheHelper.getAccountInfo().name ||
          CacheHelper.getAccountInfo().type == "admin") {
        filteredAccountsNameList.add(account.name);
      }
    }

    if (filteredAccountsNameList.contains(CacheHelper.getAccountInfo().name)) {
      if (widget.selectUser.userName != CacheHelper.getAccountInfo().name) {
        widget.selectUser.userName = CacheHelper.getAccountInfo().name;
        BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
      }
    } else {
      if (widget.selectUser.userName != filteredAccountsNameList[0]) {
        widget.selectUser.userName = filteredAccountsNameList[0];
        BlocProvider.of<SlipIdBloc>(context).add(RefreshSlipIdEvent());
      }
    }

    return filteredAccountsNameList;
  }

  List<int> selectUserDigitAmounts = List.generate(100, (index) => 0);

  ////////////////////////////// Slip Id //////////////////////////////
  Widget get _buildCurrentSlip => BlocBuilder<SlipIdBloc, SlipIdState>(
        builder: (context, state) {
          return FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
              future: FirebaseFirestore.instance
                  .collection(Collections.match)
                  .doc(widget.match.date)
                  .collection(widget.selectUser.userType)
                  .where("userName", isEqualTo: widget.selectUser.userName)
                  .get(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: SizedBox(
                      width: 30,
                      height: 30,
                      child: CircularProgressIndicator(),
                    ),
                  );
                }
                int lastSlip = 0;
                int currentSlipId = 1;
                int totalAmount = 0;
                selectUserDigitAmounts = List.generate(1000, (index) => 0);
                snapshot.data!.docs.map((DocumentSnapshot document) {
                  Map<String, dynamic> data =
                      document.data()! as Map<String, dynamic>;
                  Slip s = Slip.fromJson(data);
                  totalAmount += s.totalAmount;
                  if (s.isSave) {
                    if (currentSlipId <= s.id) {
                      lastSlip = s.id;
                      currentSlipId = s.id + 1;
                    }
                  }
                  for (var receipt in s.receipts) {
                    for (var digit in receipt.digitList) {
                      selectUserDigitAmounts[int.parse(digit.value)] =
                          selectUserDigitAmounts[int.parse(digit.value)] +
                              digit.amount;
                    }
                  }
                }).toList();
                currentSlipController.text = currentSlipId.toString();
                lastSlipController.text = lastSlip.toString();
                userTotalAmountController.text = totalAmount.toString();
                BlocProvider.of<ReceiptListBloc>(context)
                    .add(ChangeReceiptListEvent());
                return SizedBox(
                  height: 45,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                          child: TextFormField(
                        style: TextStyles.textFieldsTextStyle(context),
                        textInputAction: TextInputAction.previous,
                        controller: userTotalAmountController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          enabled: false,
                          border: OutlineInputBorder(),
                          labelText: "Total",
                          hintText: "Total",
                        ),
                      )),
                      10.paddingWidth,
                      Expanded(
                          child: TextFormField(
                        style: TextStyles.textFieldsTextStyle(context),
                        textInputAction: TextInputAction.previous,
                        controller: lastSlipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          enabled: false,
                          border: OutlineInputBorder(),
                          labelText: "Last Slip",
                          hintText: "Last Slip",
                        ),
                      )),
                      10.paddingWidth,
                      Expanded(
                          child: TextFormField(
                        onFieldSubmitted: (value) {
                          int? slipIdNum = int.tryParse(value);
                          if (slipIdNum != null) {
                            Slip? selectedSlip;
                            snapshot.data!.docs
                                .map((DocumentSnapshot document) {
                              Map<String, dynamic> data =
                                  document.data()! as Map<String, dynamic>;
                              Slip s = Slip.fromJson(data);
                              if (slipIdNum == s.id) {
                                selectedSlip = s;
                              }
                              return;
                            }).toList();
                            if (selectedSlip != null) {
                              BlocProvider.of<ReceiptListBloc>(context)
                                  .add(ChangeReceiptListEvent());
                            } else {
                              BlocProvider.of<ReceiptListBloc>(context)
                                  .add(ChangeReceiptListEvent());
                              currentSlipController.text =
                                  "${int.parse(lastSlipController.text.toString()) + 1}";
                              Toasts.showErrorMessageToast(
                                  "Invalid Current Slip Id");
                            }
                          } else {
                            currentSlipController.text =
                                "${int.parse(lastSlipController.text.toString()) + 1}";
                            Toasts.showErrorMessageToast(
                                "Invalid Current Slip Id");
                          }
                        },
                        style: TextStyles.textFieldsTextStyle(context),
                        textInputAction: TextInputAction.none,
                        controller: currentSlipController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          contentPadding:
                              EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                          border: OutlineInputBorder(),
                          hintText: "Current Slip",
                          labelText: "Current Slip",
                        ),
                      )),
                    ],
                  ),
                );
              });
        },
      );
}
