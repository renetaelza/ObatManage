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
    FirebaseFirestore.instance
        .collection('obat')
        .doc(id)
        .delete()
        .then((value) {
      fetchObat();
    });
  }

  void addObat(String nama, int harga, int stok, String desc, String kategori,
      String pict) {
    FirebaseFirestore.instance.collection('obat').add({
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'desc': desc,
      'kategori': kategori,
      'pict': pict,
    }).then((value) {
      fetchObat();
    });
  }

  void updateObat(String id, String nama, int harga, int stok, String desc,
      String kategori, String pict) {
    FirebaseFirestore.instance.collection('obat').doc(id).update({
      'nama': nama,
      'harga': harga,
      'stok': stok,
      'desc': desc,
      'kategori': kategori,
      'pict': pict,
    }).then((value) {
      fetchObat();
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Hapus Obat'),
          content: Text('Apakah Anda yakin ingin menghapus obat ini?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                deleteObat(id);
                Navigator.pop(context);
              },
              child: Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
                          onPressed: () {
                            _showUpdateObatDialog(context, item);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.delete, color: Colors.red),
                          onPressed: () {
                            _showDeleteConfirmationDialog(context, item['id']);
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

  void _showAddObatDialog(BuildContext context) {
    final _namaController = TextEditingController();
    final _hargaController = TextEditingController();
    final _stokController = TextEditingController();
    final _deskripsiController = TextEditingController();
    final _fotoController = TextEditingController();
    String? _selectedKategori; // Variable to store selected category

    // Variables to track validation states
    bool _isNamaValid = true;
    bool _isHargaValid = true;
    bool _isStokValid = true;
    bool _isDeskripsiValid = true;
    bool _isFotoValid = true;
    bool _isKategoriValid = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Add Obat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Obat',
                        errorText: !_isNamaValid ? 'Required' : null,
                      ),
                    ),
                    TextField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Obat',
                        errorText:
                            !_isHargaValid ? 'Must be a positive number' : null,
                      ),
                    ),
                    TextField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Obat',
                        errorText: !_isDeskripsiValid ? 'Required' : null,
                      ),
                    ),
                    TextField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok Obat',
                        errorText:
                            !_isStokValid ? 'Must be a positive number' : null,
                      ),
                    ),
                    TextField(
                      controller: _fotoController,
                      decoration: InputDecoration(
                        labelText: 'Foto Obat',
                        hintText: 'fotoObat/...',
                        errorText: !_isFotoValid ? 'Required' : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      items: ['body', 'obat'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedKategori = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategori Obat',
                        errorText: !_isKategoriValid ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
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
                    // Validate fields
                    setState(() {
                      _isNamaValid = _namaController.text.isNotEmpty;
                      _isHargaValid =
                          int.tryParse(_hargaController.text) != null &&
                              int.parse(_hargaController.text) > 0;
                      _isStokValid =
                          int.tryParse(_stokController.text) != null &&
                              int.parse(_stokController.text) > 0;
                      _isDeskripsiValid = _deskripsiController.text.isNotEmpty;
                      _isFotoValid = _fotoController.text.isNotEmpty;
                      _isKategoriValid = _selectedKategori != null;
                    });

                    if (_isNamaValid &&
                        _isHargaValid &&
                        _isStokValid &&
                        _isDeskripsiValid &&
                        _isFotoValid &&
                        _isKategoriValid) {
                      addObat(
                        _namaController.text,
                        int.parse(_hargaController.text),
                        int.parse(_stokController.text),
                        _deskripsiController.text,
                        _selectedKategori!,
                        _fotoController.text,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields correctly'),
                        ),
                      );
                    }
                  },
                  child: Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showUpdateObatDialog(BuildContext context, Map<String, dynamic> item) {
    final _namaController = TextEditingController(text: item['nama']);
    final _hargaController =
        TextEditingController(text: item['harga'].toString());
    final _stokController =
        TextEditingController(text: item['stok'].toString());
    final _deskripsiController =
        TextEditingController(text: item['deskripsi'] ?? '');
    final _fotoController = TextEditingController(text: item['foto'] ?? '');
    String? _selectedKategori = item['kategori'];

    // Variables for validation
    bool _isNamaValid = true;
    bool _isHargaValid = true;
    bool _isStokValid = true;
    bool _isDeskripsiValid = true;
    bool _isFotoValid = true;
    bool _isKategoriValid = true;

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text('Update Obat'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: _namaController,
                      decoration: InputDecoration(
                        labelText: 'Nama Obat',
                        errorText: !_isNamaValid ? 'Required' : null,
                      ),
                    ),
                    TextField(
                      controller: _hargaController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Harga Obat',
                        errorText:
                            !_isHargaValid ? 'Must be a positive number' : null,
                      ),
                    ),
                    TextField(
                      controller: _stokController,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        labelText: 'Stok Obat',
                        errorText:
                            !_isStokValid ? 'Must be a positive number' : null,
                      ),
                    ),
                    TextField(
                      controller: _deskripsiController,
                      decoration: InputDecoration(
                        labelText: 'Deskripsi Obat',
                        errorText: !_isDeskripsiValid ? 'Required' : null,
                      ),
                    ),
                    TextField(
                      controller: _fotoController,
                      decoration: InputDecoration(
                        labelText: 'Foto Obat',
                        hintText: 'fotoObat/...',
                        errorText: !_isFotoValid ? 'Required' : null,
                      ),
                    ),
                    SizedBox(height: 16),
                    DropdownButtonFormField<String>(
                      value: _selectedKategori,
                      items: ['body', 'obat'].map((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (newValue) {
                        setState(() {
                          _selectedKategori = newValue;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Kategori Obat',
                        errorText: !_isKategoriValid ? 'Required' : null,
                      ),
                    ),
                  ],
                ),
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
                    setState(() {
                      _isNamaValid = _namaController.text.isNotEmpty;
                      _isHargaValid =
                          int.tryParse(_hargaController.text) != null &&
                              int.parse(_hargaController.text) > 0;
                      _isStokValid =
                          int.tryParse(_stokController.text) != null &&
                              int.parse(_stokController.text) > 0;
                      _isDeskripsiValid = _deskripsiController.text.isNotEmpty;
                      _isFotoValid = _fotoController.text.isNotEmpty;
                      _isKategoriValid = _selectedKategori != null;
                    });

                    if (_isNamaValid &&
                        _isHargaValid &&
                        _isStokValid &&
                        _isDeskripsiValid &&
                        _isFotoValid &&
                        _isKategoriValid) {
                      updateObat(
                        item['id'],
                        _namaController.text,
                        int.parse(_hargaController.text),
                        int.parse(_stokController.text),
                        _deskripsiController.text,
                        _selectedKategori!,
                        _fotoController.text,
                      );
                      Navigator.pop(context);
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Please fill all fields correctly'),
                        ),
                      );
                    }
                  },
                  child: Text('Update'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
