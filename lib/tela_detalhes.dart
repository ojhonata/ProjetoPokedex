import 'package:flutter/material.dart';
import 'package:projeto2_pokemon/pokemon.dart';

// Recebe um Pokemon como parâmetro via construtor (passagem de parâmetros entre telas)
class TelaDetalhes extends StatefulWidget {
  final Pokemon pokemon;
  const TelaDetalhes({super.key, required this.pokemon});

  @override
  State<StatefulWidget> createState() => _TelaDetalhesState();
}

class _TelaDetalhesState extends State<TelaDetalhes> {
  bool _ehFavorito = false;

  @override
  void initState() {
    super.initState();
    // Verifica no banco se já é favorito ao abrir a tela
    DataAccessObject.ehFavorito(widget.pokemon.id).then((v) => setState(() => _ehFavorito = v));
  }

  void _alternarFavorito() async {
    if (_ehFavorito) {
      await DataAccessObject.removerFavorito(widget.pokemon.id);
    } else {
      await DataAccessObject.salvarFavorito(widget.pokemon);
    }
    setState(() => _ehFavorito = !_ehFavorito);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(_ehFavorito ? '${widget.pokemon.nome} salvo nos favoritos!' : '${widget.pokemon.nome} removido dos favoritos'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.pokemon;
    final nome = p.nome[0].toUpperCase() + p.nome.substring(1);

    return Scaffold(
      appBar: AppBar(
        title: Text(nome),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(_ehFavorito ? Icons.star : Icons.star_border),
            color: _ehFavorito ? Colors.amber : null,
            onPressed: _alternarFavorito,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Imagem (uso de Image.network para evitar dependência externa)
            SizedBox(
              height: 200,
              child: Image.network(
                p.urlImagem,
                fit: BoxFit.contain,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
              ),
            ),
            const SizedBox(height: 16),

            // Número e nome
            Text(nome,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // Peso e altura em cards lado a lado
            Row(
              children: [
                _card('Peso', '${(p.peso / 10).toStringAsFixed(1)} kg', Icons.monitor_weight_outlined),
                const SizedBox(width: 12),
                _card('Altura', '${(p.altura / 10).toStringAsFixed(1)} m', Icons.height),
              ],
            ),
            const SizedBox(height: 12),

            // Tipos
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: p.tipos.map((t) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Chip(label: Text(t.toUpperCase(), style: const TextStyle(color: Colors.black, fontWeight: FontWeight.bold))),
              )).toList(),
            ),
            const SizedBox(height: 24),

            // Botão de favorito
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: _alternarFavorito,
                icon: Icon(_ehFavorito ? Icons.star : Icons.star_border),
                label: Text(_ehFavorito ? 'Remover dos Favoritos' : 'Salvar nos Favoritos'),
                style: FilledButton.styleFrom(backgroundColor: _ehFavorito ? Colors.amber[700] : null),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _card(String label, String valor, IconData icone) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.shade100),
        ),
        child: Column(children: [
          Icon(icone, color: Colors.red),
          const SizedBox(height: 4),
          Text(label, style: TextStyle(color: Colors.black)),
          Text(valor, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ]),
      ),
    );
  }
}
