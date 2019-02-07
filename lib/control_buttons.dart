import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibrate/vibrate.dart';

import 'address_button_manager.dart';
import 'address_store.dart';
import 'constant.dart';
import 'geo_store.dart';
import 'map_controller_manager.dart';

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
      color: Colors.green,
      textColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.BUTTON_BORDER_RADIUS)),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0.0, Constant.BUTTON_PADDING, 0.0, Constant.BUTTON_PADDING),
        child: Row(
          children: <Widget>[
            Icon(
              Icons.my_location,
              color: Colors.lime,
            ),
            SizedBox(width: Constant.BUTTON_ICON_SPACING),
            Text(
              "Get My Address",
              style: TextStyle(fontSize: Constant.BUTTON_FONT_SIZE, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
      onPressed: () {
        Geolocator().getCurrentPosition(desiredAccuracy: LocationAccuracy.high).then((position) {
          GeoStore.writeLatitude(position.latitude);
          GeoStore.writeLongitude(position.longitude);
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
                placeMarkerList.elementAt(0).postalCode;
            String geolocation =
                placeMarkerList.elementAt(0).position.latitude.toStringAsFixed(Constant.GEO_PRECISION) +
                    "," +
                    placeMarkerList.elementAt(0).position.longitude.toStringAsFixed(Constant.GEO_PRECISION);
            LatLng latLng = LatLng(position.latitude, position.longitude);
            MapControllerManager.of(context).mapController.controller.clearMarkers();
            MapControllerManager.of(context).mapController.controller.addMarker(
                  MarkerOptions(
                    position: latLng,
                    infoWindowText: InfoWindowText(address, geolocation),
                    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                  ),
                );

            MapControllerManager.of(context)
                .mapController
                .controller
                .animateCamera(CameraUpdate.newLatLngZoom(latLng, Constant.DEFAULT_ZOOM_LEVEL));
            AddressStore.writeAddress(address);
            AddressButtonManager.of(context).bloc.addressSink.add(address + "\n(" + geolocation + ")");
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
        MapControllerManager.of(context).mapController.controller.clearMarkers();
        AddressStore.writeAddress(Constant.DEFAULT_ADDRESS);
        AddressButtonManager.of(context).bloc.addressSink.add(Constant.DEFAULT_ADDRESS);
        Vibrate.feedback(FeedbackType.success);
      },
      child: RaisedButton(
        color: Colors.pink,
        textColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(Constant.BUTTON_BORDER_RADIUS)),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(0.0, Constant.BUTTON_PADDING, 0.0, Constant.BUTTON_PADDING),
          child: Row(
            children: <Widget>[
              Icon(
                Icons.remove_circle,
                color: Colors.lime,
              ),
              SizedBox(width: Constant.BUTTON_ICON_SPACING),
              Text(
                "Clear",
                style: TextStyle(fontSize: Constant.BUTTON_FONT_SIZE, fontWeight: FontWeight.normal),
              ),
            ],
          ),
        ),
        onPressed: () {
          Vibrate.feedback(FeedbackType.warning);
          Scaffold.of(context).showSnackBar(SnackBar(
            duration: Duration(seconds: 2),
            content: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.warning,
                  color: Colors.red,
                ),
                SizedBox(width: Constant.SIZED_BOX_WIDTH),
                Text(
                  'Long press to clear',
                  style: TextStyle(fontFamily: 'century_gothic'),
                ),
              ],
            ),
          ));
        },
      ),
    );
  }
}
