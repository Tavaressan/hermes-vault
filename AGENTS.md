# Contexto do vault

Este diretório é ao mesmo tempo a base de conhecimento do Vitor e a memória persistente do agente.
Toda nota é Markdown puro, legível no Obsidian e versionada em Git.

## Estrutura e onde escrever

| Pasta | Uso | Quando escrever aqui |
|---|---|---|
| `00-hermes/` | Persona, memória, config | Nunca escreva à mão aqui; a memória é gerida pela ferramenta `memory` |
| `10-projetos/` | Projetos com entregável definido | Só após a nota ser revisada e promovida do inbox |
| `20-estudos/` | Material de estudo, resumos, roteiros | Notas de aprendizado consolidadas |
| `30-trabalho/` | Notas de trabalho | Contexto profissional |
| `90-inbox/` | Captura rápida | **Padrão para qualquer pesquisa nova** |

Fluxo: pesquisa nova nasce em `90-inbox/`. Depois de revisada por Vitor, é promovida para a pasta
de projeto ou estudo correspondente. Não pule essa etapa.

## Convenções de nota

- **Nome de arquivo**: kebab-case, descritivo, sem data no nome — `misra-cpp-2023.md`, não
  `2026-08-06-notas.md`. Notas diárias são a exceção (`YYYY-MM-DD.md`).
- **Primeira linha**: um `# Título` em linguagem natural.
- **Links**: use wiki-links `[[nome-do-arquivo]]` para conectar notas. Link generosamente — um
  link para uma nota que ainda não existe é válido e sinaliza o que falta escrever.
- **Tags**: no frontmatter YAML, não espalhadas no corpo.
  ```yaml
  ---
  tags: [automotive, cpp, safety]
  status: verificado | parcial | rascunho
  ---
  ```
- **MOC** (Map of Content): toda pasta de projeto começa por uma nota `00-moc-<tema>.md` que
  indexa e linka as demais.

## Regra de proveniência

Toda afirmação factual sobre o mundo externo — norma, versão, preço, cargo, estatística — carrega
**fonte e data de acesso**. Formato:

> MISRA C++:2023 substitui o AUTOSAR C++14.
> — [misra.org.uk/…](https://misra.org.uk/), acesso em 2026-08-06

O que não foi confirmado em fonte primária é marcado explicitamente:

> ⚠️ **Não verificado** — afirmação encontrada apenas em fonte secundária.

Distinga fato verificável, inferência e hipótese sempre que a diferença puder mudar uma decisão.
Nunca apresente inferência como fato estabelecido.

## Idioma

Português para o corpo das notas. Termos técnicos e identificadores de código permanecem na forma
original (`std::array`, `no_std`, ASIL D).
