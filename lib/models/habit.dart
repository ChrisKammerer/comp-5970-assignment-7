class Habit {
  final int id;
  final String text;
  bool isComplete;

  Habit({required this.id, required this.text, this.isComplete = false});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'text': text,
      'isComplete': isComplete,
    };
  }

  factory Habit.fromMap(Map<String, dynamic> map) {
    return Habit(
      id: map['id'],
      text: map['text'],
      isComplete: map['isComplete'] ?? false,
    );
  }
}
