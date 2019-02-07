import 'package:flutter/material.dart';

import 'address_button_manager.dart';
import 'address_store.dart';
import 'address_text_view.dart';
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
        AddressTextView(),
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
        MapView(),
      ],
    );
  }
}
