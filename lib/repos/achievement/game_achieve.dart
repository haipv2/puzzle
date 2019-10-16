import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/achievement.dart';

class GameAchievement {
//  static Achievement bestEasy = new Achievement();
//  static Achievement bestMedium = new Achievement();
//  static Achievement bestHard = new Achievement();


  static Future<Achievement> getBestScore(String imageName,{List<String> imageNames}) async {
    Achievement achievement = Achievement();
    try {
      Firestore.instance
          .collection('images')
          .where('image_name', isEqualTo: imageName)
          .snapshots()
          .listen((data) {
        if (data.documents.isEmpty) {
          return achievement;
        } else {
          data.documents.forEach((item) {
            achievement.userNameEasy = item['user_name_easy'];
            achievement.userNameMedium = item['user_name_medium'];
            achievement.userNameHard = item['user_name_hard'];
            achievement.moveStepEasy = item['move_step_easy'];
            achievement.imageName = item['image_name'];
            achievement.moveStepMedium = item['move_step_medium'];
            achievement.moveStepHard = item['move_step_hard'];
            achievement.userNameEasyCountry = item['user_name_easy_country'];
            achievement.userNameMediumCountry =
                item['user_name_medium_country'];
            achievement.userNameHardCountry = item['user_name_hard_country'];
          });
        }
        return achievement;
      });
    } catch (e) {
      print('ERROR: ${e}');
    }
    return achievement;
  }

  static updateNewScore(Achievement achievement) {
    Firestore.instance
        .collection('images')
        .document(achievement.imageName)
        .updateData({
      'user_name_easy': achievement.userNameEasy,
      'user_name_medium': achievement.userNameMedium,
      'user_name_hard': achievement.userNameHard,
      'user_name_easy_country': achievement.userNameEasyCountry,
      'user_name_medium_country': achievement.userNameMediumCountry,
      'user_name_hard_country': achievement.userNameHardCountry,
      'move_step_easy': achievement.moveStepEasy,
      'move_step_medium': achievement.moveStepMedium,
      'move_step_hard': achievement.moveStepHard
    }).catchError((e) {
      print('ERROR: ${e}');
    });
  }
}
