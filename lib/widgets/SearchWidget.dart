import 'package:flutter/material.dart';

class SearchWidget extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const SearchWidget({
    Key? key,
    required this.onChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: TextField(
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(5),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: const Color(0xFFFAFAFA),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFFfb3132),
          ),
          suffixIcon: const Icon(
            Icons.sort,
            color: Color(0xFFfb3132),
          ),
          hintText: "What would you like to buy?",
          hintStyle: const TextStyle(
            color: Color(0xFFd0cece),
            fontSize: 18,
          ),
        ),
        onChanged: onChanged,
      ),
    );
  }
}
