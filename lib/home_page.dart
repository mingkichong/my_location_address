import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:vibrate/vibrate.dart';
import './constant.dart';
import './control_button_bloc.dart';
import './address_button_manager.dart';
import './address_store.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text("My Location Address")),
      ),
      body: AddressButtonManager(
        child: BodyStructure(),
        bloc: ControlButtonBloc(),
      ),
    );
  }
}

class BodyStructure extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    AddressStore.readAddress(context).then((value) {
      AddressButtonManager.of(context).bloc.addressSink.add(value);
    });
    return Column(
      children: <Widget>[
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
        ControlButtons(),
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
        AddressText(),
        SizedBox(height: Constant.SIZED_BOX_HEIGHT),
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
            AddressStore.readAddress(context).then((value) {
              Clipboard.setData(ClipboardData(text: value));
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

class ControlButtons extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        _GetMyLocationButton(),
        SizedBox(width: Constant.SIZED_BOX_WIDTH),
        _ClearButton(),
      ],
    );
  }
}

class _GetMyLocationButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RaisedButton(
      color: Colors.lightGreen,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.BUTTON_BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.all(Constant.BUTTON_PADDING),
        child: Text(
          "Get My Address",
          style: TextStyle(fontSize: Constant.BUTTON_FONT_SIZE),
        ),
      ),
      onPressed: () {
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
          Geolocator()
              .placemarkFromCoordinates(position.latitude, position.longitude)
              .then((placeMarkerList) {
            String address = placeMarkerList.elementAt(0).name +
                " " +
                placeMarkerList.elementAt(0).thoroughfare +
                ", " +
                placeMarkerList.elementAt(0).subAdministratieArea +
                ", " +
                placeMarkerList.elementAt(0).administrativeArea +
                ", " +
                placeMarkerList.elementAt(0).country +
                ", " +
                placeMarkerList.elementAt(0).postalCode +
                " \n(" +
                placeMarkerList.elementAt(0).position.latitude.toString() +
                "," +
                placeMarkerList.elementAt(0).position.longitude.toString() +
                ")";
            AddressStore.writeAddress(address);
            AddressButtonManager.of(context).bloc.addressSink.add(address);
          });
        });
        Vibrate.feedback(FeedbackType.light);
      },
    );
  }
}

class _ClearButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        AddressStore.writeAddress(Constant.DEFAULT_ADDRESS);
        AddressButtonManager.of(context).bloc.addressSink.add(Constant.DEFAULT_ADDRESS);
        Vibrate.feedback(FeedbackType.success);
      },
      child: RaisedButton(
        color: Colors.pink,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.BUTTON_BORDER_RADIUS)),
        child: Padding(
          padding: const EdgeInsets.all(Constant.BUTTON_PADDING),
          child: Text(
            "Clear",
            style: TextStyle(fontSize: Constant.BUTTON_FONT_SIZE),
          ),
        ),
        onPressed: () {
          Vibrate.feedback(FeedbackType.warning);
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text("Long press to clear"),
                ),
          );
        },
      ),
    );
  }
}
