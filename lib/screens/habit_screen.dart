import 'package:flutter/material.dart';

import '../data/habit_data.dart';
import '../models/habit.dart';
import '../widgets/habit_view.dart';
// TODO: add header

class HabitScreen extends StatefulWidget {
  const HabitScreen({super.key});

  @override
  State<HabitScreen> createState() => _HabitScreenState();
}

class _HabitScreenState extends State<HabitScreen> {
  List<Habit> habitList = habitsData
      .map(
        (habit) =>
            Habit(id: habit.id, text: habit.text, isComplete: habit.isComplete),
      )
      .toList();

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

  void restartSession() {
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
      isComplete = false;
    });

    for (final habit in habitList) {
      habit.isComplete = false;
    }
  }

  void markHabitAsComplete() {
    setState(() {
      if (habitList.isEmpty) {
        return;
      }

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
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text('Placeholder'),
              const SizedBox(height: 22),
              const Text(
                'Instructions Here',
                textAlign: TextAlign.center,
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: isComplete
                      ? CompletionPanel(completedCount: completedCount)
                      : HabitView(
                          key: ValueKey(currentHabit.id),
                          habit: currentHabit,
                          onSwipeLeft: markHabitAsIncomplete,
                          onSwipeRight: markHabitAsComplete,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CompletionPanel extends StatelessWidget {
  final int completedCount;
  // final VoidCallback onRestart;
  const CompletionPanel({super.key, required this.completedCount});

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
            'Habits Complete',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            'Habits Completed: $completedCount',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
