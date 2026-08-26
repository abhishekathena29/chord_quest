import 'package:flutter/material.dart';

/// The three primary destinations of the app shell.
enum NavTab { learn, journey, profile }

/// Holds the selected bottom-navigation tab.
class NavProvider extends ChangeNotifier {
  NavTab _tab = NavTab.journey;
  NavTab get tab => _tab;

  int get index => NavTab.values.indexOf(_tab);

  void select(NavTab tab) {
    if (tab == _tab) return;
    _tab = tab;
    notifyListeners();
  }

  void selectIndex(int index) => select(NavTab.values[index]);
}
