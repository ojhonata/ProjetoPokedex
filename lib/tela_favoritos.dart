import 'package:flutter/material.dart';
import 'package:projeto2_pokemon/pokemon.dart';
import 'package:projeto2_pokemon/tela_detalhes.dart';

class TelaFavoritos extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TelaFavoritosState();
}

class _TelaFavoritosState extends State<TelaFavoritos> {
  List<Pokemon> _favoritos = [];

  void _atualizarFavoritos() async {
    final lista = await DataAccessObject.obterFavoritos();
    setState(() => _favoritos = lista);
  }

  void _remover(Pokemon pokemon) async {
    await DataAccessObject.removerFavorito(pokemon.id);
    _atualizarFavoritos();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('${pokemon.nome} removido')));
    }
  }

  @override
  void initState() {
    super.initState();
    _atualizarFavoritos();
  }

  @override
  Widget build(BuildContext context) {
    if (_favoritos.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.star_border, size: 80, color: Colors.grey),
            SizedBox(height: 16),
            Text('Nenhum favorito ainda!', style: TextStyle(fontSize: 18, color: Colors.grey)),
            Text('Toque em um Pokémon e salve-o.', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _favoritos.length,
      itemBuilder: (context, index) {
        final p = _favoritos[index];
        final nome = p.nome[0].toUpperCase() + p.nome.substring(1);

        return ListTile(
          leading: Image.network(
            p.urlImagem,
            width: 56,
            height: 56,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return const SizedBox(
                width: 56,
                height: 56,
                child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
              );
            },
            errorBuilder: (context, error, stackTrace) => const SizedBox(
              width: 56,
              height: 56,
              child: Icon(Icons.catching_pokemon),
            ),
          ),
          title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
          subtitle: Text(p.tipos.join(' / ')),
          trailing: IconButton(
            icon: const Icon(Icons.star, color: Colors.amber),
            onPressed: () => _remover(p),
          ),
          // Navega para TelaDetalhes e atualiza a lista ao voltar
          onTap: () async {
            await Navigator.push(context, MaterialPageRoute(builder: (context) => TelaDetalhes(pokemon: p)));
            _atualizarFavoritos();
          },
        );
      },
    );
  }
}
