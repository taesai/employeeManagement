import "package:flutter/cupertino.dart";
import "package:flutter/material.dart";
import "package:new_attendance_manager/pages/pdf_page.dart";

class FileMessageTile extends StatelessWidget {
  final String fileUrl;
  final String sender;
  final bool sentByMe;

  const FileMessageTile({
    super.key,
    required this.fileUrl,
    required this.sender,
    required this.sentByMe,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
          top: 4, bottom: 4, left: sentByMe ? 0 : 24, right: sentByMe ? 24 : 0),
      alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: sentByMe
            ? const EdgeInsets.only(left: 30)
            : const EdgeInsets.only(right: 30),
        padding:
            const EdgeInsets.only(top: 17, bottom: 17, left: 20, right: 20),
        decoration: BoxDecoration(
            borderRadius: sentByMe
                ? const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  )
                : const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  ),
            color:
                sentByMe ? Theme.of(context).primaryColor : Colors.grey[700]),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sender.toUpperCase(),
              textAlign: TextAlign.start,
              style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -0.5),
            ),
            const SizedBox(
              height: 8,
            ),
            GestureDetector(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => PdfPage(pdfUrl: fileUrl)));
              },
              child: SizedBox(
                  height: 50,
                  width: 150,
                  child: Row(
                    children: const [
                      Icon(
                        CupertinoIcons.doc,
                        color: Colors.white,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        "Tap to open",
                        style: TextStyle(color: Colors.white),
                      ),
                    ],
                  )),
            )
          ],
        ),
      ),
    );
  }
}
