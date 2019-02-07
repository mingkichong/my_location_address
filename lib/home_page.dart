import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:vibrate/vibrate.dart';
import './constant.dart';
import './control_button_bloc.dart';
import './address_button_manager.dart';
import './address_store.dart';
import 'map_controller_manager.dart';
import 'map_controller.dart';
import 'geo_store.dart';

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

class MapView extends StatefulWidget {
  @override
  _MapViewState createState() => _MapViewState();
}

class _MapViewState extends State<MapView> {
  GoogleMapController googleMapController;
  @override
  Widget build(BuildContext context) {
    return Expanded(
      flex: 6,
      child: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: LatLng(37.7749, -122.4194),
          zoom: 1,
        ),
        onMapCreated: (controller) {
          MapControllerManager.of(context).mapController.controller = googleMapController = controller;
          AddressStore.readAddress().then((address) {
            GeoStore.readLatLng().then((LatLng position) {
              String geolocation = position.latitude.toStringAsFixed(Constant.GEO_PRECISION) +
                  ", " +
                  position.longitude.toStringAsFixed(Constant.GEO_PRECISION);
              controller
                  .animateCamera(CameraUpdate.newLatLngZoom(position, Constant.DEFAULT_ZOOM_LEVEL))
                  .then((_) {
                controller.addMarker(MarkerOptions(
                  position: position,
                  infoWindowText: InfoWindowText(address, geolocation),
                ));
              });
            });
          });
        },
        tiltGesturesEnabled: false,
        compassEnabled: false,
        rotateGesturesEnabled: false,
        scrollGesturesEnabled: true,
        zoomGesturesEnabled: true,
        mapType: MapType.normal,
      ),
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
                content: Text(
                  'Address copied to clipboard',
                  textAlign: TextAlign.center,
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
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
                  content: Text(
                    "Long press to clear",
                    textAlign: TextAlign.center,
                  ),
                ),
          );
        },
      ),
    );
  }
}
