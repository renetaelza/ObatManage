import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:obat/pages/cart.dart';
import 'package:obat/pages/cart_page.dart';

class ObatDetailPage extends StatefulWidget {
  final String obatId;

  ObatDetailPage({required this.obatId});

  @override
  _ObatDetailPageState createState() => _ObatDetailPageState();
}

class _ObatDetailPageState extends State<ObatDetailPage> {
  Map<String, dynamic>? obatDetail;

  void fetchObatDetail() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    DocumentSnapshot doc =
        await firestore.collection('obat').doc(widget.obatId).get();

    if (doc.exists) {
      setState(() {
        obatDetail = doc.data() as Map<String, dynamic>;
      });
    } else {
      print("Obat tidak ditemukan.");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchObatDetail();
  }

  String formatHarga(String harga) {
    try {
      final parsedHarga = double.parse(harga.replaceAll(RegExp('[^0-9]'), ''));
      final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
      return format.format(parsedHarga);
    } catch (e) {
      return 'Rp 0';
    }
  }

  void addToCart(Map<String, dynamic> obat) {
    Provider.of<CartProvider>(context, listen: false).addToCart(obat);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${obat['nama']} added to cart!')),
    );

    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShoppingCartPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (obatDetail == null) {
      return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          centerTitle: true,
          title:
              const Text('Detail Obat', style: TextStyle(color: Colors.black)),
        ),
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        centerTitle: true,
        title: const Text('Detail Obat', style: TextStyle(color: Colors.black)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 10),
            Container(
              width: 400,
              height: 400,
              child:
                  obatDetail!['pict'] != null && obatDetail!['pict'].isNotEmpty
                      ? Image.asset(
                          obatDetail!['pict'],
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Icon(
                                Icons.medication_outlined,
                                size: 100,
                                color: Colors.grey,
                              ),
                            );
                          },
                        )
                      : Container(
                          color: Colors.grey[300],
                          child: const Icon(
                            Icons.medication_outlined,
                            size: 100,
                            color: Colors.grey,
                          ),
                        ),
            ),
            const SizedBox(height: 10),
            Text(
              obatDetail!['nama'] ?? 'Nama tidak tersedia',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.category_outlined),
                const SizedBox(width: 8),
                Text(
                  'Kategori: ${obatDetail!['kategori'] ?? 'Tidak tersedia'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Text(
                  'Harga: ${formatHarga(obatDetail!['harga'].toString())}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(width: 8),
                Column(
                  children: [
                    Row(
                      children: [
                        Icon(Icons.info_outline),
                        const SizedBox(width: 8),
                        Text(
                          'Deskripsi',
                          style: TextStyle(fontSize: 16, color: Colors.black),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      constraints: BoxConstraints(
                          maxWidth: MediaQuery.of(context).size.width * 0.8),
                      child: Text(
                        obatDetail!['desc'] ?? 'Deskripsi tidak tersedia',
                        style:
                            const TextStyle(fontSize: 15, color: Colors.black),
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.visible,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.payments_outlined),
                const SizedBox(width: 8),
                Text(
                  'Stok: ${obatDetail!['stok'] ?? 'Tidak tersedia'}',
                  style: const TextStyle(fontSize: 16, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                addToCart(obatDetail!);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFFC8ACD6),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              child: const Text(
                'Add to Cart',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
