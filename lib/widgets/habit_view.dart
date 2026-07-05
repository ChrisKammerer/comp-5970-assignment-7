import 'package:flutter/material.dart';
import '../models/habit.dart';

class HabitView extends StatefulWidget {
  final Habit habit;
  final VoidCallback onSwipeComplete;

  const HabitView({
    super.key,
    required this.habit,
    required this.onSwipeComplete,
  });

  @override
  State<HabitView> createState() => _HabitViewState();
}

class _HabitViewState extends State<HabitView> {
  Offset habitOffset = Offset.zero;
  bool isAnimatingOut = false;

  static const double swipeThreshold = 120;

  void handleDragUpdate(DragUpdateDetails details) {
    if (isAnimatingOut) return;

    setState(() {
      habitOffset += details.delta;
    });
  }

  void handleDragEnd(DragEndDetails details) {
    if (isAnimatingOut) return;

    if (habitOffset.dx.abs() > swipeThreshold) {
      animateCardOut();
    } else {
      snapCardBack();
    }
  }

  void snapCardBack() {
    setState(() {
      habitOffset = Offset.zero;
    });
  }

  Future<void> animateCardOut() async {
    setState(() {
      isAnimatingOut = true;
      habitOffset = Offset(habitOffset.dx > 0 ? 500 : -500, habitOffset.dy);
    });

    await Future.delayed(const Duration(milliseconds: 200));

    if (!mounted) return;

    widget.onSwipeComplete();

    setState(() {
      habitOffset = Offset.zero;
      isAnimatingOut = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool showCompleteLabel = habitOffset.dx.abs() > 30;
    final double opacity = (1 - (habitOffset.dx.abs() / 500).clamp(0.0, 1.0)).clamp(0.2, 1.0);

    return GestureDetector(
      onHorizontalDragUpdate: handleDragUpdate,
      onHorizontalDragEnd: handleDragEnd,
      child: AnimatedContainer(
        duration: isAnimatingOut || habitOffset == Offset.zero
            ? const Duration(milliseconds: 200)
            : Duration.zero,
        curve: Curves.easeOut,
        transform: Matrix4.identity()
          ..translateByDouble(habitOffset.dx, habitOffset.dy, 0, 1),
        child: Opacity(
          opacity: opacity,
          child: HabitBody(
            habit: widget.habit,
            showCompleteLabel: showCompleteLabel,
          ),
        ),
      ),
    );
  }
}

class HabitBody extends StatelessWidget {
  final Habit habit;
  final bool showCompleteLabel;

  const HabitBody({
    super.key,
    required this.habit,
    required this.showCompleteLabel,
  });

  @override
  Widget build(BuildContext context) {
    final String text = habit.text;
    final Color backgroundColor = Colors.white;
    final Color textColor = Colors.black54;

    return Container(
      width: double.infinity,
      constraints: const BoxConstraints(maxHeight: 200),
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
        alignment: Alignment.center,
        children: [
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
          if (showCompleteLabel)
            const IgnorePointer(
              child: Center(
                child: SwipeLabel(
                  text: 'DONE',
                  color: Colors.green,
                ),
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

  const SwipeLabel({
    super.key,
    required this.text,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.35,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.transparent,
          border: Border.all(color: color, width: 6),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 28,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.5,
          ),
        ),
      ),
    );
  }
}
