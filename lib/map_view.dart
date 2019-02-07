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
          target: LatLng(Constant.SAN_FRAN_GEO_LAT, Constant.SAN_FRAN_GEO_LONG),
          zoom: 1,
        ),
        onMapCreated: (controller) {
          MapControllerManager.of(context).mapController.controller = googleMapController = controller;
          AddressStore.readAddress().then((address) {
            GeoStore.readLatLng().then((LatLng position) {
              bool isDefaultGeo = position.latitude == Constant.DEFAULT_GEO_LAT &&
                  position.longitude == Constant.DEFAULT_GEO_LONG;
              String geolocation = (isDefaultGeo)
                  ? ""
                  : position.latitude.toStringAsFixed(Constant.GEO_PRECISION) +
                      ", " +
                      position.longitude.toStringAsFixed(Constant.GEO_PRECISION);
              controller
                  .moveCamera(CameraUpdate.newLatLngZoom(
                      (isDefaultGeo)
                          ? LatLng(Constant.SAN_FRAN_GEO_LAT, Constant.SAN_FRAN_GEO_LONG)
                          : position,
                      Constant.DEFAULT_ZOOM_LEVEL))
                  .then(
                (_) {
                  if (!isDefaultGeo) {
                    controller.addMarker(
                      MarkerOptions(
                        position: position,
                        infoWindowText: InfoWindowText(address, geolocation),
                        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
                      ),
                    );
                  }
                },
              );
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
