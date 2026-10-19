import 'dart:io';

import 'package:url_launcher/url_launcher.dart';

whatsapp(phoneNumber) async {
  var contact = phoneNumber;
  var androidUrl = "whatsapp://send?phone=$contact&text=Hi, I need some help";
  var iosUrl =
      "https://wa.me/$contact?text=${Uri.parse('Hi, I need some help')}";

  try {
    if (Platform.isIOS) {
      await launchUrl(Uri.parse(iosUrl));
    } else {
      await launchUrl(Uri.parse(androidUrl));
    }
  } on Exception {
    print("whatApp is not installed");
    //  EasyLoading.showError('WhatsApp is not installed.');
  }
}
