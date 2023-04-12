import 'dart:convert';
import 'dart:ffi';

enum EventType {
  visits,
  login,
  signup,
  attach_new_device,
  email_change,
  profile_update,
  password_reset,
  withdrawal,
  deposit,
  purchase;
}

enum FingerprintLogResult { success, fail, incomplete }

class BaseFingerprintEventResponse {
  BaseFingerprintEventResponse(this.result, this.error, this.data);

  final bool result;
  final String? error;
  final FingerprintEventResponse? data;

  static BaseFingerprintEventResponse fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    var fingerprintEventResponseJson = jsonData['data'];

    FingerprintEventResponse? fingerprintEventResponse;

    if (fingerprintEventResponseJson != null) {
      fingerprintEventResponse =
          FingerprintEventResponse.fromJson(fingerprintEventResponseJson);
    }

    return BaseFingerprintEventResponse(
        json['result'] as bool? ?? fingerprintEventResponse != null,
        json['error'] as String?,
        fingerprintEventResponse);
  }
}

class FingerprintEventResponse {
  FingerprintEventResponse(
      this.id,
      this.event,
      this.location,
      this.ip,
      this.result,
      this.signals,
      this.fingerprintId,
      this.applicationId,
      this.userId,
      this.updatedAt,
      this.createdAt);

  final String? id;
  final String? event;
  final FingerprintLocation? location;
  final String? ip;
  final String? result;
  final List<String>? signals;
  final String? fingerprintId;
  final String? applicationId;
  final String? userId;
  final String? updatedAt;
  final String? createdAt;

  static FingerprintEventResponse fromJson(dynamic json) {
    dynamic jsonData = json;

    try {
      String jsonDataString = json.toString();
      jsonData = jsonDecode(jsonDataString);
    } catch (e) {
      jsonData = json;
    }

    var fingerprintLocationJson = jsonData['location'];

    FingerprintLocation? fingerprintLocation;

    if (fingerprintLocationJson != null) {
      fingerprintLocation =
          FingerprintLocation.fromJson(fingerprintLocationJson);
    }

    return FingerprintEventResponse(
      json['id'] as String?,
      json['event'] as String?,
      fingerprintLocation,
      json['ip'] as String?,
      json['result'] as String?,
      json['signals'] as List<String>?,
      json['fingerprintId'] as String?,
      json['applicationId'] as String?,
      json['userId'] as String?,
      json['updatedAt'] as String?,
      json['createdAt'] as String?,
    );
  }
}

class FingerprintLocation {
  FingerprintLocation(this.city, this.country, this.countryCode,
      this.continentName, this.continentCode, this.latitude, this.longitude);

  final String? city;
  final String? country;
  final String? countryCode;
  final String? continentName;
  final String? continentCode;
  final Double? latitude;
  final Double? longitude;

  static FingerprintLocation fromJson(dynamic json) {
    return FingerprintLocation(
        json['city'] as String?,
        json['country'] as String?,
        json['countryCode'] as String?,
        json['continentName'] as String? ?? json['continent_name'] as String?,
        json['continentCode'] as String? ?? json['continent_code'] as String?,
        json['latitude'] as Double?,
        json['longitude'] as Double?);
  }
}
