import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseDatabaseUtil {
//  DatabaseReference _imageRef;

//  DatabaseError error;
  Firestore firestore;

//  FirebaseDatabase database = new FirebaseDatabase();

  static final FirebaseDatabaseUtil _instance =
      new FirebaseDatabaseUtil.internal();

  FirebaseDatabaseUtil.internal();

  factory FirebaseDatabaseUtil() {
    return _instance;
  }

  Future<List<String>> getImageNames(List<String> imageNames) async {
//    _imageRef = database.reference().child('images');
//    DataSnapshot snapshot = await _imageRef.once();
    QuerySnapshot snapshot = await Firestore.instance
        .collection('images')
        .getDocuments();
    snapshot.documents.forEach((f) {
      imageNames.add(f.data['image_name']);
    });
    return imageNames;
  }


  String buildImageName(Map<dynamic, dynamic> imageNameMap) {
    String fileName;
    imageNameMap.forEach((key, value) {
      if (key == 'image_name') {
        fileName = value.toString();
      }
    });
    return fileName;
  }
}
