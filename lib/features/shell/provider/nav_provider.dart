import 'package:flutter/material.dart';

/// The primary destinations of the app shell. Practice is reached via the
/// raised centre button in the nav bar, not a tab, so it has no entry here.
enum NavTab { learn, journey, tuner, profile }

/// Holds the selected bottom-navigation tab.
class NavProvider extends ChangeNotifier {
  NavTab _tab = NavTab.learn;
  NavTab get tab => _tab;

  int get index => NavTab.values.indexOf(_tab);

  void select(NavTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  void selectIndex(int index) => select(NavTab.values[index]);
}
