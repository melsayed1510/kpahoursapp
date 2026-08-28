enum ShiftType { a, b, c }

extension ShiftTypeX on ShiftType {
  String get label => switch (this) {
        ShiftType.a => 'A',
        ShiftType.b => 'B',
        ShiftType.c => 'C',
      };

  String get code => label;
}
