import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:vibrate/vibrate.dart';

import 'address_button_manager.dart';
import 'address_store.dart';
import 'constant.dart';
import 'control_buttons.dart';
import 'control_button_bloc.dart';
import 'geo_store.dart';
import 'map_controller.dart';
import 'map_controller_manager.dart';
import 'map_view.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                Icons.location_on,
                color: Colors.lime,
              ),
              SizedBox(width: Constant.SIZED_BOX_WIDTH),
              Text("My Location Address"),
              SizedBox(width: Constant.SIZED_BOX_WIDTH),
              Icon(
                Icons.public,
                color: Colors.lime,
              ),
            ],
          ),
        ),
      ),
      body: MapControllerManager(
        mapController: MapController(),
        child: AddressButtonManager(
          child: BodyStructure(),
          bloc: ControlButtonBloc(),
        ),
      ),
    );
  }
}

class BodyStructure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AddressStore.readAddress().then((address) {
      GeoStore.readLatLng().then((position) {
        String addressGeo = address +
            " \n(" +
            position.latitude.toStringAsFixed(Constant.GEO_PRECISION) +
            ", " +
            position.longitude.toStringAsFixed(Constant.GEO_PRECISION) +
            ")";
        AddressButtonManager.of(context).bloc.addressSink.add(addressGeo);
      });
    });
    return Column(
      children: <Widget>[
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
        ControlButtons(),
        SizedBox(height: Constant.SIZED_BOX_HEIGHT / 2),
        AddressText(),
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
        MapView(),
      ],
    );
  }
}

class AddressText extends StatelessWidget {
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
                      color: Colors.lime,
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
