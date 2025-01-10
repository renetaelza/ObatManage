import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class TransactionDetailsPage extends StatelessWidget {
  final String transactionId;

  const TransactionDetailsPage({Key? key, required this.transactionId})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Detail Transaksi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance
            .collection('transaksi')
            .doc(transactionId)
            .get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}',
                    style: TextStyle(color: Colors.white)));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(
                child: Text('Transaksi tidak ditemukan',
                    style: TextStyle(color: Colors.white)));
          }

          final data = snapshot.data!.data() as Map<String, dynamic>;
          final items = List<Map<String, dynamic>>.from(data['items']);
          final totalHarga = data['totalHarga'] as int;
          final metodeBayar = data['metodeBayar'] as String;
          final tanggalTransaksi = (data['tanggalTransaksi'] as Timestamp).toDate();

          return SingleChildScrollView(
            padding: EdgeInsets.all(16.0),
            child: Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'ID Transaksi: $transactionId',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Tanggal: ${DateFormat('dd/MM/yyyy HH:mm').format(tanggalTransaksi)}',
                    ),
                    SizedBox(height: 8),
                    Text('Metode Pembayaran: $metodeBayar'),
                    Divider(height: 24),
                    Text(
                      'Detail Pembelian:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 8),
                    ...items.map((item) => Padding(
                          padding: EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(item['nama']),
                                    Text(
                                      '${item['quantity']}x ${NumberFormat.currency(locale: 'id_ID', symbol: 'Rp').format(item['harga'])}',
                                      style: TextStyle(color: Colors.grey),
                                    ),
                                  ],
                                ),
                              ),
                              Text(
                                NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                                    .format(item['harga'] * item['quantity']),
                              ),
                            ],
                          ),
                        )),
                    Divider(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        Text(
                          NumberFormat.currency(locale: 'id_ID', symbol: 'Rp')
                              .format(totalHarga),
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 24),
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.popUntil(
                              context, (route) => route.isFirst);
                        },
                        style: ElevatedButton.styleFrom(
                          padding:
                              EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                          backgroundColor: Color(0xFFC8ACD6),
                        ),
                        child: Text(
                          'Kembali ke Beranda',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}