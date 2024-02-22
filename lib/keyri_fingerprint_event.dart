/// Class which represents fingerprint event type.
class EventType {
  EventType(this.name, {this.metadata});

  final String name;
  Map<String, dynamic>? metadata;

  /// Returns Visits event.
  static EventType visits({Map<String, dynamic>? metadata}) =>
      EventType("visits", metadata: metadata);

  /// Returns Login event.
  static EventType login({Map<String, dynamic>? metadata}) =>
      EventType("login", metadata: metadata);

  /// Returns signup event.
  static EventType signup({Map<String, dynamic>? metadata}) =>
      EventType("signup", metadata: metadata);

  /// Returns Attach new device event.
  static EventType attachNewDevice({Map<String, dynamic>? metadata}) =>
      EventType("attach_new_device", metadata: metadata);

  /// Returns Email change event.
  static EventType emailChange({Map<String, dynamic>? metadata}) =>
      EventType("emailChange", metadata: metadata);

  /// Returns Profile update event.
  static EventType profileUpdate({Map<String, dynamic>? metadata}) =>
      EventType("profile_update", metadata: metadata);

  /// Returns Password reset event.
  static EventType passwordReset({Map<String, dynamic>? metadata}) =>
      EventType("password_reset", metadata: metadata);

  /// Returns Withdrawal event.
  static EventType withdrawal({Map<String, dynamic>? metadata}) =>
      EventType("withdrawal", metadata: metadata);

  /// Returns Deposit event.
  static EventType deposit({Map<String, dynamic>? metadata}) =>
      EventType("deposit", metadata: metadata);

  /// Returns Purchase event.
  static EventType purchase({Map<String, dynamic>? metadata}) =>
      EventType("purchase", metadata: metadata);

  /// Returns Custom event.
  static EventType custom(String name, {Map<String, dynamic>? metadata}) =>
      EventType(name, metadata: metadata);
}
