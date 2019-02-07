import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';

import 'address_button_manager.dart';
import 'address_store.dart';
import 'constant.dart';

class AddressTextView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: SingleChildScrollView(
        child: GestureDetector(
          onLongPress: () {
            AddressStore.readAddress().then((value) {
              Clipboard.setData(ClipboardData(text: value));
              Scaffold.of(context).showSnackBar(SnackBar(
                duration: Duration(seconds: 2),
                content: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Icon(
                      Icons.content_copy,
                      color: Colors.lightBlue,
                    ),
                    SizedBox(width: Constant.SIZED_BOX_WIDTH),
                    Text(
                      'Address copied to clipboard',
                      style: TextStyle(fontFamily: 'century_gothic'),
                    ),
                  ],
                ),
              ));
              Vibrate.feedback(FeedbackType.selection);
            });
          },
          child: StreamBuilder<String>(
            initialData: Constant.DEFAULT_ADDRESS,
            stream: AddressButtonManager.of(context).bloc.addressStream,
            builder: (context, snapshot) => Text(
                  snapshot.data,
                  style: TextStyle(fontSize: Constant.TEXT_ADDRESS_FONT_SIZE),
                  textAlign: TextAlign.center,
                ),
          ),
        ),
      ),
    );
  }
}
