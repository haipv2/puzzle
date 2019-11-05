import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;

class ImageLoader {
  static List<String> fileNames = List<String>();

  ///
  static Future<List<String>> getImageFileName() async {

    QuerySnapshot snapshot =
        await Firestore.instance.collection('images').getDocuments();
    snapshot.documents.forEach((f) {
      fileNames.add(f.data['image_name']);
    });
    return fileNames;
  }

  static Future<List<String>> downloadImages() async {

    StorageReference ref = FirebaseStorage.instance.ref();
    for (String imgName in ImageLoader.fileNames) {
//      getDownloadUrl(ref, imgName);
    }

//    final http.Response downloadData = await http.get(url);

    return fileNames;
  }

  Future<void> getDownloadUrl(StorageReference ref, String item) async {
    try {
      String imgUrl = await ref.child('images/$item').getDownloadURL();

//      imageInfos.add(game.ImageInfo()
//        ..urls = imgUrl
//        ..imageName = item);
//      bloc.imageAddName(imageInfos);
    } catch (e) {
      print(e);
    }
  }

}
