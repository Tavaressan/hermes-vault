# hermes-vault

Vault Obsidian que serve simultaneamente como base de conhecimento pessoal e como memória
persistente do [Hermes Agent](https://github.com/NousResearch/hermes-agent).

## Como funciona

O Hermes fixa sua memória em `$HERMES_HOME/memories/` e sua persona em `$HERMES_HOME/SOUL.md`,
sem opção de reconfigurar o caminho. A posse foi invertida: os arquivos reais moram aqui no vault,
e `~/.hermes/` aponta para eles por symlink. Resultado — a memória do agente é versionada em Git,
legível e editável no Obsidian, e sincronizada entre máquinas.

```
~/.hermes/memories  ->  00-hermes/memories/   (MEMORY.md, USER.md)
~/.hermes/SOUL.md   ->  00-hermes/SOUL.md
```

O que **não** vive aqui, por conter segredos ou caminhos de máquina: `~/.hermes/config.yaml`,
`~/.hermes/.env`, `~/.hermes/sessions/`. Para replicar a configuração em outra máquina use
[[00-hermes/config.example.yaml]].

## Estrutura

| Pasta | Conteúdo |
|---|---|
| `00-hermes/` | Persona, memória e configuração do agente |
| `10-projetos/` | Projetos de pesquisa com entregável definido |
| `20-estudos/` | Material de estudo e notas de aprendizado |
| `30-trabalho/` | Notas de trabalho |
| `90-inbox/` | Captura rápida; toda pesquisa nova nasce aqui |

## Sincronização

Plugin [Obsidian Git](https://github.com/Vinzent03/obsidian-git) (Settings → Community plugins),
com auto commit-and-sync por intervalo e auto pull ao iniciar.

Para conectar ao remoto:

```bash
git remote add origin git@github.com:<usuario>/hermes-vault.git
git push -u origin main
```

O repositório deve ser **privado** — a memória do agente contém informações pessoais.

Para configurar a segunda máquina (Windows), ver [[00-hermes/setup-windows]].
