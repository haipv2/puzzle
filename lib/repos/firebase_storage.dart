
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageUtil {

  /// The reference of the image that has to be loaded.
  StorageReference reference;
  static final FirebaseStorageUtil _instance = FirebaseStorageUtil.internal();

  factory FirebaseStorageUtil(){
    return _instance;
  }

//  /// The widget that will be displayed when loading if no [placeholderImage] is set.
//  final Widget fallbackWidget;
//  /// The widget that will be displayed if an error occurs.
//  final Widget errorWidget;
//  /// The image that will be displayed when loading if no [fallbackWidget] is set.
//  final ImageProvider placeholderImage;



  void init() {
//    var url = reference.getDownloadURL();
//    print(url);
  }

  Future<dynamic> loadAllUrlImage (){
    var url = reference.getDownloadURL();
    print(url);
    return url;
  }

  FirebaseStorageUtil.internal();

}