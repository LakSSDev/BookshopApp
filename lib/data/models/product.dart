

class Product {

  int? id;
  String? name;
  double? price;
  int? stock;

  Product({
    this.id, 
    required this.name, 
    required this.price, 
    required this.stock
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'stock': stock
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'],
      name: map['name'],
      price: map['price'],
      stock: map['stock']
    );
  }
}