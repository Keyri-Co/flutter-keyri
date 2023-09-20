import 'dart:convert';

class Session {
  Session(
      this.widgetOrigin,
      this.sessionId,
      this.widgetUserAgent,
      this.userParameters,
      this.iPAddressMobile,
      this.iPAddressWidget,
      this.riskAnalytics,
      this.publicUserId,
      this.mobileTemplateResponse);

  final String? widgetOrigin;
  final String sessionId;
  final WidgetUserAgent? widgetUserAgent;
  final UserParameters? userParameters;
  final String iPAddressMobile;
  final String iPAddressWidget;
  final RiskAnalytics? riskAnalytics;
  final String? publicUserId;
  final MobileTemplateResponse? mobileTemplateResponse;

  /// Conversion helper method.
  static Session fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    var widgetUserAgentJson = jsonData['widgetUserAgent'];
    var userParametersJson = jsonData['userParameters'];
    var riskAnalyticsJson = jsonData['riskAnalytics'];
    var mobileTemplateResponseJson = jsonData['mobileTemplateResponse'];

    WidgetUserAgent? widgetUserAgent;
    UserParameters? userParameters;
    RiskAnalytics? riskAnalytics;
    MobileTemplateResponse? mobileTemplateResponse;

    if (widgetUserAgentJson != null) {
      widgetUserAgent = WidgetUserAgent.fromJson(widgetUserAgentJson);
    }

    if (userParametersJson != null) {
      userParameters = UserParameters.fromJson(userParametersJson);
    }

    if (riskAnalyticsJson != null) {
      riskAnalytics = RiskAnalytics.fromJson(riskAnalyticsJson);
    }

    if (mobileTemplateResponseJson != null) {
      mobileTemplateResponse =
          MobileTemplateResponse.fromJson(mobileTemplateResponseJson);
    }

    return Session(
      jsonData['widgetOrigin'] as String?,
      jsonData['sessionId'] as String,
      widgetUserAgent,
      userParameters,
      jsonData['iPAddressMobile'] as String? ?? '',
      jsonData['iPAddressWidget'] as String? ?? '',
      riskAnalytics,
      jsonData['publicUserId'] as String?,
      mobileTemplateResponse,
    );
  }
}

class WidgetUserAgent {
  WidgetUserAgent(this.os, this.browser);

  final String os;
  final String browser;

  /// Conversion helper method.
  static WidgetUserAgent fromJson(dynamic json) {
    return WidgetUserAgent(
      json['os'] as String,
      json['browser'] as String,
    );
  }
}

class UserParameters {
  UserParameters(this.base64EncodedData);

  final String? base64EncodedData;

  /// Conversion helper method.
  static UserParameters fromJson(dynamic json) {
    return UserParameters(json['base64EncodedData'] as String?);
  }
}

class RiskAnalytics {
  RiskAnalytics(this.riskStatus, this.riskFlagString, this.geoData);

  final String? riskStatus;
  final String? riskFlagString;
  final GeoData? geoData;

  /// Conversion helper method.
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

  /// Conversion helper method.
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

  /// Conversion helper method.
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

class MobileTemplateResponse {
  MobileTemplateResponse(this.title, this.message, this.widget, this.mobile,
      this.userAgent, this.flags);

  final String? title;
  final String? message;
  final Template? widget;
  final Template? mobile;
  final UserAgent? userAgent;
  final Flags? flags;

  /// Conversion helper method.
  static MobileTemplateResponse fromJson(dynamic json) {
    var widgetJson = json['widget'];
    var mobileJson = json['mobile'];
    var userAgentJson = json['userAgent'];
    var flagsJson = json['flags'];

    Template? widget;
    Template? mobile;
    UserAgent? userAgent;
    Flags? flags;

    if (widgetJson != null) {
      widget = Template.fromJson(widgetJson);
    }

    if (mobileJson != null) {
      mobile = Template.fromJson(mobileJson);
    }

    if (userAgentJson != null) {
      userAgent = UserAgent.fromJson(userAgentJson);
    }

    if (flagsJson != null) {
      flags = Flags.fromJson(flagsJson);
    }

    /// Conversion helper method.
    return MobileTemplateResponse(json['title'] as String?,
        json['message'] as String?, widget, mobile, userAgent, flags);
  }
}

class Template {
  Template(this.location, this.issue);

  final String? location;
  final String? issue;

  /// Conversion helper method.
  static Template fromJson(dynamic json) {
    return Template(json['location'] as String?, json['issue'] as String?);
  }
}

class UserAgent {
  UserAgent(this.name, this.issue);

  final String? name;
  final String? issue;

  /// Conversion helper method.
  static UserAgent fromJson(dynamic json) {
    return UserAgent(json['name'] as String?, json['issue'] as String?);
  }
}

class Flags {
  Flags(this.isDatacenter, this.isNewBrowser);

  final bool? isDatacenter;
  final bool? isNewBrowser;

  /// Conversion helper method.
  static Flags fromJson(dynamic json) {
    return Flags(json['isDatacenter'] as bool?, json['isNewBrowser'] as bool?);
  }
}
