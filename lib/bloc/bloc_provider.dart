import 'package:flutter/material.dart';

abstract class BlocBase {
  void dispose();
}

Type _typeOf<T>() => T;

class BlocProvider<T extends BlocBase> extends StatefulWidget {
  final Widget child;
  final T bloc;

  BlocProvider({Key key, @required this.child, @required this.bloc})
      : super(key: key);

  @override
  _BlocProviderState<T> createState() {
    return _BlocProviderState<T>();
  }

  static T of<T extends BlocBase>(BuildContext context) {
    final type = _typeOf<_BlocProviderInherited<T>>();
    _BlocProviderInherited<T> provider = context.ancestorInheritedElementForWidgetOfExactType(type)?.widget;
    return provider?.bloc;
  }
}

class _BlocProviderState<T extends BlocBase> extends State<BlocProvider<T>> {
  @override
  Widget build(BuildContext context) {
    return _BlocProviderInherited<T>(
      bloc: widget.bloc,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    widget.bloc?.dispose();
    super.dispose();
  }
}

class _BlocProviderInherited<T> extends InheritedWidget {
  _BlocProviderInherited({
    Key key,
    @required Widget child,
    @required this.bloc,
  }) : super(key: key, child: child);
  final T bloc;

  @override
  bool updateShouldNotify(InheritedWidget oldWidget) {
    return true;
  }
}

typedef BlocProvider _BuildWithChild(Widget child);

Widget blocsTree(
  List<_BuildWithChild> childlessBlocs, {
  @required Widget child,
}) {
  return childlessBlocs.reversed.fold<Widget>(
    child,
    (Widget nextChild, _BuildWithChild childlessBloc) =>
        childlessBloc(nextChild),
  );
}

_BuildWithChild blocTreeNode<T extends BlocBase>(T bloc) =>
    (Widget child) => BlocProvider<T>(bloc: bloc, child: child);
