---
tags: [automotive, autosar, cpp, arquitetura]
status: verificado
---

# AUTOSAR: Classic vs Adaptive

AUTOSAR é uma parceria de desenvolvimento que padroniza a arquitetura de software
automotivo. Entender a divisão em duas plataformas é pré-requisito para saber **onde
C++ é sequer permitido**.

Release corrente referenciada nesta nota: **R24-11** — as especificações estão públicas
em `autosar.org/fileadmin/standards/R24-11/`.
> ⚠️ Não confirmei se R24-11 continua sendo o release mais recente em agosto de 2026;
> o site usa renderização por JavaScript e não consegui extrair a lista de releases.

## Classic Platform (CP)

A plataforma tradicional, para ECUs de controle com requisitos duros de tempo real.

- Aplicação compilada em **um executável monolítico**, configurada em tempo de compilação
- Escalonamento estático, comportamento determinista
- Base histórica em **C**; é o mundo do OSEK/AUTOSAR OS
- Uso típico: powertrain, chassi, carroceria — o que precisa responder em microssegundos
  com jitter previsível

## Adaptive Platform (AP)

Para ECUs de alto poder computacional e arquitetura orientada a serviços (SOA) — o
domínio do *software-defined vehicle*.

- **A interface da Adaptive Platform é compatível com C++14**, escolha justificada pela
  disponibilidade de compiladores C++14 para dispositivos embarcados; projetos são
  livres para usar versões mais novas como C++17
- Aplicações são **processos separados**, mono ou multi-thread — não um monolito
- Configuração em **arquivos de Manifest no alvo**, não em tempo de compilação
- O runtime **liga serviços e clientes dinamicamente em tempo de execução**
- Base POSIX (perfil PSE51)

> — [AUTOSAR AP R24-11: Explanation of Adaptive Platform Software Architecture](https://www.autosar.org/fileadmin/standards/R24-11/AP/AUTOSAR_AP_EXP_SWArchitecture.pdf)
> e [Adaptive Platform Release Overview R24-11](https://www.autosar.org/fileadmin/standards/R24-11/AP/AUTOSAR_AP_TR_ReleaseOverview.pdf), acesso em 2026-08-06.

### `ara::com`

O middleware de comunicação da Adaptive Platform. Aplicações adaptativas se comunicam
por `ara::com`, que oferece o mecanismo padronizado de comunicação entre aplicações —
descoberta de serviço, eventos, métodos e campos, com o binding para o protocolo de
transporte (tipicamente SOME/IP) abstraído da aplicação.

O `ara::` é o namespace do AUTOSAR Runtime for Adaptive Applications: além de `ara::com`,
há `ara::core` (tipos fundamentais — ver [[subset-cpp-na-pratica]]), `ara::exec`
(gerenciamento de execução), `ara::log`, `ara::per` (persistência), entre outros.

## Comparação

| | Classic | Adaptive |
|---|---|---|
| Linguagem dominante | C | **C++14+** |
| Unidade de deploy | executável monolítico | processos independentes |
| Configuração | tempo de compilação | Manifest no alvo |
| Ligação de serviços | estática | **dinâmica, em runtime** |
| Tempo real | duro | soft / alto desempenho |
| Paradigma | orientado a sinal | **SOA** |
| SO | AUTOSAR OS (OSEK) | POSIX PSE51 |

> — sínteses de [LDRA — AUTOSAR Classic vs Adaptive](https://ldra.com/autosar/) e
> [MathWorks — Comparison of AUTOSAR Classic and Adaptive Platforms](https://www.mathworks.com/help/autosar/ug/autosar-platform-comparison.html), acesso em 2026-08-06.

## A implicação que importa para este dossiê

**C++ moderno vive na Adaptive Platform.** Quando alguém diz "trabalho com C++
automotivo", quase sempre é AP, middleware, ADAS ou ferramental — raramente uma ECU
Classic, que continua majoritariamente em C.

Isso também delimita onde Rust pode entrar primeiro: o grupo de trabalho de Rust no
AUTOSAR foi formado para investigar Rust **no contexto da Adaptive Platform**, não da
Classic — ver [[rust-na-industria-automotiva]]. Não é acidente: a AP tem processos
isolados, base POSIX e fronteiras de serviço bem definidas, o que torna a adoção
incremental viável.

## Relacionadas

[[misra-cpp-2023]] · [[subset-cpp-na-pratica]] · [[rust-na-industria-automotiva]] · [[normas-e-processo]]
