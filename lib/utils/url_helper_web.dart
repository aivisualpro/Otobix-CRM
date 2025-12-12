import 'dart:html' as html;

class UrlHelper {
  static void setPath(String path) {
    html.window.history.pushState(null, '', path);
  }

  static String getPath() => html.window.location.pathname ?? '/';

  static void onPop(void Function(String path) cb) {
    html.window.onPopState.listen((_) => cb(getPath()));
  }
}
