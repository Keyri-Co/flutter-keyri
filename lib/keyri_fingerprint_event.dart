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
