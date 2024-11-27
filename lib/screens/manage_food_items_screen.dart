import 'package:flutter/material.dart';
import '../database/db_helper.dart';

import '../models/food_item.dart';

class ManageFoodItemsScreen extends StatefulWidget {
  const ManageFoodItemsScreen({Key? key}) : super(key: key);

  @override
  _ManageFoodItemsScreenState createState() => _ManageFoodItemsScreenState();
}

class _ManageFoodItemsScreenState extends State<ManageFoodItemsScreen> {

  final DBHelper _dbHelper = DBHelper.instance;
  List<FoodItem> foodItems = [];

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _costController = TextEditingController();

  int? _editingId;

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

  void _saveFoodItem() async {

    final name = _nameController.text.trim();
    final cost = double.tryParse(_costController.text.trim()) ?? 0.0;

    if (name.isEmpty || cost <= 0) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(content: Text('Please enter valid name and cost.')),
      );
      return;

    }

    if (_editingId == null) {

      await _dbHelper.insert({
        'name': name,
        'cost': cost,

      });
    } else {
      await _dbHelper.update({

        '_id': _editingId,
        'name': name,
        'cost': cost,

      });
      _editingId = null;
    }

    _nameController.clear();
    _costController.clear();

    _fetchFoodItems();

    ScaffoldMessenger.of(context).showSnackBar(

      const SnackBar(content: Text('Food item saved successfully!')),
    );
  }

  void _editFoodItem(FoodItem item) {
    setState(() {
      _editingId = item.id;

      _nameController.text = item.name;
      _costController.text = item.cost.toString();
    });
  }

  void _deleteFoodItem(int id) async {
    await _dbHelper.delete(id);

    _fetchFoodItems();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Food item deleted successfully!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Food Items'),
      ),
      backgroundColor: Colors.tealAccent,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Food Name',
                  ),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: _costController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: 'Food Cost',
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: _saveFoodItem,
                  child: Text(_editingId == null ? 'Add Food Item' : 'Update Food Item'),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: ListView.builder(
              itemCount: foodItems.length,
              itemBuilder: (context, index) {
                final item = foodItems[index];
                return ListTile(
                  title: Text(item.name),
                  subtitle: Text('\$${item.cost.toStringAsFixed(2)}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () => _editFoodItem(item),
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _deleteFoodItem(item.id),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
