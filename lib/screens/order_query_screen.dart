import 'dart:convert';
import 'package:flutter/material.dart';

import '../database/db_helper.dart';
import '../models/food_item.dart';

class OrderQueryScreen extends StatefulWidget {
  const OrderQueryScreen({Key? key}) : super(key: key);

  @override
  _OrderQueryScreenState createState() => _OrderQueryScreenState();
}

class _OrderQueryScreenState extends State<OrderQueryScreen> {

  final DBHelper _dbHelper = DBHelper.instance;
  List<Map<String, dynamic>> orderPlans = [];
  List<List<FoodItem>> detailedOrderPlans = [];

  String queryDate = '';

  void _queryOrderPlans() async {
    if (queryDate.isEmpty) return;

    final data = await _dbHelper.queryOrderPlans(queryDate);

    List<List<FoodItem>> orders = [];

    for (var plan in data) {

      List<dynamic> itemIds = jsonDecode(plan['selected_items']);
      List<Map<String, dynamic>> foodData = await _dbHelper.queryAllRows();

      List<FoodItem> items = foodData

          .where((row) => itemIds.contains(row['_id']))
          .map((row) => FoodItem.fromMap(row))
          .toList();

      orders.add(items);
    }

    setState(() {

      orderPlans = data;
      detailedOrderPlans = orders;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: const Text('Query Order Plans'),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.lightBlueAccent, Colors.deepPurpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  const Text('Date (YYYY-MM-DD):', style: TextStyle(color: Colors.white)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      onChanged: (value) {
                        queryDate = value;
                      },
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Enter date',
                        fillColor: Colors.white,
                        filled: true,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.search, color: Colors.white),
                    onPressed: _queryOrderPlans,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: orderPlans.length,
                itemBuilder: (context, index) {
                  final plan = orderPlans[index];
                  final items = detailedOrderPlans[index];
                  return Card(
                    margin: const EdgeInsets.all(8.0),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Order Plan #${plan['_id']}',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          ...items.map((item) => Text(
                            '${item.name} - \$${item.cost.toStringAsFixed(2)}',
                          )),
                          const SizedBox(height: 8),
                          Text(
                            'Date: ${plan['date']}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
