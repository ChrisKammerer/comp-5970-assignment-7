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

  int currentIndex = 0;
  int completedCount = 0;
  int get todoCount => habitList.length;

  bool isComplete = false;

  Habit get currentHabit => habitList[currentIndex];

  bool get isLastHabit => currentIndex == habitList.length - 1;

  void goToNextHabit() {
    if (isLastHabit) {
      if (habitList.isEmpty) {
        setState(() {
          isComplete = true;
        });
      } else {
        setState(() {
          currentIndex = 0;
        });
      }
    } else {
      setState(() {
        currentIndex++;
      });
    }
  }

  Future<void> restartSession() async {
    setState(() {
      currentIndex = 0;
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

  Future<void> markHabitAsComplete() async {
    if (habitList.isEmpty) {
      return;
    }

    setState(() {
      currentHabit.isComplete = true;
      completedCount++;
      habitList.removeAt(currentIndex);

      if (habitList.isEmpty) {
        isComplete = true;
        currentIndex = 0;
      } else {
        currentIndex = currentIndex.clamp(0, habitList.length - 1);
      }
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

  void markHabitAsIncomplete() {
    setState(() {
      currentHabit.isComplete = false;

      if (isLastHabit) {
        if (habitList.isEmpty) {
          isComplete = true;
        } else {
          currentIndex = 0;
        }
      } else {
        currentIndex++;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            restartSession();
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
                'Swipe right if you completed the habit, swipe left to come back to it. Pull down to restart the session.',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              const SizedBox(height: 70),
              if (isLoading)
                const Center(child: CircularProgressIndicator())
              else
                SizedBox(
                  height: MediaQuery.of(context).size.height * 0.5,
                  child: Center(
                    child: isComplete || habitList.isEmpty
                        ? CompletionPanel(
                            completedCount: completedCount,
                            remainingCount: habitList.length,
                          )
                        : HabitView(
                            key: ValueKey(currentHabit.id),
                            habit: currentHabit,
                            onSwipeLeft: markHabitAsIncomplete,
                            onSwipeRight: markHabitAsComplete,
                          ),
                  ),
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
              const SizedBox(height: 24),
              Text(
                'Habits Completed: $completedCount / $totalHabitCount',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
      ),
    ));
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
