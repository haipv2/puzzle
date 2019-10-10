import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:puzzle/commons/enums.dart';
import 'package:puzzle/model/achievement.dart';

class GameAchievement {
  static Achievement bestEasy = new Achievement();
  static Achievement bestMedium = new Achievement();
  static Achievement bestHard = new Achievement();

  static Future<Achievement> getBestScoreEasy() async {
    try {
      Firestore.instance
          .collection('best_score')
          .where('level', isEqualTo: 'EASY')
          .orderBy('summary', descending: true)
          .limit(1)
          .snapshots()
          .listen((data) {
        if (data.documents.isEmpty) {
          return Achievement();
        } else {
          data.documents.forEach((item) {
            bestEasy.userName = item['user_name'];
            bestEasy.summary = item['summary'];
            bestEasy.moveStep = item['move_step'];
            bestEasy.timePlay = item['time_play'];
            bestEasy.level = item['level'];
            bestEasy.country = item['country'];
          });
        }
        return bestEasy;
      });
    } catch (e) {
      return Achievement();
    }

    return bestEasy;
  }

  static Future<Achievement> getBestScoreMedium() async {
    Query query = Firestore.instance
        .collection('best_score')
        .reference()
        .where('level', isEqualTo: 'MEDIUM')
        .orderBy('summary', descending: true)
        .limit(1);
    print(query);
    return bestMedium;
  }

  static Future<Achievement> getBestScoreHard() async {
    Query query = Firestore.instance
        .collection('best_score')
        .reference()
        .where('level', isEqualTo: 'HARD')
        .orderBy('summary', descending: true)
        .limit(1);
    print(query);
    return bestHard;
  }
}
