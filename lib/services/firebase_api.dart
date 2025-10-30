import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseApi {
  static Future<String> uploadPost(
      File file, String folderName, String filename) async {
    try {
      String url = "";
      Reference ref =
          FirebaseStorage.instance.ref().child('$folderName/$filename');

      UploadTask uploadTask = ref.putFile(file);

      // uploadTask.snapshotEvents.listen((TaskSnapshot taskSnapshot) {
      //   switch (taskSnapshot.state) {
      //     case TaskState.running:
      //       final progress = 100.0 *
      //           (taskSnapshot.bytesTransferred / taskSnapshot.totalBytes);
      //       print("Upload is $progress% complete.");
      //       break;
      //     case TaskState.paused:
      //       print("Upload is paused.");
      //       break;
      //     case TaskState.canceled:
      //       print("Upload was canceled");
      //       break;
      //     case TaskState.error:
      //       print("Error = ${taskSnapshot.printError}");
      //       break;
      //     case TaskState.success:
      //       // Handle successful uploads on complete
      //       // ...
      //       break;
      //   }
      // });

      // await uploadTask.whenComplete(() {});
      // await uploadTask.onError((error, stackTrace) async {
      //   print("errorr=====$error");
      // });

      await uploadTask.whenComplete(() async {
        url = await ref.getDownloadURL();
      });

      // print("url=====$url");

      return url;
    } on FirebaseException catch (e) {
      //print("errr=====$e");
      print("uploadPost==error==$e");
      return e.toString();
    }
  }
}
