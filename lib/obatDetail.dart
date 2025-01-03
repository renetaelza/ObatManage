import 'package:flutter/material.dart';

class ObatDetailPage extends StatefulWidget {
  final String name;
  final String price;
  final String Desc;
  final String Pict;

  ObatDetailPage({
    required this.name,
    required this.price,
    required this.Desc,
    required this.Pict,
  });

  @override
  _ObatPageState createState() => _ObatPageState();
}

class _ObatPageState extends State<ObatDetailPage> {
  final List<Map<String, String>> obatList = [
       {
      'id': '1',
      'name': 'Neurobion Strip 10 Tablet',
      'price': '28.100',
      'Pict': 'assets/neurobion.jpg',
      'Desc':
          'Neurobion adalah vitamin untuk mencegah dan mengobati Neuropati (kerusakan sel saraf) dengan gejala kesemutan dan kebas',
    },
    {
      'id': '2',
      'name': 'Herocyn Powder 85gr',
      'price': '15.200',
      'Pict': 'assets/herocyn.jpg',
      'Desc':
          'Herocyn Powder adalah bedak tabur yang digunakan untuk mengatasi gangguan kulit seperti gatal-gatal dan biang keringat.',
    },
    {
      'id': '3',
      'name': 'Procold Flu PE Strip 6 Tablet',
      'price': '4.900',
      'Pict': 'assets/procold.jpg',
      'Desc':
          'Procold Flu PE adalah obat yang mengandung Paracetamol, Pseudoephedrin HCl, dan Chlorpeniramin Maleat',
    },
    {
      'id': '4',
      'name': 'Bodrex Flu & Batuk Berdahak PE Strip 4 Tablet',
      'price': '2.400',
      'Pict': 'assets/bodrex.jpg',
      'Desc':
          'Bodrex Flu & Batuk Berdahak PE merupakan obat yang dapat meredakan gejala flu dan batuk berdahak tanpa rasa kantuk.',
    },
    {
      'id': '5',
      'name': 'Antimo Anak Rasa Jeruk Sachet 5ml',
      'price': '2.500',
      'Pict': 'assets/antimo.jpg',
      'Desc':
          'Antimo Anak merupakan obat yang berguna untuk mencegah serta meredakan gejala mabuk perjalanan, seperti mual, muntah, dan pusing. ',
    },
  ];

  List<Map<String, String>> filteredList = [];

  @override
  void initState() {
    super.initState();
    filteredList = obatList;
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text('Apakah Anda yakin ingin menghapus ${widget.name}?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
                _showAfterDelete();
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );
  }

  void _showAfterDelete() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Informasi'),
          content: Text('${widget.name} berhasil dihapus'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Tutup dialog
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            onPressed: _showDeleteDialog,
            icon: const Icon(Icons.delete),
          ),
        ],
        centerTitle: true,
        title: const Text('Detail Obat'),
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
              child: Image.asset(
                widget.Pict,
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
              ),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.medication_outlined),
                const SizedBox(width: 8),
                Text(
                  widget.name,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
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
                  widget.price,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.info_outline),
                const SizedBox(width: 8),
                Text(
                  widget.Desc,
                  style: const TextStyle(fontSize: 15, color: Colors.black),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
