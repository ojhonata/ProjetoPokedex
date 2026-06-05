import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:sqflite/sqflite.dart' as sql;

class Pokemon {
  final int id;
  final String nome;
  final int peso;
  final int altura;
  final List<String> tipos;
  final String urlImagem;

  Pokemon({
    required this.id,
    required this.nome,
    required this.peso,
    required this.altura,
    required this.tipos,
    required this.urlImagem,
  });

  // Converte o JSON da PokeAPI para um objeto Pokemon
  factory Pokemon.fromJson(Map<String, dynamic> json) {
    return Pokemon(
      id: json['id'],
      nome: json['name'],
      peso: json['weight'],
      altura: json['height'],
      tipos: (json['types'] as List).map((t) => t['type']['name'] as String).toList(),
      urlImagem: json['sprites']['front_default'] ?? '',
    );
  }

  // Converte um Map do banco de dados para um objeto Pokemon
  factory Pokemon.fromMap(Map<String, dynamic> map) {
    return Pokemon(
      id: map['id'],
      nome: map['nome'],
      peso: map['peso'],
      altura: map['altura'],
      tipos: (map['tipos'] as String).split(','),
      urlImagem: map['urlImagem'],
    );
  }

  // Converte o objeto para Map (para salvar no banco)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nome': nome,
      'peso': peso,
      'altura': altura,
      'tipos': tipos.join(','),
      'urlImagem': urlImagem,
    };
  }
}

class DataAccessObject {
  static Future<void> criarTabelas(sql.Database database) async {
    await database.execute("""
      CREATE TABLE favoritos (
        id INTEGER PRIMARY KEY NOT NULL,
        nome TEXT NOT NULL,
        peso INTEGER,
        altura INTEGER,
        tipos TEXT,
        urlImagem TEXT
      );
    """);
  }

  static Future<sql.Database> db() async {
    return sql.openDatabase(
      'pokedex.db',
      version: 1,
      onCreate: (sql.Database database, int version) async {
        await criarTabelas(database);
      },
    );
  }

  // Salva um Pokémon nos favoritos
  static Future<void> salvarFavorito(Pokemon pokemon) async {
    final db = await DataAccessObject.db();
    await db.insert('favoritos', pokemon.toMap(),
        conflictAlgorithm: sql.ConflictAlgorithm.replace);
  }

  // Retorna todos os favoritos
  static Future<List<Pokemon>> obterFavoritos() async {
    final db = await DataAccessObject.db();
    final maps = await db.query('favoritos', orderBy: 'nome');
    return maps.map((map) => Pokemon.fromMap(map)).toList();
  }

  // Verifica se um Pokémon já é favorito
  static Future<bool> ehFavorito(int id) async {
    final db = await DataAccessObject.db();
    final resultado = await db.query('favoritos', where: 'id = ?', whereArgs: [id]);
    return resultado.isNotEmpty;
  }

  // Remove um Pokémon dos favoritos
  static Future<void> removerFavorito(int id) async {
    final db = await DataAccessObject.db();
    try {
      await db.delete('favoritos', where: 'id = ?', whereArgs: [id]);
    } catch (erro) {
      debugPrint('Falha ao remover favorito: $erro');
    }
  }
}

class PokemonService {
  static const String _baseUrl = 'https://pokeapi.co/api/v2';

  // Busca uma página de Pokémons
  static Future<List<Pokemon>> obterPokemons({int offset = 0, int limit = 20}) async {
    final resposta = await http.get(Uri.parse('$_baseUrl/pokemon?offset=$offset&limit=$limit'));
    if (resposta.statusCode != 200) throw Exception('Erro ao carregar lista');

    final resultados = json.decode(resposta.body)['results'] as List;
    return Future.wait(resultados.map((item) => _obterDetalhes(item['url'])));
  }

  // Busca detalhes de um Pokémon pela URL
  static Future<Pokemon> _obterDetalhes(String url) async {
    final resposta = await http.get(Uri.parse(url));
    if (resposta.statusCode != 200) throw Exception('Erro ao carregar detalhes');
    return Pokemon.fromJson(json.decode(resposta.body));
  }

  // Busca um Pokémon pelo nome
  static Future<Pokemon> buscarPorNome(String nome) async {
    final resposta = await http.get(Uri.parse('$_baseUrl/pokemon/${nome.toLowerCase().trim()}'));
    if (resposta.statusCode != 200) throw Exception('Pokémon não encontrado');
    return Pokemon.fromJson(json.decode(resposta.body));
  }
}
