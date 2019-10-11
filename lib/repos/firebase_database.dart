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
//    snapshots.documents.map((DocumentSnapshot documentSnapshot) {
//      imageNames.add(documentSnapshot['file_name']);
//    });
//    values.forEach((item) {
//      if (item != null) {
//        imageNames.add(item.toString());
//      }
//    });

//    List<String> result = [];
//    images.forEach((key, value) {
//      result.ad d(buildImageName(value));
//    });
    return imageNames;
  }

//  getData() async {
//    return await FirebaseDatabase.instance
//        .reference()
//        .child('images')
//        .limitToFirst(10);
//  }
//
//  DatabaseError getError() {
//    return error;
//  }
//
//  DatabaseReference imageRef() {
//    return _imageRef;
//  }

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
