import 'package:flutter/widgets.dart';
import 'package:flutter/foundation.dart';

class Signal<T> {
  final ValueNotifier<T> _notifier;
  Signal(T value) : _notifier = ValueNotifier<T>(value);

  T get value => _notifier.value;
  set value(T v) => _notifier.value = v;

  void addListener(VoidCallback listener) => _notifier.addListener(listener);
  void removeListener(VoidCallback listener) =>
      _notifier.removeListener(listener);

  ValueListenable<T> get listenable => _notifier;
}

class ListSignal<T> extends Signal<List<T>> {
  ListSignal(List<T> value) : super(value);
}

class SignalBuilder<T> extends StatelessWidget {
  final Signal<T> signal;
  final Widget Function(BuildContext, T, Widget?) builder;
  final Widget? child;

  const SignalBuilder(
      {Key? key, required this.signal, required this.builder, this.child})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<T>(
        valueListenable: signal.listenable, builder: builder, child: child);
  }
}
