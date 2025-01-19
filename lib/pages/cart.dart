import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CartProvider with ChangeNotifier {
  List<Map<String, dynamic>> _cartItems = [];

  List<Map<String, dynamic>> get cartItems => _cartItems;

  int get cartItemCount => _cartItems.fold<int>(
      0, (total, item) => total + (item['quantity'] as int));

  // Helper method to safely parse stock value
  int _parseStock(dynamic stockValue) {
    if (stockValue == null) return 0;
    if (stockValue is int) return stockValue;
    if (stockValue is String) {
      return int.tryParse(stockValue) ?? 0;
    }
    return 0;
  }

  Future<bool> addToCart(Map<String, dynamic> item) async {
    // Check if item already exists in cart
    final existingItem = _cartItems.firstWhere(
      (cartItem) => cartItem['id'] == item['id'],
      orElse: () => {},
    );

    // Get reference to Firestore
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentReference obatRef = firestore.collection('obat').doc(item['id']);

    try {
      bool success = await firestore.runTransaction<bool>((transaction) async {
        DocumentSnapshot snapshot = await transaction.get(obatRef);
        
        if (!snapshot.exists) {
          throw Exception('Obat tidak ditemukan!');
        }

        Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
        // Use the helper method to parse stock
        int currentStock = _parseStock(data['stok']);

        // Check if there's enough stock
        if (currentStock <= 0) {
          throw Exception('Stok habis!');
        }

        // If item exists in cart, check if there's enough stock for additional quantity
        if (existingItem.isNotEmpty && currentStock <= _parseStock(existingItem['quantity'])) {
          throw Exception('Stok tidak mencukupi!');
        }

        // Decrease stock by 1
        transaction.update(obatRef, {'stok': (currentStock - 1).toString()});

        return true;
      });

      if (success) {
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
        return true;
      }
      return false;
    } catch (e) {
      print('Error adding to cart: $e');
      return false;
    }
  }

  Future<void> updateQuantity(String id, int newQuantity) async {
    final index = _cartItems.indexWhere((item) => item['id'] == id);
    if (index != -1) {
      final currentQuantity = _cartItems[index]['quantity'] as int;
      final quantityDiff = newQuantity - currentQuantity;

      if (quantityDiff != 0) {
        try {
          FirebaseFirestore firestore = FirebaseFirestore.instance;
          DocumentReference obatRef = firestore.collection('obat').doc(id);

          await firestore.runTransaction((transaction) async {
            DocumentSnapshot snapshot = await transaction.get(obatRef);
            
            if (!snapshot.exists) {
              throw Exception('Obat tidak ditemukan!');
            }

            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            int currentStock = _parseStock(data['stok']);

            // If increasing quantity, check if enough stock
            if (quantityDiff > 0 && currentStock < quantityDiff) {
              throw Exception('Stok tidak mencukupi!');
            }

            // Update stock
            transaction.update(obatRef, {
              'stok': (currentStock - quantityDiff).toString()
            });
          });

          // Update cart quantity after successful stock update
          if (newQuantity > 0) {
            _cartItems[index]['quantity'] = newQuantity;
          } else {
            _cartItems.removeAt(index);
          }
          notifyListeners();
        } catch (e) {
          print('Error updating quantity: $e');
          throw e;
        }
      }
    }
  }

  int calculateTotalHarga() {
    return _cartItems.fold<int>(0, (total, item) {
      int harga = int.tryParse(item['harga'].toString()) ?? 0;
      int quantity = (item['quantity'] ?? 0) as int;
      return total + (harga * quantity);
    });
  }

  Future<void> clearCart() async {
    for (var item in _cartItems) {
      try {
        FirebaseFirestore firestore = FirebaseFirestore.instance;
        DocumentReference obatRef = firestore.collection('obat').doc(item['id']);
        
        await firestore.runTransaction((transaction) async {
          DocumentSnapshot snapshot = await transaction.get(obatRef);
          
          if (snapshot.exists) {
            Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
            int currentStock = _parseStock(data['stok']);
            int quantity = item['quantity'] as int;

            // Restore stock based on quantity
            transaction.update(obatRef, {
              'stok': (currentStock + quantity).toString()
            });
          }
        });
      } catch (e) {
        print('Error restoring stock for item ${item['id']}: $e');
      }
    }
    
    _cartItems.clear();
    notifyListeners();
  }
}