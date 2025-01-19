import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:file_picker/file_picker.dart';
import 'package:csv/csv.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class ManageObat extends StatefulWidget {
  @override
  _ManageObatState createState() => _ManageObatState();
}

class _ManageObatState extends State<ManageObat> {
  List<Map<String, dynamic>> obatList = [];
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
        isLoading = false;
      });
    });
  }

  Future<void> importData(BuildContext context) async {
    try {
      final result = await FilePicker.platform
          .pickFiles(type: FileType.custom, allowedExtensions: ['csv']);
      if (result != null) {
        final fileBytes = result.files.single.bytes;
        if (fileBytes != null) {
          final csvData = CsvToListConverter()
              .convert(String.fromCharCodes(fileBytes), eol: '\n');

          // Save data to Firestore
          for (var row in csvData.skip(1)) {
            if (row.length >= 6) {
              // Ensure there are enough columns
              await FirebaseFirestore.instance.collection('obat').add({
                'desc': row[0].toString(),
                'harga': int.tryParse(row[1].toString()) ?? 0,
                'kategori': row[2].toString(),
                'nama': row[3].toString(),
                'pict': row[4].toString(),
                'stok': int.tryParse(row[5].toString()) ?? 0,
              });
            }
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('CSV file successfully imported!')),
          );
        }
      }
    } catch (e) {
      print("Error importing data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Failed to import CSV file.')),
      );
    }
  }

  Future<void> exportDataToPDF() async {
    try {
      final pdf = pw.Document();
      final data = await FirebaseFirestore.instance.collection('obat').get();

      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text('Obat Report', style: pw.TextStyle(fontSize: 24)),
                pw.SizedBox(height: 16),
                pw.Table.fromTextArray(
                  headers: ['ID', 'Nama', 'Harga', 'Stok'],
                  data: data.docs.map((doc) {
                    final d = doc.data();
                    return [
                      doc.id,
                      d['nama'] ?? '',
                      d['harga']?.toString() ?? '0',
                      d['stok']?.toString() ?? '0',
                    ];
                  }).toList(),
                ),
              ],
            );
          },
        ),
      );

      await Printing.sharePdf(
        bytes: await pdf.save(),
        filename: 'obat-report.pdf',
      );
    } catch (e) {
      print("Error exporting PDF: $e");
    }
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Manage Obat', style: TextStyle(color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.add, color: Colors.white),
            onPressed: () => _showAddObatDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton.icon(
                  onPressed: () => importData(context),
                  icon: const Icon(Icons.upload_file),
                  label: const Text('Import CSV',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                  ),
                ),
                ElevatedButton.icon(
                  onPressed: exportDataToPDF,
                  icon: const Icon(Icons.picture_as_pdf),
                  label: const Text('Export PDF',
                      style: TextStyle(color: Colors.black)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.orange,
                  ),
                ),
              ],
            ),
          ),
          isLoading
              ? Center(child: CircularProgressIndicator())
              : Expanded(
                  child: ListView.builder(
                    itemCount: obatList.length,
                    itemBuilder: (context, index) {
                      final item = obatList[index];
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
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () {
                              _showDeleteConfirmationDialog(
                                  context, item['id']);
                            },
                          ),
                        ),
                      );
                    },
                  ),
                ),
        ],
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
    String? _selectedKategori;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Obat'),
          content: SingleChildScrollView(
            child: Column(
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
                TextField(
                  controller: _deskripsiController,
                  decoration: InputDecoration(labelText: 'Deskripsi Obat'),
                ),
                TextField(
                  controller: _fotoController,
                  decoration: InputDecoration(labelText: 'Foto Obat'),
                ),
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
                  decoration: InputDecoration(labelText: 'Kategori Obat'),
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
                // Add logic to add Obat
                FirebaseFirestore.instance.collection('obat').add({
                  'nama': _namaController.text,
                  'harga': int.tryParse(_hargaController.text) ?? 0,
                  'stok': int.tryParse(_stokController.text) ?? 0,
                  'desc': _deskripsiController.text,
                  'kategori': _selectedKategori,
                  'pict': _fotoController.text,
                }).then((value) {
                  fetchObat();
                  Navigator.pop(context);
                });
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }
}
