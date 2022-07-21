class Session {
  Session(
      this.widgetOrigin,
      this.sessionId,
      this.widgetUserAgent,
      this.userParameters,
      this.iPAddressMobile,
      this.iPAddressWidget,
      this.riskAnalytics,
      this.publicUserId);

  final String widgetOrigin;
  final String sessionId;
  final WidgetUserAgent? widgetUserAgent;
  final UserParameters? userParameters;
  final String iPAddressMobile;
  final String iPAddressWidget;
  final RiskAnalytics? riskAnalytics;
  final String? publicUserId;

  static Session fromJson(dynamic json) {
    var widgetUserAgentJson = json['widgetUserAgent'];
    var userParametersJson = json['userParameters'];
    var riskAnalyticsJson = json['riskAnalytics'];

    WidgetUserAgent? widgetUserAgent;
    UserParameters? userParameters;
    RiskAnalytics? riskAnalytics;

    if (widgetUserAgentJson != null) {
      widgetUserAgent = WidgetUserAgent.fromJson(widgetUserAgentJson);
    }

    if (userParametersJson != null) {
      userParameters = UserParameters.fromJson(userParametersJson);
    }

    if (riskAnalyticsJson != null) {
      riskAnalytics = RiskAnalytics.fromJson(riskAnalyticsJson);
    }

    return Session(
      json['widgetOrigin'] as String,
      json['sessionId'] as String,
      widgetUserAgent,
      userParameters,
      json['iPAddressMobile'] as String,
      json['iPAddressWidget'] as String,
      riskAnalytics,
      json['publicUserId'] as String?,
    );
  }
}

class WidgetUserAgent {
  WidgetUserAgent(this.isDesktop, this.os, this.browser);

  final bool isDesktop;
  final String os;
  final String browser;

  static WidgetUserAgent fromJson(dynamic json) {
    return WidgetUserAgent(
      json['isDesktop'] as bool,
      json['os'] as String,
      json['browser'] as String,
    );
  }
}

class UserParameters {
  UserParameters(this.custom);

  final String? custom;

  static UserParameters fromJson(dynamic json) {
    return UserParameters(json['custom'] as String?);
  }
}

class RiskAnalytics {
  RiskAnalytics(
      this.riskAttributes, this.riskStatus, this.riskFlagString, this.geoData);

  final RiskAttributes riskAttributes;
  final String? riskStatus;
  final String? riskFlagString;
  final GeoData? geoData;

  static RiskAnalytics fromJson(dynamic json) {
    var geoDataJson = json['geoData'];

    GeoData? geoData;

    if (geoDataJson != null) {
      geoData = GeoData.fromJson(geoDataJson);
    }

    return RiskAnalytics(
        RiskAttributes.fromJson(json['riskAttributes']),
        json['riskStatus'] as String?,
        json['riskFlagString'] as String?,
        geoData);
  }
}

class RiskAttributes {
  RiskAttributes(
      this.distance,
      this.isDifferentCountry,
      this.isKnownAbuser,
      this.isIcloudRelay,
      this.isKnownAttacker,
      this.isAnonymous,
      this.isThreat,
      this.isBogon,
      this.blocklists,
      this.isDatacenter,
      this.isTor,
      this.isProxy);

  final int? distance;
  final bool? isDifferentCountry;
  final bool? isKnownAbuser;
  final bool? isIcloudRelay;
  final bool? isKnownAttacker;
  final bool? isAnonymous;
  final bool? isThreat;
  final bool? isBogon;
  final bool? blocklists;
  final bool? isDatacenter;
  final bool? isTor;
  final bool? isProxy;

  static RiskAttributes fromJson(dynamic json) {
    return RiskAttributes(
        json['distance'] as int?,
        json['isDifferentCountry'] as bool?,
        json['isKnownAbuser'] as bool?,
        json['isIcloudRelay'] as bool?,
        json['isKnownAttacker'] as bool?,
        json['isAnonymous'] as bool?,
        json['isThreat'] as bool?,
        json['isBogon'] as bool?,
        json['blocklists'] as bool?,
        json['isDatacenter'] as bool?,
        json['isTor'] as bool?,
        json['isProxy'] as bool?);
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
