import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// === MODEL ===
class Catatan {
  final String judul;
  final String isi;
  final String kategori;
  final DateTime dibuatPada;

  Catatan({
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.dibuatPada,
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Catatan Mahasiswa',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const HomePage(),
        '/tambah': (context) => const TambahCatatanPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/detail') {
          final catatan = settings.arguments as Catatan;
          return MaterialPageRoute(
            builder: (_) => DetailCatatanPage(catatan: catatan),
          );
        }
        return null;
      },
    );
  }
}

// === HOME PAGE ===
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Catatan> _catatan = [
    Catatan(
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      dibuatPada: DateTime.now(),
    ),
  ];

  String _filterKategori = 'Semua';
  final List<String> _filterOpsi = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  Future<void> _bukaTambahCatatan() async {
    final hasil = await Navigator.pushNamed(context, '/tambah');

    if (hasil is Catatan) {
      setState(() => _catatan.add(hasil));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Catatan "${hasil.judul}" ditambahkan')),
      );
    }
  }

  void _hapusCatatan(int index) {
    setState(() {
      _catatan.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    final catatanDifilter = _filterKategori == 'Semua'
        ? _catatan
        : _catatan.where((c) => c.kategori == _filterKategori).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          DropdownButton<String>(
            value: _filterKategori,
            icon: const Icon(Icons.filter_list, color: Colors.indigo),
            underline: const SizedBox(),
            onChanged: (String? newValue) {
              setState(() {
                _filterKategori = newValue!;
              });
            },
            items: _filterOpsi.map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: catatanDifilter.isEmpty
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.notes, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Belum ada catatan',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      )
          : ListView.builder(
        itemCount: catatanDifilter.length,
        itemBuilder: (context, i) {
          final c = catatanDifilter[i];
          return Card(
            margin:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ListTile(
              title: Text(c.judul,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text('${c.kategori} • ${_formatTanggal(c.dibuatPada)}'),
              trailing: IconButton(
                icon: const Icon(Icons.delete, color: Colors.red),
                onPressed: () {
                  final indexAsli = _catatan.indexOf(c);
                  _hapusCatatan(indexAsli);
                },
              ),
              onTap: () {
                Navigator.pushNamed(context, '/detail', arguments: c);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _bukaTambahCatatan,
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// === TAMBAH CATATAN PAGE ===
class TambahCatatanPage extends StatefulWidget {
  const TambahCatatanPage({super.key});

  @override
  State<TambahCatatanPage> createState() => _TambahCatatanPageState();
}

class _TambahCatatanPageState extends State<TambahCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  final _judulCtrl = TextEditingController();
  final _isiCtrl = TextEditingController();

  String _kategori = 'Kuliah';
  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanBaru = Catatan(
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: DateTime.now(),
    );

    Navigator.pop(context, catatanBaru);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Catatan')),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _judulCtrl,
              decoration: const InputDecoration(
                labelText: 'Judul',
                prefixIcon: Icon(Icons.title),
                border: OutlineInputBorder(),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Judul wajib diisi';
                if (v.trim().length < 3) return 'Minimal 3 karakter';
                return null;
              },
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _kategori,
              decoration: const InputDecoration(
                labelText: 'Kategori',
                prefixIcon: Icon(Icons.category),
                border: OutlineInputBorder(),
              ),
              items: _kategoriOpsi
                  .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                  .toList(),
              onChanged: (v) => setState(() => _kategori = v!),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _isiCtrl,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Isi',
                prefixIcon: Icon(Icons.notes),
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Isi wajib diisi' : null,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _simpan,
              icon: const Icon(Icons.save),
              label: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }
}

// === DETAIL CATATAN PAGE ===
class DetailCatatanPage extends StatelessWidget {
  final Catatan catatan;
  const DetailCatatanPage({super.key, required this.catatan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detail Catatan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              catatan.judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Chip(
              label: Text(catatan.kategori),
              backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${_formatTanggal(catatan.dibuatPada)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),
            Text(
              catatan.isi,
              style: const TextStyle(fontSize: 16, height: 1.5),
            ),
            const SizedBox(height: 40),
            Center(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
                label: const Text('Kembali ke Daftar'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
