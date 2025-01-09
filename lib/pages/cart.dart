import 'package:flutter/material.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get cartItemCount => _cartItems.fold<int>(
      0, (total, item) => total + (item['quantity'] as int));

  void addToCart(Map<String, dynamic> item) {
    final existingItem = _cartItems.firstWhere(
      (cartItem) => cartItem['id'] == item['id'],
      orElse: () => {},
    );

    if (existingItem.isNotEmpty) {
      existingItem['quantity'] += 1;
    } else {
      _cartItems.add({
        'id': item['id'],
        'nama': item['nama'],
        'harga': int.tryParse(item['harga'].toString()) ?? 0,
        'pict': item['pict'],
        'quantity': 1,
      });
    }
    notifyListeners();
  }

  void updateQuantity(String id, int newQuantity) {
    final index = _cartItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      if (newQuantity > 0) {
        _cartItems[index]['quantity'] = newQuantity;
      } else {
        _cartItems.removeAt(index);
      }
      notifyListeners();
    }
  }

  int calculateTotalHarga() {
    return _cartItems.fold<int>(0, (total, item) {
      int harga = int.tryParse(item['harga'].toString()) ?? 0;
      int quantity = (item['quantity'] ?? 0) as int;
      return total + (harga * quantity);
    });
  }
}
