import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:obat/pages/cart.dart';

class ShoppingCartPage extends StatefulWidget {
  @override
  _ShoppingCartPageState createState() => _ShoppingCartPageState();
}

class _ShoppingCartPageState extends State<ShoppingCartPage> {
  String? selectedPaymentMethod;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Shopping Cart', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: Container(
        color: Theme.of(context).primaryColor,
        child: Consumer<CartProvider>(
          builder: (context, cartProvider, child) {
            final cartItems = cartProvider.cartItems;

            return cartItems.isEmpty
                ? Center(
                    child: Text('Keranjang belanja kosong.',
                        style: TextStyle(color: Colors.white)))
                : Column(
                    children: [
                      Expanded(
                        child: Container(
                          child: ListView.builder(
                            itemCount: cartItems.length,
                            itemBuilder: (context, index) {
                              final item = cartItems[index];
                              return Card(
                                margin: EdgeInsets.all(8.0),
                                child: ListTile(
                                  leading: item['pict'] != null &&
                                          item['pict'].isNotEmpty
                                      ? Image.asset(
                                          item['pict'],
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                      : Icon(Icons.medication,
                                          size: 50, color: Colors.grey),
                                  title: Text(
                                      item['nama'] ?? 'Nama tidak tersedia'),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                          'Harga: ${formatHarga(item['harga'])}'),
                                      Row(
                                        children: [
                                          IconButton(
                                            icon: Icon(Icons.remove),
                                            onPressed: () {
                                              cartProvider.updateQuantity(
                                                  item['id'],
                                                  item['quantity'] - 1);
                                            },
                                          ),
                                          Text('${item['quantity']}'),
                                          IconButton(
                                            icon: Icon(Icons.add),
                                            onPressed: () {
                                              cartProvider.updateQuantity(
                                                  item['id'],
                                                  item['quantity'] + 1);
                                            },
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  trailing: Text(
                                    formatHarga(
                                        item['harga'] * item['quantity']),
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('Total Harga:',
                                    style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white)),
                                Text(
                                  formatHarga(
                                      cartProvider.calculateTotalHarga()),
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.green),
                                ),
                              ],
                            ),
                            SizedBox(height: 10),
                            DropdownButton<String>(
                              value: selectedPaymentMethod,
                              items: <String>[
                                'Cash',
                                'Debit'
                              ].map<DropdownMenuItem<String>>((String value) {
                                return DropdownMenuItem<String>(
                                  value: value,
                                  child: Text(value,
                                      style: TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (String? newValue) {
                                setState(() {
                                  selectedPaymentMethod = newValue;
                                });
                              },
                              hint: Text('Pilih Metode Pembayaran',
                                  style: TextStyle(color: Colors.white)),
                              dropdownColor: Theme.of(context)
                                  .primaryColor, // Dropdown background color
                            ),
                            SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () {
                                // Implement checkout
                                print(
                                    'Checkout pressed with items: ${cartProvider.cartItems}');
                              },
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: 15, horizontal: 30),
                                backgroundColor: Color(0xFFC8ACD6),
                              ),
                              child: Text(
                                'Checkout',
                                style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
          },
        ),
      ),
    );
  }

  String formatHarga(int harga) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return format.format(harga);
  }
}
