import 'package:flutter/material.dart';
import 'formInput.dart';

class AddObatPage extends StatefulWidget {
  final Function(String name, String price, String description) onAddObat;

  AddObatPage({required this.onAddObat});

  @override
  _AddObatPageState createState() => _AddObatPageState();
}

class _AddObatPageState extends State<AddObatPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  void _submitForm() {
    final name = _nameController.text.trim();
    final price = _priceController.text.trim();
    final description = _descriptionController.text.trim();

    if (name.isNotEmpty && price.isNotEmpty) {
      widget.onAddObat(name, price, description);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Data berhasil ditambahkan')),
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Nama dan harga harus diisi')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tambah Obat Baru'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: FormInput(
            nameController: _nameController,
            priceController: _priceController,
            descriptionController: _descriptionController,
            onSubmit: _submitForm),
      ),
    );
  }
}
