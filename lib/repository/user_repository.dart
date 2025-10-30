import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:ukel/model/user_model.dart';
import 'package:ukel/utils/constants.dart';

class UserRepository {
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;

  Future<String> createUser(Map<String, dynamic> userDetails) async {
    try {
      await _firebaseFirestore
          .collection("user")
          .doc(userDetails["id"])
          .set(userDetails);

      return AppConstant.success;
    } catch (e) {
      return e.toString();
    }
  }

  Future<Map<String, dynamic>> searchUser(String email, String role) async {
    try {
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await _firebaseFirestore
          .collection("user")
          .where("email", isEqualTo: email)
          .where("role", isEqualTo: role)
          .get();

      List<UserModel> customerModelList = [];

      for (var item in querySnapshot.docs) {
        if (item.exists) {
          final model = UserModel.fromJson(item.data());
          customerModelList.add(model);
        }
      }

      Map<String, dynamic> result = {
        FbConstant.user: customerModelList,
      };

      return result;
    } catch (e) {
      return {
        FbConstant.user: [],
      };
    }
  }

}