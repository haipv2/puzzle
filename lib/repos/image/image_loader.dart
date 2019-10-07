import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import '../firebase_database.dart';
import '../firebase_storage.dart';

class ImageLoader {
//  static StorageReference reference = FirebaseStorage().ref().child('gs://backend-puzzle.appspot.com/');
  static List<String> fileNames = List<String>();
  static List<String> imageUrls = List<String>();

  ///
  static Future<List<String>> init() async {

    QuerySnapshot snapshot =
        await Firestore.instance.collection('images').getDocuments();
    snapshot.documents.forEach((f) {
      fileNames.add(f.data['file_name']);
    });
    return fileNames;
  }

//  static Future<dynamic> buildImageUrl() {
  static void buildImageUrl() async {
    QuerySnapshot snapshot =
        await Firestore.instance.collection('images').getDocuments();
    snapshot.documents.forEach((f) {
      fileNames.add(f.data['file_name']);
    });

    StorageReference ref = FirebaseStorage.instance.ref();
    for(String imgName in fileNames){
      getDownloadUrl(ref, imgName);
    }
    print (imageUrls);
  }
  static Future<List<String>> getDownloadUrl(StorageReference ref, String item)async{
    String imgUrl = await ref.child('images/$item').getDownloadURL().toString();
    imageUrls.add(imgUrl);
    return imageUrls;
  }
}
