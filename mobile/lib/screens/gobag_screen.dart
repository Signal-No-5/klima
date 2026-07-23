import 'package:flutter/material.dart';
import '../models/gobag_item.dart';
import '../services/storage_service.dart';
import '../constants/mock_data.dart';
import '../providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'learning_screen.dart';

class GoBagScreen extends StatefulWidget {
  const GoBagScreen({super.key});

  @override
  State<GoBagScreen> createState() => _GoBagScreenState();
}

class _GoBagScreenState extends State<GoBagScreen> {
  List<GoBagItem> _items = [];
  Map<String, List<GoBagItem>> _groupedItems = {};

  @override
  void initState() {
    super.initState();
    _loadItems();
  }

  Future<void> _loadItems() async {
    var items = StorageService.getGoBagItems();
    if (items.isEmpty) {
      items = MockData.getDefaultGoBagItems();
      await StorageService.saveGoBagItems(items);
    }

    setState(() {
      _items = items;
      _groupItems();
    });
  }

  void _groupItems() {
    _groupedItems = {};
    for (final item in _items) {
      if (!_groupedItems.containsKey(item.category)) {
        _groupedItems[item.category] = [];
      }
      _groupedItems[item.category]!.add(item);
    }
  }

  Future<void> _toggleItem(GoBagItem item) async {
    final updatedItem = item.copyWith(isChecked: !item.isChecked);
    final userProvider = context.read<UserProvider>();
    final messenger = ScaffoldMessenger.of(context);

    await StorageService.updateGoBagItem(updatedItem);
    await _loadItems();

    // Check if all items are completed
    if (_items.every((i) => i.isChecked)) {
      await userProvider.addBadge('ready_ka_na');

      if (mounted) {
        messenger.showSnackBar(
          const SnackBar(
            content: Text('🎒 Badge Earned: Ready Ka Na!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  double get _completionPercentage {
    if (_items.isEmpty) return 0;
    final completed = _items.where((i) => i.isChecked).length;
    return completed / _items.length;
  }

  @override
  Widget build(BuildContext context) {
    final completed = _items.where((i) => i.isChecked).length;
    final total = _items.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('🎒 My Go-Bag'),
        actions: [
          IconButton(
            icon: const Icon(Icons.school),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const LearningScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress Card
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.blue.shade50,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Readiness Progress',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$completed / $total',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: _completionPercentage,
                  minHeight: 8,
                  backgroundColor: Colors.grey.shade300,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    _completionPercentage == 1.0 ? Colors.green : Colors.blue,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  _completionPercentage == 1.0
                      ? '✅ All set! You\'re ready!'
                      : 'Keep going! You\'re ${(_completionPercentage * 100).toStringAsFixed(0)}% ready',
                  style: TextStyle(
                    color: _completionPercentage == 1.0
                        ? Colors.green
                        : Colors.black87,
                  ),
                ),
              ],
            ),
          ),

          // Checklist
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(8),
              children: _groupedItems.entries.map((entry) {
                return _buildCategorySection(entry.key, entry.value);
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategorySection(String category, List<GoBagItem> items) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: ExpansionTile(
        title: Text(
          _getCategoryLabel(category),
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        subtitle: Text(
            '${items.where((i) => i.isChecked).length} / ${items.length} items'),
        children: items.map((item) {
          return CheckboxListTile(
            title: Text(item.name),
            subtitle: Text(item.description),
            secondary: Text(
              item.icon ?? '📦',
              style: const TextStyle(fontSize: 24),
            ),
            value: item.isChecked,
            onChanged: (value) => _toggleItem(item),
          );
        }).toList(),
      ),
    );
  }

  String _getCategoryLabel(String category) {
    switch (category) {
      case 'documents':
        return '📄 Important Documents';
      case 'food':
        return '🍱 Food & Water';
      case 'medical':
        return '⚕️ Medical Supplies';
      case 'tools':
        return '🔧 Tools & Equipment';
      case 'clothing':
        return '👕 Clothing & Shelter';
      case 'communication':
        return '📱 Communication';
      case 'others':
        return '🛍️ Other Essentials';
      default:
        return category.toUpperCase();
    }
  }
}
