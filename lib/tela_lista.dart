import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:projeto2_pokemon/pokemon.dart';
import 'package:projeto2_pokemon/tela_detalhes.dart';

class TelaLista extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TelaListaState();
}

class _TelaListaState extends State<TelaLista> {
  List<Pokemon> _pokemons = [];
  bool _carregando = false;
  bool _modosBusca = false;
  int _offset = 0;

  final _buscaController = TextEditingController();

  // Cores por tipo (usadas na etiqueta de tipo)
  static const Map<String, Color> _coresTipo = {
    'fire': Color(0xFFFF4422), 'water': Color(0xFF3399FF),
    'grass': Color(0xFF77CC55), 'electric': Color(0xFFFFCC33),
    'ice': Color(0xFF66CCFF), 'fighting': Color(0xFFBB5544),
    'poison': Color(0xFFAA5599), 'ground': Color(0xFFDDBB55),
    'flying': Color(0xFF8899FF), 'psychic': Color(0xFFFF5599),
    'bug': Color(0xFFAABB22), 'rock': Color(0xFFBBAA66),
    'ghost': Color(0xFF6666BB), 'dragon': Color(0xFF7766EE),
    'dark': Color(0xFF775544), 'steel': Color(0xFFAAAABB),
    'fairy': Color(0xFFEE99EE), 'normal': Color(0xFFAAAA99),
  };

  @override
  void initState() {
    super.initState();
    _carregarMais();
  }

  void _carregarMais() async {
    if (_carregando) return;
    setState(() => _carregando = true);
    try {
      final novos = await PokemonService.obterPokemons(offset: _offset);
      setState(() {
        _pokemons.addAll(novos);
        _offset += 20;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('$e')));
    }
  }

  void _buscar() async {
    final nome = _buscaController.text.trim();
    if (nome.isEmpty) return;
    setState(() => _carregando = true);
    try {
      final pokemon = await PokemonService.buscarPorNome(nome);
      setState(() {
        _pokemons = [pokemon];
        _modosBusca = true;
        _carregando = false;
      });
    } catch (e) {
      setState(() => _carregando = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pokémon não encontrado!')));
    }
  }

  void _limparBusca() {
    _buscaController.clear();
    setState(() { _pokemons = []; _offset = 0; _modosBusca = false; });
    _carregarMais();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Barra de busca
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _buscaController,
                  decoration: InputDecoration(
                    border: const OutlineInputBorder(),
                    labelText: 'Buscar pelo nome',
                    prefixIcon: const Icon(Icons.search),
                  ),
                  onSubmitted: (_) => _buscar(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(onPressed: _buscar, child: const Text('Buscar')),
              if (_modosBusca) ...[
                const SizedBox(width: 8),
                OutlinedButton(onPressed: _limparBusca, child: const Text('Limpar')),
              ]
            ],
          ),
        ),

        // Lista de Pokémons
        Expanded(
          child: NotificationListener<ScrollNotification>(
            onNotification: (scroll) {
              // Carrega mais ao chegar perto do fim da lista
              bool chegouNoFim = scroll.metrics.pixels >= scroll.metrics.maxScrollExtent - 200;
              if (!_modosBusca && chegouNoFim) {
                _carregarMais();
              }
              return false;
            },
            child: ListView.builder(
              itemCount: _pokemons.length + (_carregando ? 1 : 0),
              itemBuilder: (context, index) {
                // Indicador de carregamento no final
                if (index == _pokemons.length) {
                  return const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()));
                }

                final p = _pokemons[index];
                final nome = p.nome[0].toUpperCase() + p.nome.substring(1);

                return ListTile(
                  // Imagem com cache (biblioteca cached_network_image do pub.dev)
                  leading: CachedNetworkImage(
                    imageUrl: p.urlImagem,
                    width: 56, height: 56,
                    placeholder: (context, url) => const SizedBox(width: 56, height: 56, child: CircularProgressIndicator()),
                    errorWidget: (context, url, error) => const Icon(Icons.catching_pokemon, size: 40),
                  ),
                  title: Text(nome, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Row(
                    children: p.tipos.map((t) => Padding(
                      padding: const EdgeInsets.only(right: 4),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: _coresTipo[t] ?? Colors.grey,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(t.toUpperCase(), style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                      ),
                    )).toList(),
                  ),
                  // Navega para TelaDetalhes passando o pokemon como parâmetro
                  onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => TelaDetalhes(pokemon: p))),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}