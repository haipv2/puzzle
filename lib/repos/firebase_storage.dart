
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageUtil {

  /// The reference of the image that has to be loaded.
  StorageReference reference;
  static final FirebaseStorageUtil _instance = FirebaseStorageUtil.internal();

  factory FirebaseStorageUtil(){
    return _instance;
  }

  void init() {
  }

  Future<dynamic> loadAllUrlImage (){
    var url = reference.getDownloadURL();
    return url;
  }

  FirebaseStorageUtil.internal();

}