import 'package:flutter/material.dart';

import 'map_controller.dart';

class MapControllerManager extends InheritedWidget {
  final MapController mapController;

  const MapControllerManager({
    Key key,
    @required this.mapController,
    @required Widget child,
  })  : assert(child != null),
        super(key: key, child: child);

  static MapControllerManager of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(MapControllerManager) as MapControllerManager;
  }

  @override
  bool updateShouldNotify(MapControllerManager old) => true;
}
