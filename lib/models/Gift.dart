class Gift {
  // attributes of a Gift
  String name;
  String category;
  double price;
  String status;
  String? description;

  Gift({
    required this.name,
    required this.category,
    required this.price,
    required this.status,
    this.description,
  });
}
