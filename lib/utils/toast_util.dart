import 'package:fluttertoast/fluttertoast.dart';

class ToastUtil {
  static Future<void> showToast(String message) async {
    await Fluttertoast.showToast(
        msg: message,
        // toastLength: Toast.LENGTH_SHORT,
        // gravity: ToastGravity.CENTER,
        timeInSecForIosWeb: 1,
        // backgroundColor: A.red,
        // textColor: Colors.white,
        fontSize: 14.0);
  }
}
