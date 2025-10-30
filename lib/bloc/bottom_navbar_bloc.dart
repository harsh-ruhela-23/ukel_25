import 'dart:async';

enum NavBarItem { HOME, BRANCH,
  // TRAINING
  PARTY,
  PROFILE }

class BottomNavBarBloc {
  final StreamController<NavBarItem> _navBarController =
      StreamController<NavBarItem>.broadcast();

  NavBarItem defaultItem = NavBarItem.HOME;

  int navBarIndex = 0;

  void pickItem(int i) {
    switch (i) {
      case 0:
        _navBarController.sink.add(NavBarItem.HOME);
        navBarIndex = 0;
        break;
      case 1:
        _navBarController.sink.add(NavBarItem.BRANCH);
        navBarIndex = 1;
        break;
      // case 2:
      //   _navBarController.sink.add(NavBarItem.TRAINING);
      //   navBarIndex = 2;
      //   break;
      // case 1:
      case 2:
        _navBarController.sink.add(NavBarItem.PARTY);
        navBarIndex = 2;
        break;

      case 3:
        _navBarController.sink.add(NavBarItem.PROFILE);
        navBarIndex = 3;
        break;
    }
  }

  Stream<NavBarItem> get itemStream => _navBarController.stream;

  close() {
    _navBarController.close();
  }
}
