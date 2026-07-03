import 'dart:math';
import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitView extends StatefulWidget {
  final Habit habit;
  final VoidCallback onSwipeRight; // completed
  final VoidCallback onSwipeLeft; // come back to task

  const HabitView({
    super.key,
    required this.habit,
    required this.onSwipeRight,
    required this.onSwipeLeft,
  });

  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  Offset habitOffset = Offset.zero;
  bool isAnimatingOut = false;
  bool isCompleted = false;

  static const double swipeThreshold = 120;

  void handleDragUpdate(DragUpdateDetails details) {
    if (isAnimatingOut) return;

    setState(() {
      habitOffset += details.delta;
    });
  }

  void handleDragEnd(DragEndDetails details) {
    if (isAnimatingOut) return;

    if (habitOffset.dx > swipeThreshold) {
      animateCardOut(isComplete: true);
    } else if (habitOffset.dx < -swipeThreshold) {
      animateCardOut(isComplete: false);
    } else {
      snapCardBack();
    }
  }

  void snapCardBack() {
    setState(() {
      habitOffset = Offset.zero;
    });
  }

  Future<void> animateCardOut({required bool isComplete}) async {
    setState(() {
      isAnimatingOut = true;
      habitOffset = Offset(isComplete ? 500 : -500, habitOffset.dy);
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    if (isComplete) {
      widget.onSwipeRight();
    } else {
      widget.onSwipeLeft();
    }

    setState(() {
      habitOffset = Offset.zero;
      isAnimatingOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double swipeRotation = (habitOffset.dx / 350).clamp(-0.35, 0.35);
    final bool showCompleteLabel = habitOffset.dx > 30;
    final bool showTodoLabel = habitOffset.dx < -30;

    return GestureDetector(
      onPanUpdate: handleDragUpdate,
      onPanEnd: handleDragEnd,
      child: AnimatedContainer(
        duration: isAnimatingOut || habitOffset == Offset.zero
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(habitOffset.dx, habitOffset.dy, 0, 1)
          ..rotateZ(swipeRotation),
        child: HabitBody(
          habit: widget.habit,
          isComplete: widget.habit.isComplete,
          showCompleteLabel: showCompleteLabel,
          showTodoLabel: showTodoLabel,
        ),
      ),
    );
  }
}

class HabitBody extends StatelessWidget {
  final Habit habit;
  final bool isComplete;
  final bool showCompleteLabel;
  final bool showTodoLabel;

  const HabitBody({
    super.key,
    required this.habit,
    required this.isComplete,
    required this.showCompleteLabel,
    required this.showTodoLabel,
  });

  @override
  Widget build(BuildContext context) {
    final String text = habit.text;
    final Color backgroundColor = Colors.white;
    final Color textColor = Colors.black54;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 240),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
            color: Color(0x22000000),
            blurRadius: 24,
            offset: Offset(0, 12),
          ),
        ],
      ),
      child: Stack(
        children: [
          if (showCompleteLabel)
            const Positioned(
              top: 0,
              right: 0,
              child: SwipeLabel(
                text: 'COMPLETED',
                color: Colors.green,
                angle: -pi / 14,
              ),
            ),
          if (showTodoLabel)
            const Positioned(
              top: 0,
              right: 0,
              child: SwipeLabel(
                text: "TO-DO",
                color: Colors.red,
                angle: pi / 14,
              ),
            ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  text,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: textColor,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    height: 1.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class SwipeLabel extends StatelessWidget {
  final String text;
  final Color color;
  final double angle;

  const SwipeLabel({
    super.key,
    required this.text,
    required this.color,
    required this.angle,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: angle,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          border: Border.all(color: color, width: 4),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1,
          ),
        ),
      ),
    );
  }
}
