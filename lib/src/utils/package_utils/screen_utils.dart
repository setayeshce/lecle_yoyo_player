import 'package:auto_orientation/auto_orientation.dart';

class ScreenUtils {
  static void toggleFullScreen(bool fullScreen) {
    if (fullScreen) {
      AutoOrientation.portraitUpMode();
    } else {
      AutoOrientation.landscapeRightMode();
    }
  }
}
