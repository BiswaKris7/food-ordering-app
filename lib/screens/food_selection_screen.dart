import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/food_item.dart';
import 'order_query_screen.dart';

class FoodSelectionScreen extends StatefulWidget {
  const FoodSelectionScreen({Key? key}) : super(key: key);

  @override
  _FoodSelectionScreenState createState() => _FoodSelectionScreenState();
}

class _FoodSelectionScreenState extends State<FoodSelectionScreen> {

  final DBHelper _dbHelper = DBHelper.instance;
  List<FoodItem> foodItems = [];
  List<FoodItem> selectedItems = [];
  double targetCost = 0.0;

  @override
  void initState() {

    super.initState();
    _fetchFoodItems();

  }

  Future<void> _fetchFoodItems() async {

    final data = await _dbHelper.queryAllRows();
    setState(() {
      foodItems = data.map((item) => FoodItem.fromMap(item)).toList();
    });
  }

  void _saveOrderPlan() async {

    if (selectedItems.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one food item.')),
      );
      return;
    }

    final date = DateTime.now().toIso8601String().split('T').first;

    final selectedItemsJson = selectedItems.map((item) => item.id).toList().toString();

    await _dbHelper.insertOrderPlan(date, selectedItemsJson);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Order plan for $date saved successfully!')),
    );

    setState(() {
      selectedItems.clear();
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Food Items'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Target Cost:'),
                const SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        targetCost = double.tryParse(value) ?? 0.0;
                      });
                    },
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: 'Enter target cost',
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                  trailing: Checkbox(
                    value: selectedItems.contains(item),
                    onChanged: (isSelected) {
                      setState(() {
                        if (isSelected == true) {

                          selectedItems.add(item);

                        } else {
                          selectedItems.remove(item);
                        }
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                ElevatedButton(
                  onPressed: _saveOrderPlan,
                  child: const Text('Save Order Plan'),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const OrderQueryScreen(),
                      ),
                    );
                  },
                  child: const Text('Query Order Plans'),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
