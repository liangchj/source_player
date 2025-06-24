import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferencesCache {
  //创建工厂方法
  static SharedPreferencesCache? _instance;
  factory SharedPreferencesCache() =>
      _instance ??= SharedPreferencesCache._internal();
  static late final SharedPreferencesAsync asyncPrefs;

  SharedPreferencesCache._internal() {
    asyncPrefs = SharedPreferencesAsync();
  }

  SharedPreferencesAsync getAsyncPrefs() => asyncPrefs;
}
