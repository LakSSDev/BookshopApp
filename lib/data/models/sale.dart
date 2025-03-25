class Sale {
  final int? id;
  final String date; // fecha como texto (puedes usar DateTime si prefieres)
  final double total;

  Sale({this.id, required this.date, required this.total});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'total': total,
    };
  }

  factory Sale.fromMap(Map<String, dynamic> map) {
    return Sale(
      id: map['id'],
      date: map['date'],
      total: map['total'],
    );
  }
}
