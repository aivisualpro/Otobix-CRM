import 'dart:html' as html;

class UrlHelper {
  static void setPath(String path) {
    // ensure starts with /
    if (!path.startsWith('/')) path = '/$path';
    html.window.location.hash = path; // ✅ hash routing
  }

  static String getPath() {
    // hash example: "#/admin/users?origin=admin"
    final h = html.window.location.hash ?? '';
    if (h.isEmpty) return '/';

    final withoutHash = h.startsWith('#') ? h.substring(1) : h;
    return withoutHash.isEmpty ? '/' : withoutHash;
  }

  static void onPop(void Function(String path) cb) {
    html.window.onHashChange.listen((_) => cb(getPath()));
  }
}
