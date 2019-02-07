import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapController {
  GoogleMapController _googleMapController;

  set controller(GoogleMapController gMapController) {
    _googleMapController = gMapController;
  }

  GoogleMapController get controller => _googleMapController;
}
