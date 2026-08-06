---
tags: [cpp, rust, interop, arquitetura, automotive]
status: rascunho
---

# C++ e Rust — trade-offs e adoção incremental

## Onde as duas linguagens se encontram

Uma observação que salta ao comparar [[subset-cpp-na-pratica]] com o Rust embarcado: as
duas convergem para as mesmas propriedades, por caminhos opostos.

| Propriedade exigida em ASIL | C++ automotivo chega por | Rust chega por |
|---|---|---|
| Sem alocação em regime permanente | **proibição externa** (regra MISRA, revisão) | `no_std` — a alocação não está disponível por padrão |
| Sem exceções | flag de compilador + regra | não existem exceções; `Result<T, E>` é o mecanismo |
| Erro explícito no tipo de retorno | `ara::core::Result<T, E>`, criado para isso | `Result<T, E>` na linguagem |
| Liberação determinística | RAII | ownership + `Drop` |
| Sem UB | dezenas de regras MISRA existem só para tornar UB inalcançável | o compilador rejeita em safe Rust |

A diferença de fundo: em C++ a segurança é **imposta por processo e verificada por
ferramenta**; em Rust boa parte dela é **imposta pelo compilador**. É por isso que a
promessa é atraente — parte do custo de conformidade migraria de revisão humana para
verificação automática.

O contra-argumento honesto: a ISO 26262 não dá crédito por garantia de linguagem. A
evidência ainda precisa ser produzida, e o `unsafe` — inevitável em drivers e acesso a
registrador — reabre a porta exatamente onde o hardware é tocado.

## Interoperabilidade

Adoção realista é incremental — Rust em módulos novos convivendo com base C++ existente.
As opções:

| Ferramenta | Direção | Nota |
|---|---|---|
| **`bindgen`** | C/C++ → Rust | Gera bindings Rust a partir de headers. Maduro para C; C++ tem limitações (templates, herança, sobrecarga) |
| **`cbindgen`** | Rust → C | Gera header C a partir de API Rust `extern "C"` |
| **`cxx`** | C++ ↔ Rust | Ponte segura bidirecional com esquema declarado dos dois lados; cobre tipos como `std::string`, `std::unique_ptr` |
| **`autocxx`** | C++ → Rust | Camada sobre `cxx` + `bindgen`, reduz o boilerplate |
| **FFI C manual** | ambas | O denominador comum: uma interface C entre os dois. Mais trabalho, menos surpresa |

> ⚠️ **Não verificado** — não confirmei o estado de manutenção atual de cada uma dessas
> crates nem se alguma tem uso reportado em contexto automotivo qualificado. Trate a
> tabela como mapa do território, não como recomendação.

Em contexto de segurança funcional, cada camada de geração automática de binding é
código gerado por ferramenta — e portanto sujeita ao raciocínio de qualificação de
ferramenta de [[toolchain-e-qualificacao]]. Uma FFI C escrita à mão pode ser mais barata
de justificar que um gerador sofisticado, mesmo sendo pior de escrever.

## Estratégia de adoção plausível

Ordenada por risco crescente, e ancorada nas lacunas registradas em
[[rust-na-industria-automotiva]]:

1. **Ferramental e infraestrutura** — build, geradores de código, análise, bancada de
   teste. Sem exposição a norma, ganho imediato, e forma pessoas.
2. **Componentes QM no veículo** — telemetria, infotenimento não-crítico, conectividade.
   Rust roda em produção sem carregar ASIL.
3. **Componentes ASIL baixo na Adaptive Platform** — processos isolados com fronteira de
   serviço `ara::com` bem definida. É o ponto que o WG-SAF do AUTOSAR está investigando,
   e o isolamento de processo torna o argumento de segurança tratável.
4. **Componentes ASIL alto** — hoje esbarra no `core` certificado apenas a ASIL B
   (Ferrocene 26.02.0), na ausência de crates com evidência, e na falta de geração a
   partir de Simulink.

O passo 4 não está bloqueado pela linguagem. Está bloqueado pelo ecossistema.

## Como decidir, honestamente

- **Projeto novo, ASIL C/D, powertrain ou chassi, com modelos Simulink** → C++ (ou C).
  A ausência de geração de código Rust a partir de modelo, sozinha, encerra a discussão.
- **Adaptive Platform, componente novo, ASIL B ou abaixo, equipe disposta** → Rust é
  defensável hoje, com Ferrocene, e o custo maior será o ecossistema, não a linguagem.
- **Qualquer coisa QM** → escolha por produtividade da equipe.
- **Base legada grande em C++** → a pergunta não é "migrar?", é "onde vale a fronteira?".
  Cada fronteira FFI é custo permanente.

## O que ainda falta verificar nesta nota

- Existe algum caso público documentado de Rust em componente automotivo com ASIL
  atribuído em produção?
- Estado atual de `cxx` e `autocxx`; alguma delas com kit de qualificação?
- Como o `unsafe` é tratado nas Safety-Critical Rust Coding Guidelines em elaboração

## Relacionadas

[[rust-na-industria-automotiva]] · [[subset-cpp-na-pratica]] · [[embassy]] · [[toolchain-e-qualificacao]] · [[plataformas-autosar]]
