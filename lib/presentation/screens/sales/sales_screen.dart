import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:lotaya/core/extensions/size_extension.dart';
import 'package:lotaya/core/routes/routes.dart';
import 'package:lotaya/core/styles/appbars/appbar.dart';
import 'package:lotaya/core/values/images.dart';
import 'package:lotaya/data/model/match.dart';
import 'package:lotaya/presentation/screens/sales/sale_details_screen.dart';

import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/collections.dart';

class SalesScreen extends StatefulWidget {
  const SalesScreen({Key? key}) : super(key: key);

  @override
  State<SalesScreen> createState() => _SalesScreenState();
}

class _SalesScreenState extends State<SalesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: defaultAppBar(context, title: "အရောင်း"),
      body: StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection(Collections.match).where("isActive",isEqualTo: true).snapshots(),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return DefaultText("No Internet Connection", style: TextStyles.bodyTextStyle.copyWith(color: Colors.orange));
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: SizedBox(width:50,height:50,child: CircularProgressIndicator()));
            }
            if (snapshot.data!.size == 0) {
              return Center(child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.hourglass_empty),
                  10.paddingHeight,
                  const DefaultText("Empty Match", style: TextStyles.bodyTextStyle),
                ],
              ));
            } else {
              return ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width*((MediaQuery.of(context).size.width<900)?0.1:0.25),vertical: 20) ,
                  itemCount: snapshot.data!.size,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> data = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                    DigitMatch match = DigitMatch.fromJson(data);
                    return Card(
                      child: InkWell(
                        onTap: (){
                          goToNextPage(context, SaleDetailsScreen(match:  match));
                        },
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 20,horizontal: 10),
                          child: Row(
                            children: [
                              const ImageIcon(AssetImage(Images.iconSales),size: 30,),
                              10.paddingWidth,
                              Expanded(
                                child: DefaultText(
                                  snapshot.data!.docs[index].id.toString(),
                                  style: TextStyles.titleTextStyle,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            }
          }),
    );
  }
}
