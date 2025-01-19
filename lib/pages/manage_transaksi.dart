import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageTransaksi extends StatefulWidget {
  @override
  _ManageTransaksiState createState() => _ManageTransaksiState();
}

class _ManageTransaksiState extends State<ManageTransaksi> {
  List<Map<String, dynamic>> transaksiList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchTransaksi();
  }

  void fetchTransaksi() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference transaksi = firestore.collection('transaksi');

    transaksi.snapshots().listen((snapshot) {
      List<Map<String, dynamic>> tempList = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          ...data,
        };
      }).toList();

      setState(() {
        transaksiList = tempList;
        isLoading = false;
      });
    });
  }

  void deleteTransaksi(String id) {
    FirebaseFirestore.instance
        .collection('transaksi')
        .doc(id)
        .delete()
        .then((value) {
      fetchTransaksi();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Transaksi'),
          content: Text('Apakah Anda yakin ingin menghapus transaksi ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteTransaksi(id);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _showTransactionDetails(
      BuildContext context, Map<String, dynamic> item) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Detail Transaksi'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ID Transaksi: ${item['idTransaksi']}',
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text(
                    'Metode Bayar: ${item['metodeBayar'] ?? 'Tidak tersedia'}'),
                SizedBox(height: 10),
                Text(
                    'Tanggal Transaksi: ${_formatDate(item['tanggalTransaksi'])}'),
                SizedBox(height: 10),
                Text('Total Harga: ${formatHarga(item['totalHarga'])}'),
                SizedBox(height: 10),
                Text('Items:', style: TextStyle(fontWeight: FontWeight.bold)),
                ..._buildItemsList(item['items']),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  List<Widget> _buildItemsList(List<dynamic> items) {
    return items.map<Widget>((item) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Text(
          '${item['nama']} - Harga: ${formatHarga(item['harga'])}, Quantity: ${item['quantity']}',
        ),
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Manage Transaksi', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: transaksiList.length,
              itemBuilder: (context, index) {
                final item = transaksiList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text('Transaksi ${index + 1}',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Total Harga: ${formatHarga(item['totalHarga'])}',
                            style: TextStyle(color: Colors.black)),
                        Text(
                            'Metode Bayar: ${item['metodeBayar'] ?? 'Tidak tersedia'}',
                            style: TextStyle(color: Colors.black)),
                        Text(
                            'Tanggal: ${_formatDate(item['tanggalTransaksi'])}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    onTap: () {
                      _showTransactionDetails(context, item);
                    },
                    trailing: IconButton(
                      icon: Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        _showDeleteConfirmationDialog(context, item['id']);
                      },
                    ),
                  ),
                );
              },
            ),
    );
  }

  String formatHarga(int harga) {
    final format = NumberFormat.currency(locale: 'id_ID', symbol: 'Rp');
    return format.format(harga);
  }

  String _formatDate(Timestamp? timestamp) {
    if (timestamp != null) {
      return DateFormat('dd MMMM yyyy HH:mm:ss').format(timestamp.toDate());
    }
    return 'Tanggal tidak tersedia';
  }
}
