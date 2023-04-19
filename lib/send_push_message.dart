import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

void sendPushMessage(String token, String title, String body) async {
  try {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: <String, String>{
        'Content-Type': 'application/json',
        'Authorization':
            'key=AAAA8kwtbkk:APA91bHtdDKdDy3U_EMMTHjbGqwtNlUKVNnKAtiEx-XskWp0mm'
                'Ezm4MkVxmxa-SqPaZjdVQCZ0kP5af2T24WVnTYqSfWqMQd3LJd-cyj4VdQn9yr'
                'aXAOAhHilXDksv8PTJAApLPQy2Y_' //TODO what is my key??
      },
      body: jsonEncode(
        <String, dynamic>{
          'priority': 'high', // TODO arg priority?

          // TODO allegedly this is required when you want a click on the notif panel? to lead to a (dedicated?) page
          'data': <String, dynamic>{
            'click_action': 'FLUTTER_NOTIFICATION_CLICK',
            'status': 'done',
            'body': body,
            'title': title,
          },

          'notification': <String, dynamic>{
            'title': title,
            'body': body,
            'android_channel_id': 'cleanest' //allegedly this doesn't matter
          },
          'to': token,
        },
      ),
    );
  } catch (e) {
    if (kDebugMode) print('sendPushMessage() error: $e');
  }
}
