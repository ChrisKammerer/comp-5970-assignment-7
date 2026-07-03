class Habit {
  final int id;
  final String text;
  bool isComplete;

  Habit({required this.id, required this.text, this.isComplete = false});
}
