import 'dart:html' as html;

class UrlHelper {
  static void setPath(String path) {
    if (!path.startsWith('/')) path = '/$path';
    html.window.history.pushState(null, '', path);
  }

  static String getPath() {
    final p = html.window.location.pathname;
    final q = html.window.location.search;
    return '${p ?? '/'}${q ?? ''}';
  }

  static void onPop(void Function(String path) cb) {
    html.window.onPopState.listen((_) => cb(getPath()));
  }
}
