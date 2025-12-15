import 'dart:html' as html;

class UrlHelper {
  static void setPath(String path) {
    if (!path.startsWith('/')) path = '/$path';
    html.window.location.hash = path;
  }

  static String getPath() {
    final h = html.window.location.hash; // "#/admin/users?origin=admin"
    if (h.isEmpty) return '/';
    return h.startsWith('#')
        ? h.substring(1)
        : h; // "/admin/users?origin=admin"
  }

  static void onPop(void Function(String path) cb) {
    html.window.onHashChange.listen((_) => cb(getPath()));
  }
}
