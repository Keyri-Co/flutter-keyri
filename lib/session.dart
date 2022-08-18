import 'dart:convert';

class Session {
  Session(
      this.widgetOrigin,
      this.sessionId,
      this.widgetUserAgent,
      this.iPAddressMobile,
      this.iPAddressWidget,
      this.riskAnalytics,
      this.publicUserId);

  final String? widgetOrigin;
  final String sessionId;
  final WidgetUserAgent? widgetUserAgent;
  final String iPAddressMobile;
  final String iPAddressWidget;
  final RiskAnalytics? riskAnalytics;
  final String? publicUserId;

  static Session fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    var widgetUserAgentJson = jsonData['widgetUserAgent'];
    var riskAnalyticsJson = jsonData['riskAnalytics'];

    WidgetUserAgent? widgetUserAgent;
    RiskAnalytics? riskAnalytics;

    if (widgetUserAgentJson != null) {
      widgetUserAgent = WidgetUserAgent.fromJson(widgetUserAgentJson);
    }

    if (riskAnalyticsJson != null) {
      riskAnalytics = RiskAnalytics.fromJson(riskAnalyticsJson);
    }

    return Session(
      jsonData['widgetOrigin'] as String?,
      jsonData['sessionId'] as String,
      widgetUserAgent,
      jsonData['iPAddressMobile'] as String? ?? '',
      jsonData['iPAddressWidget'] as String? ?? '',
      riskAnalytics,
      jsonData['publicUserId'] as String?,
    );
  }
}

class WidgetUserAgent {
  WidgetUserAgent(this.os, this.browser);

  final String os;
  final String browser;

  static WidgetUserAgent fromJson(dynamic json) {
    return WidgetUserAgent(
      json['os'] as String,
      json['browser'] as String,
    );
  }
}

class RiskAnalytics {
  RiskAnalytics(this.riskStatus, this.riskFlagString, this.geoData);

  final String? riskStatus;
  final String? riskFlagString;
  final GeoData? geoData;

  static RiskAnalytics fromJson(dynamic json) {
    var geoDataJson = json['geoData'];
    GeoData? geoData;

    if (geoDataJson != null) {
      geoData = GeoData.fromJson(geoDataJson);
    }

    return RiskAnalytics(json['riskStatus'] as String?,
        json['riskFlagString'] as String?, geoData);
  }
}

class GeoData {
  GeoData(this.mobile, this.browser);

  final IPData? mobile;
  final IPData? browser;

  static GeoData fromJson(dynamic json) {
    var mobileJson = json['mobile'];
    var browserJson = json['browser'];

    IPData? mobile;
    IPData? browser;

    if (mobileJson != null) {
      mobile = IPData.fromJson(mobileJson);
    }

    if (browserJson != null) {
      browser = IPData.fromJson(browserJson);
    }

    return GeoData(mobile, browser);
  }
}

class IPData {
  IPData(this.continentCode, this.countryCode, this.city, this.latitude,
      this.longitude, this.regionCode);

  final String? continentCode;
  final String? countryCode;
  final String? city;
  final double? latitude;
  final double? longitude;
  final String? regionCode;

  static IPData fromJson(dynamic json) {
    return IPData(
        json['continentCode'] as String?,
        json['countryCode'] as String?,
        json['city'] as String?,
        json['latitude'] as double?,
        json['longitude'] as double?,
        json['regionCode'] as String?);
  }
}
