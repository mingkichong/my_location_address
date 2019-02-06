import 'package:flutter/material.dart';
import './control_button_bloc.dart';

class AddressButtonManager extends InheritedWidget {
  final ControlButtonBloc bloc;

  const AddressButtonManager({
    Key key,
    @required Widget child,
    @required this.bloc,
  })  : assert(child != null && bloc != null),
        super(key: key, child: child);

  static AddressButtonManager of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(AddressButtonManager) as AddressButtonManager;
  }

  @override
  bool updateShouldNotify(AddressButtonManager old) => true;
}
