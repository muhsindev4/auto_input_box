import 'package:auto_input_box/auto_input_box.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(
    home: InputExampleScreen(),
  ));
}

class Product {
  final String name;
  final double price;

  Product({required this.name, required this.price});
}

class InputExampleScreen extends StatelessWidget {
  final TextEditingController _stringController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  final TextEditingController _productController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    List<Product> products = [
      Product(name: "Washing Machine", price: 399.99),
      Product(name: "Refrigerator", price: 499.99),
      Product(name: "Microwave", price: 199.99),
    ];

    return Scaffold(
      appBar: AppBar(title: Text("Mixed Input Example")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // String input
              AutoInputBox<String>(
                textEditingController: _stringController,
                suggestions: ['Cat', 'Dog', 'Bird', 'Fish'],
                toDisplayString: (item) => item,
                inputDecoration: InputDecoration(
                  labelText: "Animal",
                  prefixIcon: Icon(Icons.pets),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Number input
              AutoInputBox<int>(
                textEditingController: _numberController,
                suggestions: [10, 20, 30, 40, 50],
                toDisplayString: (item) => item.toString(),
                inputDecoration: InputDecoration(
                  labelText: "Age",
                  prefixIcon: Icon(Icons.accessibility),
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),

              // Product input
              AutoInputBox<Product>(
                textEditingController: _productController,
                suggestions: products,
                toDisplayString: (product) =>
                    '${product.name} - \$${product.price}',
                inputDecoration: InputDecoration(
                  labelText: "Product",
                  prefixIcon: Icon(Icons.shopping_bag),
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
