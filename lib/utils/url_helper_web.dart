import 'dart:html' as html;

class UrlHelper {
  static const _kLastPathKey = 'otobix_last_path';

  static String _normalize(String path) {
    var p = path.trim();
    if (p.isEmpty) return '/';
    if (!p.startsWith('/')) p = '/$p';
    return p;
  }

  /// Normal navigation (tab clicks etc.)
  static void setPath(String path) {
    final p = _normalize(path);
    html.window.history.pushState(null, '', '/#$p');
    html.window.localStorage[_kLastPathKey] = p;
  }

  /// Use this when restoring after refresh (no extra history entry)
  static void replacePath(String path) {
    final p = _normalize(path);
    html.window.history.replaceState(null, '', '/#$p');
    html.window.localStorage[_kLastPathKey] = p;
  }

  static String getPath() {
    // Most reliable: fragment (part after #)
    final frag = Uri.base.fragment; // "/admin/dashboard?origin=home"
    if (frag.isNotEmpty) {
      final p = _normalize(frag);
      html.window.localStorage[_kLastPathKey] = p;
      return p;
    }

    // Fallback: stored last path
    final last = html.window.localStorage[_kLastPathKey];
    if (last != null && last.isNotEmpty) return _normalize(last);

    return '/';
  }

  static void onPop(void Function(String path) cb) {
    void fire(_) => cb(getPath());
    html.window.onPopState.listen(fire);
    html.window.onHashChange.listen(fire);
  }
}
