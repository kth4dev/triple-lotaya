import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lotaya/core/extensions/size_extension.dart';

import '../../../core/styles/textstyles/default_text.dart';
import '../../../core/styles/textstyles/textstyles.dart';
import '../../../data/model/message.dart';

class NoticeListWidget extends StatelessWidget {
  final List<Message> messages;
  const NoticeListWidget({super.key,required this.messages});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) {
          return Card(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                children: [
                  Icon(Icons.message),
                  10.paddingWidth,
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            Expanded(child: DefaultText(messages[index].title, style: TextStyles.subTitleTextStyle)),
                            DefaultText(DateFormat("dd-MM-yyyy hh:mm a").format(DateTime.fromMillisecondsSinceEpoch(messages[index].createdTimed)),
                                style: TextStyles.descriptionTextStyle),
                          ],
                        ),
                        5.paddingHeight,
                        DefaultText(messages[index].content, style: TextStyles.bodyTextStyle),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
