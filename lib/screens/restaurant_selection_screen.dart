import 'package:flutter/material.dart';

/// Screen for selecting a restaurant when sending an invitation
class RestaurantSelectionScreen extends StatefulWidget {
  const RestaurantSelectionScreen({super.key});

  @override
  State<RestaurantSelectionScreen> createState() =>
      _RestaurantSelectionScreenState();
}

class _RestaurantSelectionScreenState extends State<RestaurantSelectionScreen> {
  final TextEditingController _customRestaurantController =
      TextEditingController();
  String? _selectedRestaurant;
  bool _isCustom = false;

  // List of recommended restaurants
  final List<Map<String, dynamic>> _restaurants = [
    {
      'name': 'The Coffee House',
      'type': 'Café',
      'icon': Icons.local_cafe,
      'color': Colors.brown,
    },
    {
      'name': 'Bella Italia',
      'type': 'Italian',
      'icon': Icons.restaurant,
      'color': Colors.red,
    },
    {
      'name': 'Sushi Paradise',
      'type': 'Japanese',
      'icon': Icons.set_meal,
      'color': Colors.orange,
    },
    {
      'name': 'Green Garden Cafe',
      'type': 'Healthy',
      'icon': Icons.eco,
      'color': Colors.green,
    },
    {
      'name': 'Urban Bistro',
      'type': 'Fusion',
      'icon': Icons.restaurant_menu,
      'color': Colors.purple,
    },
    {
      'name': 'The Tea Room',
      'type': 'Tea House',
      'icon': Icons.emoji_food_beverage,
      'color': Colors.teal,
    },
  ];

  @override
  void dispose() {
    _customRestaurantController.dispose();
    super.dispose();
  }

  void _confirmSelection() {
    String? restaurant;
    
    if (_isCustom) {
      final customName = _customRestaurantController.text.trim();
      if (customName.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please enter a restaurant name'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      restaurant = customName;
    } else {
      restaurant = _selectedRestaurant;
    }

    if (restaurant == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or enter a restaurant'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.pop(context, restaurant);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Choose Restaurant'),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text(
              'Confirm',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Recommended Restaurants',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                ..._restaurants.map((restaurant) {
                  final isSelected =
                      !_isCustom && _selectedRestaurant == restaurant['name'];
                  return _buildRestaurantCard(
                    name: restaurant['name'] as String,
                    type: restaurant['type'] as String,
                    icon: restaurant['icon'] as IconData,
                    color: restaurant['color'] as Color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedRestaurant = restaurant['name'] as String;
                        _isCustom = false;
                      });
                    },
                  );
                }),
                const SizedBox(height: 24),
                Divider(color: Colors.grey[300]),
                const SizedBox(height: 24),
                Text(
                  'Or Enter Your Own',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                const SizedBox(height: 16),
                _buildCustomRestaurantInput(),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: SafeArea(
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _confirmSelection,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Confirm Selection',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRestaurantCard({
    required String name,
    required String type,
    required IconData icon,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: isSelected ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isSelected ? color : Colors.transparent,
          width: 2,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 32,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      type,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: color,
                  size: 28,
                )
              else
                Icon(
                  Icons.circle_outlined,
                  color: Colors.grey[300],
                  size: 28,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomRestaurantInput() {
    return Card(
      elevation: _isCustom ? 4 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _isCustom ? Colors.blue : Colors.transparent,
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.edit_location_alt,
                    color: Colors.blue,
                    size: 32,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    'Custom Restaurant',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                if (_isCustom)
                  const Icon(
                    Icons.check_circle,
                    color: Colors.blue,
                    size: 28,
                  ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _customRestaurantController,
              decoration: InputDecoration(
                hintText: 'Enter restaurant name',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey[50],
                prefixIcon: const Icon(Icons.restaurant),
              ),
              onTap: () {
                setState(() {
                  _isCustom = true;
                  _selectedRestaurant = null;
                });
              },
              onChanged: (value) {
                if (!_isCustom) {
                  setState(() {
                    _isCustom = true;
                    _selectedRestaurant = null;
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
