class Usuario {
  int? id;
  String nome;
  String sobrenome;
  String email;

  Usuario({this.id, required this.nome, required this.sobrenome, required this.email});

  Usuario copyWith({int? id, String? nome, String? sobrenome, String? email}) {
    return Usuario(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      sobrenome: sobrenome ?? this.sobrenome,
      email: email ?? this.email,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'sobrenome': sobrenome,
      'email': email,
    };
  }

  factory Usuario.fromMap(Map<String, dynamic> map) {
    return Usuario(
      id: map['id'] as int?,
      nome: map['nome'] as String,
      sobrenome: map['sobrenome'] as String,
      email: map['email'] as String,
    );
  }
}
