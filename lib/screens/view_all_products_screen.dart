import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:synque_work/constants/constants.dart';
import 'package:synque_work/data/models/product_model.dart';
import 'package:synque_work/screens/crud/create_products_screen.dart';

class ViewAllProductsScreen extends StatefulWidget {
  const ViewAllProductsScreen({super.key});

  @override
  State<ViewAllProductsScreen> createState() => _ViewAllProductsScreenState();
}

class _ViewAllProductsScreenState extends State<ViewAllProductsScreen> {
  late Future<List<ProductModel>> futureProducts;

  // Function to fetch all products
  Future<List<ProductModel>> fetchAllProducts() async {
    final response =
        await http.get(Uri.parse("${AppConstants.baseUrl}products/"));

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body) as List;
      final allProducts =
          jsonData.map((product) => ProductModel.fromJson(product)).toList();
      return allProducts;
    } else {
      throw Exception('Failed to load products');
    }
  }

  @override
  void initState() {
    super.initState();
    futureProducts = fetchAllProducts();
  }

  // Method to refresh the products list
  void refreshProducts() {
    setState(() {
      futureProducts = fetchAllProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View All Products'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Navigate to AddProductScreen and wait for the result (refresh trigger)
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddProductScreen(),
            ),
          );

          // Refresh the product list if a product was added
          if (result == true) {
            refreshProducts();
          }
        },
        child: const Icon(Icons.add_outlined),
      ),
      body: FutureBuilder<List<ProductModel>>(
        future: futureProducts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No products found'));
          } else {
            final products = snapshot.data!;
            return ListView.builder(
              itemCount: products.length,
              itemBuilder: (BuildContext context, int index) {
                final product = products[index];
                return Card(
                  child: ListTile(
                    leading: Image.network(product.image,
                        height: 60, width: 60, fit: BoxFit.contain),
                    title: Text(product.title),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
