import 'package:flutter/material.dart';
import '../widgets/custom_buttons.dart';

/// Screen for recommending venues after activity selection
class VenueRecommendationScreen extends StatefulWidget {
  final String? selectedActivity;

  const VenueRecommendationScreen({super.key, this.selectedActivity});

  @override
  State<VenueRecommendationScreen> createState() =>
      _VenueRecommendationScreenState();
}

class _VenueRecommendationScreenState extends State<VenueRecommendationScreen> {
  final TextEditingController _customRestaurantController =
      TextEditingController();
  String? _selectedRestaurant;
  bool _isCustom = false;

  // List of recommended venues
  final List<Map<String, dynamic>> _venues = [
    {
      'name': 'Virtual / No Venue',
      'type': 'Online / None',
      'icon': Icons.wifi,
      'color': Colors.grey,
    },
    {
      'name': 'Library',
      'type': 'Study Space',
      'icon': Icons.library_books,
      'color': Colors.blue,
    },
    {
      'name': 'Canteen 2 (LG1)',
      'type': 'Cafeteria',
      'icon': Icons.restaurant,
      'color': Colors.orange,
    },
    {
      'name': 'LG7 Food Court',
      'type': 'Food Court',
      'icon': Icons.fastfood,
      'color': Colors.red,
    },
    {
      'name': 'Starbucks',
      'type': 'Café',
      'icon': Icons.local_cafe,
      'color': Colors.green,
    },
    {
      'name': 'E²I',
      'type': 'Meeting Space',
      'icon': Icons.business,
      'color': Colors.purple,
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
            content: Text('Please enter a venue'),
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
          content: Text('Please select or enter a venue'),
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
        title: const Text('Choose a Venue'),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: const Text(
              'Confirm',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
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
                  'Recommended Venues',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                ..._venues.map((venue) {
                  final isSelected =
                      !_isCustom && _selectedRestaurant == venue['name'];
                  return _buildVenueCard(
                    name: venue['name'] as String,
                    type: venue['type'] as String,
                    icon: venue['icon'] as IconData,
                    color: venue['color'] as Color,
                    isSelected: isSelected,
                    onTap: () {
                      setState(() {
                        _selectedRestaurant = venue['name'] as String;
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
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
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
                child: PrimaryButton(
                  text: 'Confirm Selection',
                  onPressed: _confirmSelection,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: const Text(
                    'Confirm Selection',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVenueCard({
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
                child: Icon(icon, color: color, size: 32),
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
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.check_circle, color: color, size: 28)
              else
                Icon(Icons.circle_outlined, color: Colors.grey[300], size: 28),
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
          color: _isCustom
              ? Theme.of(context).colorScheme.primary
              : Colors.transparent,
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
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.edit_location_alt,
                    color: Theme.of(context).colorScheme.primary,
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
                  Icon(
                    Icons.check_circle,
                    color: Theme.of(context).colorScheme.primary,
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
