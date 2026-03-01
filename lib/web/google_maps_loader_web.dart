// Web-only implementation.
// ignore_for_file: avoid_web_libraries_in_flutter, deprecated_member_use

import 'dart:async';
import 'dart:html' as html;

Future<void> loadGoogleMapsJS(String apiKey) async {
  final completer = Completer<void>();

  // لو اتعمل تحميل قبل كده
  final existing = html.document.querySelector('script[data-gmaps="true"]');
  if (existing != null) {
    completer.complete();
    return completer.future;
  }

  final script = html.ScriptElement()
    ..setAttribute('data-gmaps', 'true')
    ..src =
        "https://maps.googleapis.com/maps/api/js?key=$apiKey&libraries=places"
    ..async = true
    ..defer = true;

  script.onLoad.listen((_) => completer.complete());
  script.onError.listen((_) => completer.complete()); // ما نكسرش التطبيق

  html.document.head!.append(script);
  return completer.future;
}
