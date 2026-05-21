import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

// === MODEL ===
class Catatan {
  final String id;
  final String judul;
  final String isi;
  final String kategori;
  final String email; // Fitur: Validasi Lanjutan
  final DateTime dibuatPada;

  Catatan({
    required this.id,
    required this.judul,
    required this.isi,
    required this.kategori,
    required this.email,
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
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/form') {
          final catatan = settings.arguments as Catatan?;
          return MaterialPageRoute(
            builder: (_) => FormCatatanPage(catatanLama: catatan),
          );
        }
        if (settings.name == '/detail') {
          final args = settings.arguments as Map<String, dynamic>;
          return MaterialPageRoute(
            builder: (_) => DetailCatatanPage(
              catatan: args['catatan'],
              onUpdate: args['onUpdate'],
            ),
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
      id: '1',
      judul: 'Belajar Flutter',
      isi: 'Mempelajari Stateful Widget, Form, dan Navigation.',
      kategori: 'Kuliah',
      email: 'ghani@example.com',
      dibuatPada: DateTime.now(),
    ),
  ];

  // Fitur: Filter berdasarkan Kategori
  String _filterKategori = 'Semua';
  final List<String> _filterOpsi = ['Semua', 'Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  void _updateList(Catatan baru) {
    setState(() {
      final index = _catatan.indexWhere((c) => c.id == baru.id);
      if (index != -1) {
        _catatan[index] = baru;
      } else {
        _catatan.add(baru);
      }
    });
  }

  void _hapusCatatan(String id) {
    setState(() {
      _catatan.removeWhere((c) => c.id == id);
    });
  }

  @override
  Widget build(BuildContext context) {
    // Logika Filter
    final listDifilter = _filterKategori == 'Semua'
        ? _catatan
        : _catatan.where((c) => c.kategori == _filterKategori).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Mahasiswa'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        actions: [
          // Widget Dropdown Filter di AppBar
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
      body: listDifilter.isEmpty
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notes, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text('Belum ada catatan untuk kategori ini',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            )
          : ListView.builder(
              itemCount: listDifilter.length,
              itemBuilder: (context, i) {
                final c = listDifilter[i];
                return Card(
                  margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: ListTile(
                    title: Text(c.judul,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${c.kategori} • ${_formatTanggal(c.dibuatPada)}'),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _hapusCatatan(c.id),
                    ),
                    onTap: () {
                      Navigator.pushNamed(context, '/detail', arguments: {
                        'catatan': c,
                        'onUpdate': (Catatan baru) => _updateList(baru),
                      });
                    },
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final hasil = await Navigator.pushNamed(context, '/form');
          if (hasil is Catatan) _updateList(hasil);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatTanggal(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}

// === FORM PAGE (Reuse + Email Validation) ===
class FormCatatanPage extends StatefulWidget {
  final Catatan? catatanLama;
  const FormCatatanPage({super.key, this.catatanLama});

  @override
  State<FormCatatanPage> createState() => _FormCatatanPageState();
}

class _FormCatatanPageState extends State<FormCatatanPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _judulCtrl;
  late TextEditingController _isiCtrl;
  late TextEditingController _emailCtrl; // Controller baru untuk Email
  late String _kategori;

  final _kategoriOpsi = const ['Kuliah', 'Tugas', 'Pribadi', 'Lainnya'];

  @override
  void initState() {
    super.initState();
    _judulCtrl = TextEditingController(text: widget.catatanLama?.judul ?? '');
    _isiCtrl = TextEditingController(text: widget.catatanLama?.isi ?? '');
    _emailCtrl = TextEditingController(text: widget.catatanLama?.email ?? '');
    _kategori = widget.catatanLama?.kategori ?? 'Kuliah';
  }

  @override
  void dispose() {
    _judulCtrl.dispose();
    _isiCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  void _simpan() {
    if (!_formKey.currentState!.validate()) return;

    final catatanResult = Catatan(
      id: widget.catatanLama?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
      judul: _judulCtrl.text.trim(),
      isi: _isiCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      kategori: _kategori,
      dibuatPada: widget.catatanLama?.dibuatPada ?? DateTime.now(),
    );

    Navigator.pop(context, catatanResult);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.catatanLama != null;

    return Scaffold(
      appBar: AppBar(title: Text(isEdit ? 'Edit Catatan' : 'Tambah Catatan')),
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
            // Fitur: Validasi Lanjutan (Field Email + Regex)
            TextFormField(
              controller: _emailCtrl,
              decoration: const InputDecoration(
                labelText: 'Email Pengirim',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
                hintText: 'contoh: nama@mail.com',
              ),
              keyboardType: TextInputType.emailAddress,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Email wajib diisi';
                // Regex sederhana untuk validasi format email
                final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                if (!emailRegex.hasMatch(v)) return 'Format email tidak valid';
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
              icon: Icon(isEdit ? Icons.save : Icons.add),
              label: Text(isEdit ? 'Simpan Perubahan' : 'Tambah Catatan'),
            ),
          ],
        ),
      ),
    );
  }
}

// === DETAIL PAGE ===
class DetailCatatanPage extends StatefulWidget {
  final Catatan catatan;
  final Function(Catatan) onUpdate;

  const DetailCatatanPage({super.key, required this.catatan, required this.onUpdate});

  @override
  State<DetailCatatanPage> createState() => _DetailCatatanPageState();
}

class _DetailCatatanPageState extends State<DetailCatatanPage> {
  late Catatan _currentCatatan;

  @override
  void initState() {
    super.initState();
    _currentCatatan = widget.catatan;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Catatan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () async {
              final hasil = await Navigator.pushNamed(
                context, '/form', arguments: _currentCatatan
              );
              
              if (hasil is Catatan) {
                setState(() => _currentCatatan = hasil);
                widget.onUpdate(hasil);
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _currentCatatan.judul,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Chip(
                  label: Text(_currentCatatan.kategori),
                  backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Oleh: ${_currentCatatan.email}',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              'Dibuat pada: ${_formatTanggal(_currentCatatan.dibuatPada)}',
              style: const TextStyle(color: Colors.grey),
            ),
            const Divider(height: 32),
            Text(
              _currentCatatan.isi,
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
