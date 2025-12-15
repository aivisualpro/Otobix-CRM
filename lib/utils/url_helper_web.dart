import 'dart:html' as html;

class UrlHelper {
  static const _kLastPathKey = 'otobix_last_path';

  static void setPath(String path) {
    final p = path.startsWith('/') ? path : '/$path';

    // ✅ always keep URL in hash: /#/...
    html.window.history.pushState(null, '', '/#$p');

    // ✅ persist last route so refresh can restore even if hash becomes empty
    html.window.localStorage[_kLastPathKey] = p;
  }

  static String getPath() {
    // ✅ Most reliable inside Flutter web
    final frag =
        Uri.base.fragment; // "/admin/dashboard?origin=home" (without "#")
    if (frag.isNotEmpty) {
      final p = frag.startsWith('/') ? frag : '/$frag';
      // keep it stored
      html.window.localStorage[_kLastPathKey] = p;
      return p;
    }

    // ✅ fallback to last stored route
    final last = html.window.localStorage[_kLastPathKey];
    if (last != null && last.isNotEmpty) return last;

    return '/';
  }

  static void onPop(void Function(String path) cb) {
    void fire(_) => cb(getPath());
    html.window.onPopState.listen(fire);
    html.window.onHashChange.listen(fire);
  }
}
