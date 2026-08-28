import 'package:shared_preferences/shared_preferences.dart';

class PreferencesService {
  static const _keyShiftMinutes = 'last_shift_duration_minutes';

  Future<void> saveShiftDuration(Duration duration) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyShiftMinutes, duration.inMinutes);
  }

  Future<Duration> loadShiftDuration({Duration fallback = const Duration(hours: 6, minutes: 30)}) async {
    final prefs = await SharedPreferences.getInstance();
    final mins = prefs.getInt(_keyShiftMinutes);
    return mins != null ? Duration(minutes: mins) : fallback;
  }
}
