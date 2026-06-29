import 'package:flutter/material.dart';
import 'usuario.dart';
import 'usuario_dao.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CRUD Usuário',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'CRUD de Usuários'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final TextEditingController _nomeController = TextEditingController();
  final TextEditingController _sobrenomeController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  List<Usuario> _usuarios = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _refreshUsuarios();
  }

  @override
  void dispose() {
    _nomeController.dispose();
    _sobrenomeController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _refreshUsuarios() async {
    final usuarios = await UsuarioDao.getAll();
    setState(() {
      _usuarios = usuarios;
      _isLoading = false;
    });
  }

  Future<void> _addUsuario() async {
    final nome = _nomeController.text.trim();
    final sobrenome = _sobrenomeController.text.trim();
    final email = _emailController.text.trim();

    if (nome.isEmpty || sobrenome.isEmpty || email.isEmpty) {
      _showMessage('Preencha nome, sobrenome e email.');
      return;
    }

    final usuario = Usuario(nome: nome, sobrenome: sobrenome, email: email);
    await UsuarioDao.insert(usuario);
    _nomeController.clear();
    _sobrenomeController.clear();
    _emailController.clear();
    await _refreshUsuarios();
  }

  Future<void> _deleteUsuario(int id) async {
    await UsuarioDao.delete(id);
    await _refreshUsuarios();
  }

  Future<void> _showEditDialog(Usuario usuario) async {
    final nomeController = TextEditingController(text: usuario.nome);
    final sobrenomeController = TextEditingController(text: usuario.sobrenome);
    final emailController = TextEditingController(text: usuario.email);

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Editar usuário'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nomeController,
                decoration: const InputDecoration(labelText: 'Nome'),
              ),
              TextField(
                controller: sobrenomeController,
                decoration: const InputDecoration(labelText: 'Sobrenome'),
              ),
              TextField(
                controller: emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final nome = nomeController.text.trim();
                final sobrenome = sobrenomeController.text.trim();
                final email = emailController.text.trim();
                if (nome.isEmpty || sobrenome.isEmpty || email.isEmpty) {
                  _showMessage('Preencha todos os campos.');
                  return;
                }

                final navigator = Navigator.of(context);
                await UsuarioDao.update(usuario.copyWith(
                  nome: nome,
                  sobrenome: sobrenome,
                  email: email,
                ));
                if (!mounted) return;
                navigator.pop();
                await _refreshUsuarios();
              },
              child: const Text('Salvar'),
            ),
          ],
        );
      },
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Cadastro de usuário',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nomeController,
              decoration: const InputDecoration(
                labelText: 'Nome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _sobrenomeController,
              decoration: const InputDecoration(
                labelText: 'Sobrenome',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 14),
            ElevatedButton(
              onPressed: _addUsuario,
              child: const Text('Adicionar usuário'),
            ),
            const SizedBox(height: 20),
            const Text(
              'Usuários cadastrados',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 10),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else if (_usuarios.isEmpty)
              const Center(child: Text('Nenhum usuário cadastrado.'))
            else
              Column(
                children: _usuarios.map((usuario) {
                  return Card(
                    child: ListTile(
                      title: Text('${usuario.nome} ${usuario.sobrenome}'),
                      subtitle: Text(usuario.email),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () => _showEditDialog(usuario),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () => _deleteUsuario(usuario.id!),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
