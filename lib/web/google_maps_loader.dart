// ignore_for_file: avoid_web_libraries_in_flutter
import 'dart:html' as html;
import 'dart:async';

Future<void> loadGoogleMapsJS() async {
  final completer = Completer<void>();

  final script = html.ScriptElement()
    ..src =
        "https://maps.googleapis.com/maps/api/js?key=YOUR_KEY&libraries=places"
    ..async = true;

  script.onLoad.listen((_) => completer.complete());
  script.onError.listen((_) => completer.complete());

  html.document.head!.append(script);
  return completer.future;
}
