import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/achievement.dart';

class GameAchievement {
//  static Achievement bestEasy = new Achievement();
//  static Achievement bestMedium = new Achievement();
//  static Achievement bestHard = new Achievement();
  static Achievement achievement = Achievement();
  static Future<Achievement> getBestScore(String imageName) async {

    try {
      Firestore.instance
          .collection('images')
          .where('image_name', isEqualTo: imageName)
          .snapshots()
          .listen((data) {
        if (data.documents.isEmpty) {
          return Achievement();
        } else {
          data.documents.forEach((item) {
            achievement.userName = item['user_name'];
            achievement.moveStepEasy = item['move_step_easy'];
            achievement.imageName = item['image_name'];
            achievement.moveStepMedium = item['move_step_medium'];
            achievement.moveStepHard = item['move_step_hard'];
            achievement.country = item['country'];
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
      'user_name': achievement.userName,
      'country': achievement.country,
      'move_step_easy': achievement.moveStepEasy,
      'move_step_medium': achievement.moveStepMedium,
      'move_step_hard': achievement.moveStepHard
    }).catchError((e) {
      print('ERROR: ${e}');
    });
  }
}
