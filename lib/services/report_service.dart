import 'dart:io';
import 'package:pdf/widgets.dart' as pw;
import 'package:geolocator/geolocator.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

class ReportService {
  static Future<File> generateReport({
    required File videoFile,
    required Position location,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (context) => pw.Column(
          children: [
            pw.Text("Accident Report", style: const pw.TextStyle(fontSize: 30)),
            pw.SizedBox(height: 20),
            pw.Text("Location: ${location.latitude}, ${location.longitude}"),
            pw.Text("Video Attached Separately"),
          ],
        ),
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File("${dir.path}/accident_report.pdf");
    await file.writeAsBytes(await pdf.save());
    return file;
  }

  static Future<void> uploadReport(
      File pdf, File video, Position location) async {
    final request = http.MultipartRequest(
      "POST",
      Uri.parse("http://yourserver.com/api/accident/report"),
    );

    request.files.add(await http.MultipartFile.fromPath("pdf", pdf.path));
    request.files.add(await http.MultipartFile.fromPath("video", video.path));

    request.fields["lat"] = location.latitude.toString();
    request.fields["lng"] = location.longitude.toString();

    await request.send();
  }
}
