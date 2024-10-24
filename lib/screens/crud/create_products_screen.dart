import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:synque_work/constants/constants.dart';
import 'package:synque_work/data/models/product_model.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController categoryController = TextEditingController();
  final TextEditingController imageController = TextEditingController();
  final key = GlobalKey<FormState>();

  List<ProductModel> storeData = [];

  Future<void> addProduct() async {
    if (key.currentState!.validate()) {
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}products/'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'title': titleController.text,
          'description': descriptionController.text,
          'price': double.tryParse(priceController.text) ?? 0.0,
          'category': categoryController.text,
          'image': imageController.text,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        final newProduct = ProductModel.fromJson(jsonData);
        setState(() {
          storeData.add(newProduct);
        });
      } else {
        print('Failed to add product: ${response.body}');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Product'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Create a New Product",
              style: TextStyle(
                fontSize: 24.0,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTextField(
                    controller: titleController,
                    label: 'Product Title',
                    hint: 'Enter Product Title',
                    icon: Icons.title,
                  ),
                  _buildTextField(
                    controller: descriptionController,
                    label: 'Product Description',
                    hint: 'Enter Product Description',
                    icon: Icons.description,
                    maxLines: 3,
                  ),
                  _buildTextField(
                    controller: priceController,
                    label: 'Price',
                    hint: 'Enter Product Price',
                    icon: Icons.attach_money,
                    keyboardType: TextInputType.number,
                  ),
                  _buildTextField(
                    controller: categoryController,
                    label: 'Category',
                    hint: 'Enter Product Category',
                    icon: Icons.category,
                  ),
                  _buildTextField(
                    controller: imageController,
                    label: 'Image URL',
                    hint: 'Enter Image URL',
                    icon: Icons.image,
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: ElevatedButton.icon(
                      onPressed: addProduct,
                      icon: const Icon(Icons.add),
                      label: const Text("Add Product"),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 15.0, horizontal: 30.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10)),
                        textStyle: const TextStyle(fontSize: 18.0),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 30),
            const Text(
              "Added Products:",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.blueAccent,
              ),
            ),
            const SizedBox(height: 10),
            _buildProductList(),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    IconData? icon,
    int maxLines = 1,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
        keyboardType: keyboardType,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildProductList() {
    if (storeData.isEmpty) {
      return const Center(
        child: Text(
          'No products added yet',
          style: TextStyle(fontSize: 16.0),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: storeData.length,
      itemBuilder: (context, index) {
        final product = storeData[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.symmetric(vertical: 10.0),
          child: ListTile(
            contentPadding: const EdgeInsets.all(15.0),
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: Image.network(
                product.image ?? '',
                width: 60,
                height: 60,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.error);
                },
              ),
            ),
            title: Text(
              product.title ?? 'No Title',
              style:
                  const TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Price: \$${product.price?.toStringAsFixed(2) ?? '0.00'}",
                  style: const TextStyle(fontSize: 16.0),
                ),
                Text(
                  "Category: ${product.category}",
                  style: const TextStyle(fontSize: 16.0),
                ),
              ],
            ),
            trailing: IconButton(
              onPressed: () {
                confirmDeleteProduct(product.id!);
              },
              icon: const Icon(Icons.delete),
            ),
          ),
        );
      },
    );
  }

  Future<void> confirmDeleteProduct(int productId) async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: const Text('Are you sure you want to delete this product?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              deleteProduct(productId);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> deleteProduct(int productId) async {
    final response = await http.delete(
      Uri.parse('${AppConstants.baseUrl}products/$productId'),
    );

    if (response.statusCode == 200) {
      setState(() {
        storeData.removeWhere((product) => product.id == productId);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Product deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to delete product')),
      );
    }
  }
}
