import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ManageObat extends StatefulWidget {
  @override
  _ManageObatState createState() => _ManageObatState();
}

class _ManageObatState extends State<ManageObat> {
  List<Map<String, dynamic>> obatList = [];
  List<Map<String, dynamic>> filteredList = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchObat();
  }

  void fetchObat() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    CollectionReference obat = firestore.collection('obat');

    obat.snapshots().listen((snapshot) {
      List<Map<String, dynamic>> tempList = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        return {
          'id': doc.id,
          'nama': data['nama'],
          'harga': int.tryParse(data['harga'].toString()) ?? 0,
          'stok': data['stok'],
        };
      }).toList();

      setState(() {
        obatList = tempList;
        filteredList = tempList;
        isLoading = false;
      });
    });
  }

  void deleteObat(String id) {
    FirebaseFirestore.instance.collection('obat').doc(id).delete();
  }

  void addObat(String nama, int harga, int stok) {
    FirebaseFirestore.instance.collection('obat').add({
      'nama': nama,
      'harga': harga,
      'stok': stok,
    }).then((value) {
      fetchObat();  // Refresh the list after adding
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).primaryColor,
      appBar: AppBar(
        title: Text('Manage Obat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        backgroundColor: Theme.of(context).primaryColor,
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddObatDialog(context),
          ),
        ],
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: filteredList.length,
              itemBuilder: (context, index) {
                final item = filteredList[index];
                return Card(
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    title: Text(item['nama'] ?? 'Nama tidak tersedia',
                        style: TextStyle(color: Colors.black)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Harga: ${formatHarga(item['harga'])}',
                            style: TextStyle(color: Colors.black)),
                        Text('Stok: ${item['stok']}',
                            style: TextStyle(color: Colors.black)),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.edit, color: Colors.blue),
                          onPressed: () {},
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            deleteObat(item['id']);
                          },
                        ),
                      ],
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

  // Show dialog to add new obat
  void _showAddObatDialog(BuildContext context) {
    final _namaController = TextEditingController();
    final _hargaController = TextEditingController();
    final _stokController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Obat'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _namaController,
                decoration: InputDecoration(labelText: 'Nama Obat'),
              ),
              TextField(
                controller: _hargaController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Harga Obat'),
              ),
              TextField(
                controller: _stokController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Stok Obat'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                String nama = _namaController.text;
                int harga = int.tryParse(_hargaController.text) ?? 0;
                int stok = int.tryParse(_stokController.text) ?? 0;
                
                if (nama.isNotEmpty && harga > 0 && stok > 0) {
                  addObat(nama, harga, stok);
                  Navigator.pop(context);
                } else {
                  // Show error if fields are invalid
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Please fill all fields correctly')),
                  );
                }
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
