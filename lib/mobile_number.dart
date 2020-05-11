import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:mobile_number/sim_card.dart';
import 'package:mobile_number/widget_lifecycle.dart';

class MobileNumberModel {
  String country;
  String number;

  MobileNumberModel({this.country, this.number});
}

class MobileNumber {
  static const MethodChannel _channel = const MethodChannel('mobile_number');
  static const EventChannel _phonePermissionEvent =
      EventChannel('phone_permission_event');

//phone_permission_event // //

  static void listenPhonePermission(
      Function(bool isPermissionGranted) subscription) {
    WidgetsBinding.instance.addObserver(WidgetLifecycle(
      resumeCallBack: (() async {
        if (await MobileNumber.hasPhonePermission) {
          subscription(true);
        } else {
          subscription(false);
        }
      }),
    ));
  }

  static Future<bool> get hasPhonePermission async {
    final bool hasPermission =
        await _channel.invokeMethod('hasPhonePermission');
    return hasPermission;
  }

  static Future<void> get requestPhonePermission async {
    await _channel.invokeMethod('requestPhonePermission');
  }

  static Future<MobileNumberModel> get mobileNumber async {
    final String simCardsJson = await _channel.invokeMethod('getMobileNumber');
    if (simCardsJson.isEmpty) {
      return null;
    }
    List<SimCard> simCards = SimCard.parseSimCards(simCardsJson);
    if (simCards != null && simCards.isNotEmpty) {
      final MobileNumberModel model = MobileNumberModel(
          country: simCards[0].countryPhonePrefix, number: simCards[0].number);
      return model;
    } else {
      return null;
    }
  }

  static Future<List<SimCard>> get getSimCards async {
    final String simCardsJson = await _channel.invokeMethod('getMobileNumber');
    if (simCardsJson.isEmpty) {
      return <SimCard>[];
    }
    List<SimCard> simCards = SimCard.parseSimCards(simCardsJson);
    if (simCards != null && simCards.isNotEmpty) {
      return simCards;
    } else {
      return <SimCard>[];
    }
  }
}
