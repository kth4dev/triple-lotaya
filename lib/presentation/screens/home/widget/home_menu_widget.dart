
import 'package:flutter/material.dart';

import '../../../../core/routes/routes.dart';
import '../../../../core/styles/textstyles/default_text.dart';
import '../../../../core/styles/textstyles/textstyles.dart';

class HomeMenuWidget extends StatelessWidget {
  final String label,image;
  final Widget nextPage;
  final Color color;
  const HomeMenuWidget({Key? key,required this.label,required this.image,required this.nextPage,required this.color}) : super(key: key);

  @override
  Widget build(BuildContext context) {

    return Card(
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all((Radius.circular(10))),
      ),
      elevation: 5,
      child: InkWell(
        onTap: (){
          goToNextPage(context, nextPage);
        },
        child: Container(
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                  padding: EdgeInsets.all(_getImageIconPaddingSize(context)),
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(20)
                  ),
                  child: ImageIcon(AssetImage(image),size: _getImageIconSize(context),color: Colors.white,)),
              _divider,
              Text(label, style: TextStyles.subTitleTextStyle.copyWith(color: Colors.black,fontWeight: FontWeight.bold),maxLines: 1,overflow: TextOverflow.ellipsis,)
            ],
          ),
        ),
      ) ,
    );
  }
  double _getImageIconPaddingSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1300) {
      return 20;
    } else if (width > 600) {
      return 15;
    } else {
      return 10;
    }
  }


  double _getImageIconSize(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    if (width > 1300) {
      return 50;
    } else if (width > 600) {
      return 40;
    } else {
      return 30;
    }
  }

  Widget get _divider =>  Container(
    width: double.infinity,
    height: 0.7,
    margin: const EdgeInsets.symmetric(horizontal: 30,vertical: 15),
    padding: const EdgeInsets.all(8.0),
    color: color,
  );
}


