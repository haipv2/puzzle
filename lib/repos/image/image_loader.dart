import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_database.dart';
import '../firebase_storage.dart';

class ImageLoader {
//  static StorageReference reference = FirebaseStorage().ref().child('gs://backend-puzzle.appspot.com/');
  static List<String> fileNames = List<String>();
  static List<String> imageUrls = List<String>();

  ///
  static Future<dynamic> init() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('images').getDocuments();
    snapshot.documents.forEach((f) {
      fileNames.add(f.data['file_name']);
    });
  }

  static Future<dynamic> buildImageUrl() async {
    StorageReference ref = FirebaseStorage.instance.ref();

//    fileNames.forEach((item) {
//      imageUrls.add(getDownloadUrl(ref, item));
//    });
    print (imageUrls);
  }
  static Future<String> getDownloadUrl(StorageReference ref, String item)async{
    await ref.child('images/$item').getDownloadURL().toString();

  }
}
