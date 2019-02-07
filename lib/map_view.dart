import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'address_store.dart';
import 'constant.dart';
import 'geo_store.dart';
import 'map_controller_manager.dart';

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
          target: LatLng(37.7749, -122.4194), //initiate to san francisco
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
                  .moveCamera(CameraUpdate.newLatLngZoom(position, Constant.DEFAULT_ZOOM_LEVEL))
                  .then((_) {
                controller.addMarker(MarkerOptions(
                  position: position,
                  infoWindowText: InfoWindowText(address, geolocation),
                  icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
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
