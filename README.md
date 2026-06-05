# Pokédex App

Trabalho Final da disciplina de Sistemas Móveis — ADS.

Aplicativo mobile desenvolvido em Flutter que consome a [PokeAPI](https://pokeapi.co/) para listar Pokémons, exibir seus detalhes e permitir que o usuário salve seus favoritos localmente.

---

## Funcionalidades

- Listagem de Pokémons com carregamento paginado
- Busca de Pokémon pelo nome
- Tela de detalhes com nome, número, tipos, peso e altura
- Salvamento e remoção de favoritos com persistência local

---

## Tecnologias e Bibliotecas

| Recurso | Descrição |
|---|---|
| Flutter | Framework principal para desenvolvimento mobile |
| PokeAPI | API REST pública utilizada como fonte de dados |
| sqflite | Banco de dados SQLite local para persistência dos favoritos |
| http | Requisições HTTP à PokeAPI |
| cached_network_image | Cache automático das imagens carregadas da web (pub.dev) |

---
## Estrutura do Projeto

```
lib/
├── main.dart              # Ponto de entrada do aplicativo
├── pokedex_app.dart       # Widget raiz e BottomNavigationBar
├── pokemon.dart           # Modelo, SQLite e Service (PokeAPI)
├── tela_lista.dart        # Tela de listagem e busca de Pokémons
├── tela_detalhes.dart     # Tela de detalhes e favoritar
└── tela_favoritos.dart    # Tela de Pokémons favoritos
```

---

## Como Executar

**Pré-requisitos:** Flutter SDK instalado e configurado.

```bash
# Clone o repositório
git clone https://github.com/ojhonata/ProjetoPokedex.git

# Entre na pasta
cd ProjetoPokedex

# Instale as dependências
flutter pub get

# Execute o aplicativo
flutter run
```
