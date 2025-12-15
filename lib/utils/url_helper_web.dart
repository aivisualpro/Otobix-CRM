import 'dart:html' as html;

class UrlHelper {
  static void setPath(String path) {
    final p = path.startsWith('/') ? path : '/$path';

    // ✅ keep server path always "/" and put route in hash
    // URL becomes: https://domain.com/#/admin/users?origin=admin
    html.window.history.pushState(null, '', '/#$p');
  }

  static String getPath() {
    final h = html.window.location.hash; // "#/admin/users?origin=admin"
    if (h == null || h.isEmpty) return '/';

    final s = h.startsWith('#') ? h.substring(1) : h;
    return s.isEmpty ? '/' : s; // "/admin/users?origin=admin"
  }

  static void onPop(void Function(String path) cb) {
    void fire(_) => cb(getPath());

    // ✅ back/forward
    html.window.onPopState.listen(fire);
    // ✅ when hash changes
    html.window.onHashChange.listen(fire);
  }
}
