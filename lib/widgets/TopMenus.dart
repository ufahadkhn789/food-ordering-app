import 'package:flutter/material.dart';

class TopMenus extends StatelessWidget {
  final ValueChanged<String>? onCategorySelected;

  const TopMenus({
    Key? key,
    this.onCategorySelected,
  }) : super(key: key);

  static const List<_TopMenuModel> _menus = [
    _TopMenuModel(name: 'Burger', image: 'ic_burger'),
    _TopMenuModel(name: 'Sushi', image: 'ic_sushi'),
    _TopMenuModel(name: 'Pizza', image: 'ic_pizza'),
    _TopMenuModel(name: 'Cake', image: 'ic_cake'),
    _TopMenuModel(name: 'Ice Cream', image: 'ic_ice_cream'),
    _TopMenuModel(name: 'Soft Drink', image: 'ic_soft_drink'),
  ];

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8),
        itemCount: _menus.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final menu = _menus[index];
          return TopMenuTile(
            name: menu.name,
            imageUrl: menu.image,
            onTap: () {
              if (onCategorySelected != null) {
                onCategorySelected!(menu.name);
              }
            },
          );
        },
      ),
    );
  }
}

class TopMenuTile extends StatelessWidget {
  final String name;
  final String imageUrl;
  final VoidCallback? onTap;

  const TopMenuTile({
    Key? key,
    required this.name,
    required this.imageUrl,
    this.onTap,
  }) : super(key: key);

  static const Color shadowColor = Color(0xFFfae3e2);
  static const Color textColor = Color(0xFF6e6e71);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _IconCard(imageUrl: imageUrl),
          const SizedBox(height: 4),
          Text(
            name,
            style: const TextStyle(
              color: textColor,
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
          ),
        ],
      ),
    );
  }
}

class _IconCard extends StatelessWidget {
  final String imageUrl;

  const _IconCard({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
      decoration: const BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: TopMenuTile.shadowColor,
            blurRadius: 25,
            offset: Offset(0, 0.75),
          ),
        ],
      ),
      child: Card(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(3),
        ),
        child: SizedBox(
          width: 50,
          height: 50,
          child: Center(
            child: Image.asset(
              'assets/images/topmenu/$imageUrl.png',
              width: 24,
              height: 24,
              errorBuilder: (_, __, ___) =>
              const Icon(Icons.fastfood, size: 24),
            ),
          ),
        ),
      ),
    );
  }
}

class _TopMenuModel {
  final String name;
  final String image;

  const _TopMenuModel({
    required this.name,
    required this.image,
  });
}
