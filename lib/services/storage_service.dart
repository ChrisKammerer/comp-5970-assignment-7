import 'dart:convert';
import 'package:habit_tracker/models/habit.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _habitListKey = 'habit_list';
  static const String _habitTotalKey = 'habit_total_count';
  static const String _habitCompletedKey = 'habit_completed_count';

  Future<void> saveHabitList(List<Habit> habitList) async {
    final prefs = await SharedPreferences.getInstance();
    final habitListJson = jsonEncode(habitList.map((habit) => habit.toMap()).toList());
    await prefs.setString(_habitListKey, habitListJson);
  }

  Future<List<Habit>> loadHabitList() async {
    final prefs = await SharedPreferences.getInstance();
    final habitListJson = prefs.getString(_habitListKey);
    if (habitListJson != null) {
      final List<dynamic> decodedList = jsonDecode(habitListJson);
      return decodedList.map((json) => Habit.fromMap(json)).toList();
    }
    return [];
  }

  Future<void> saveHabitSummary({required int totalCount, required int completedCount}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_habitTotalKey, totalCount);
    await prefs.setInt(_habitCompletedKey, completedCount);
  }

  Future<int> loadHabitTotalCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_habitTotalKey) ?? 0;
  }

  Future<int> loadHabitCompletedCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_habitCompletedKey) ?? 0;
  }
}