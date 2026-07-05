import 'package:flutter/material.dart';

import '../data/habit_data.dart';
import '../models/habit.dart';
import '../widgets/habit_view.dart';
import '../services/storage_service.dart';

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  final StorageService storageService = StorageService();
  List<Habit> habitList = [];
  bool isLoading = true;
  int totalHabitCount = 0;
  int completedCount = 0;
  bool isComplete = false;

  @override
  void initState() {
    super.initState();
    _loadHabitList();
  }

  Future<void> _loadHabitList() async {
    final loadedHabits = await storageService.loadHabitList();
    final storedTotal = await storageService.loadHabitTotalCount();
    final storedCompleted = await storageService.loadHabitCompletedCount();

    if (loadedHabits.isEmpty && storedTotal == 0) {
      final defaultHabits = habitsData
          .map(
            (habit) => Habit(
              id: habit.id,
              text: habit.text,
              isComplete: habit.isComplete,
            ),
          )
          .toList();
      setState(() {
        habitList = defaultHabits;
        totalHabitCount = defaultHabits.length;
        completedCount = 0;
        isLoading = false;
        isComplete = habitList.isEmpty;
      });
      await storageService.saveHabitList(habitList);
      await storageService.saveHabitSummary(
        totalCount: totalHabitCount,
        completedCount: completedCount,
      );
      return;
    }

    setState(() {
      habitList = loadedHabits;
      totalHabitCount = storedTotal > 0 ? storedTotal : habitList.length;
      completedCount = storedCompleted;
      isComplete = habitList.isEmpty;
      isLoading = false;
    });
  }

  Future<void> restartSession() async {
    setState(() {
      completedCount = 0;
      habitList = habitsData
          .map(
            (habit) => Habit(
              id: habit.id,
              text: habit.text,
              isComplete: habit.isComplete,
            ),
          )
          .toList();
      totalHabitCount = habitList.length;
      isComplete = false;
    });

    for (final habit in habitList) {
      habit.isComplete = false;
    }

    await storageService.saveHabitList(habitList);
    await storageService.saveHabitSummary(
      totalCount: totalHabitCount,
      completedCount: completedCount,
    );
  }

  Future<void> markHabitAsComplete(int habitId) async {
    final index = habitList.indexWhere((habit) => habit.id == habitId);
    if (index == -1) {
      return;
    }

    setState(() {
      final habitToComplete = habitList[index];
      habitToComplete.isComplete = true;
      completedCount++;
      habitList.removeAt(index);
      isComplete = habitList.isEmpty;
    });

    await storageService.saveHabitList(habitList);
    await storageService.saveHabitSummary(
      totalCount: totalHabitCount,
      completedCount: completedCount,
    );
  }

  void markDayComplete() {
    if (habitList.isEmpty) return;

    setState(() {
      isComplete = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await restartSession();
          },
          child: ListView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.all(18),
            children: [
              const Text(
                'Habit Tracker',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 22),
              const Text(
                'Swipe either direction to complete and remove a habit. Pull down to restart the session.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 18),
              Text(
                'Habits Completed: $completedCount / $totalHabitCount',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else if (isComplete || habitList.isEmpty)
                CompletionPanel(
                  completedCount: completedCount,
                  remainingCount: habitList.length,
                )
              else
                Column(
                  children: [
                    for (final habit in habitList)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: HabitView(
                          key: ValueKey(habit.id),
                          habit: habit,
                          onSwipeComplete: () => markHabitAsComplete(habit.id),
                        ),
                      ),
                  ],
                ),
              if (!isLoading && !isComplete) ...[
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: markDayComplete,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Mark Day Complete',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionPanel extends StatelessWidget {
  final int completedCount;
  final int remainingCount;
  // final VoidCallback onRestart;
  const CompletionPanel({
    super.key,
    required this.completedCount,
    required this.remainingCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Day Summary',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Habits Completed: $completedCount',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Habits Unfinished: $remainingCount',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
        ],
      ),
    );
  }
}
