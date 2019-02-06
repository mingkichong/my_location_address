import 'dart:async';

class ControlButtonBloc {
  StreamController<String> _controller = StreamController<String>();

  Sink<String> get addressSink => _controller.sink;
  Stream<String> get addressStream => _controller.stream;

  void dispose() {
    _controller.close();
  }
}
