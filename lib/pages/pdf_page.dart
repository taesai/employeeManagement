import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PdfPage extends StatefulWidget {
  final String? pdfUrl;

  const PdfPage({Key? key, required this.pdfUrl}) : super(key: key);

  @override
  State<PdfPage> createState() => _PdfPageState();
}

class _PdfPageState extends State<PdfPage> {
  bool isLoading = true;
  late String localFilePath;

  @override
  void initState() {
    super.initState();
    downloadPDF();
  }

  Future<void> downloadPDF() async {
    final response = await http.get(Uri.parse(widget.pdfUrl!));
    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/my_pdf_file.pdf');
    await file.writeAsBytes(response.bodyBytes);
    setState(() {
      localFilePath = file.path;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text('PDF VIEWER'),
          backgroundColor: Colors.cyan,
          elevation: 0.0,
        ),
        body: Stack(
          children: [
            if (!isLoading)
              PDFView(
                filePath: localFilePath,
                onViewCreated: (PDFViewController pdfViewController) {},
              ),
            if (isLoading)
              const Center(
                child: CircularProgressIndicator(),
              ),
          ],
        ),
      ),
    );
  }
}
