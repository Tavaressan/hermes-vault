---
tags: [automotive, rust, ferrocene, safety, autosar]
status: verificado
---

# Rust na indústria automotiva

## O gargalo nunca foi a linguagem

Como estabelecido em [[normas-e-processo]], a ISO 26262-8 exige justificativa para
qualquer ferramenta capaz de introduzir erro no produto. Um compilador é exatamente
isso. Por anos, esse foi o motivo real pelo qual Rust não entrava em projeto ASIL: não
havia toolchain com evidência de qualificação. A linguagem já era boa; faltava o papel.

## Ferrocene — o toolchain qualificado

Ferrocene é o toolchain Rust open source qualificado para uso em sistemas críticos de
segurança e de missão, em automotivo, industrial, médico e aeroespacial. **A
certificação é da TÜV SÜD.**

| Norma | Nível certificado |
|---|---|
| ISO 26262 (automotivo) | **ASIL D** |
| IEC 61508 (industrial) | **SIL 3** |
| IEC 62304 (médico) | **Classe C** |

> — [ferrocene.dev](https://ferrocene.dev/en/), acesso em 2026-08-06.
> ⚠️ **Discrepância registrada:** o `README.md` do repositório afirma "IEC 61508 (SIL 4)",
> enquanto o site oficial e o documento `ferrocene/doc/core-certification/src/safety-plan/scope.rst`
> dizem **SIL 3**. Adotei SIL 3, o valor do site oficial e do escopo de certificação.
> Fonte da discrepância: [github.com/ferrocene/ferrocene](https://github.com/ferrocene/ferrocene) (via Context7), acesso em 2026-08-06.

Distinção importante entre **toolchain qualificado** e **biblioteca certificada** — são
coisas diferentes e o segundo é mais recente:

- O *toolchain* (compilador) é qualificado a TCL3/ASIL D (ISO 26262), T3 (IEC 61508) e IEC 62304
- A *biblioteca `core`* tem certificação própria e mais restrita. Na release **26.02.0**,
  o subset certificado do `core` foi significativamente expandido, atingindo
  **IEC 61508 SIL 2 e ISO 26262 ASIL B**. Alvos com `core` certificado ganharam
  equivalentes `*-ferrocene-*` que incluem uma implementação mínima certificada de `panic`.

> — [release notes 26.02.0](https://github.com/ferrocene/ferrocene/blob/main/ferrocene/doc/release-notes/src/26.02.0.rst), acesso em 2026-08-06.

Ou seja: **compilar com ASIL D não significa que a biblioteca padrão está coberta a
ASIL D.** Esse detalhe define o que você pode usar no código, e é o tipo de coisa que
derruba um plano de projeto tarde demais.

**Plataformas suportadas**: Linux, QNX e bare metal em Armv8-A e Armv7E-M. A 26.02.0
adicionou `thumbv7em-m4-none-eabihf` e `aarch64-a53-none` como alvos suportados e
qualificados. Release corrente no site: **26.05.0**.

Ferrocene também mantém a **Ferrocene Language Specification (FLS)** — a especificação
formal da linguagem que a qualificação exige. A FLS começou como esforço da indústria e
hoje tem casa sustentável dentro do próprio Rust Project, com equipe ativa de manutenção.

## AUTOSAR: o grupo de trabalho

O AUTOSAR decidiu formar um subgrupo dentro do **Working Group for Functional Safety
(WG-SAF)** para investigar como Rust poderia ser aplicado no contexto da **Adaptive
Platform**. O anúncio é de **06/04/2022**. O responsável pelo conteúdo é **Christof Petig**.

> "The decision to form a subgroup within the Working Group for Functional Safety (WG-SAF)"
> — [autosar.org — AUTOSAR investigates how the Programming Language Rust could be applied in Adaptive Platform Context](https://www.autosar.org/news-events/detail/autosar-investigates-how-the-programming-language-rust-could-be-applied-in-adaptive-platform-context-within-the-working-group-safety), acesso em 2026-08-06.

Note o verbo: **investigar**. Quatro anos depois, isso não é o mesmo que uma
especificação Rust normativa do AUTOSAR. Não confirmei que exista uma; trate como
sinal de direção institucional, não como padrão disponível.

## Safety-Critical Rust Consortium

Iniciativa da **Rust Foundation** que organiza requisitos e coordena o trabalho entre os
interessados da indústria de sistemas críticos e o Rust Project. Entregável em
desenvolvimento: as **Safety-Critical Rust Coding Guidelines**
([github.com/rustfoundation/safety-critical-rust-coding-guidelines](https://github.com/rustfoundation/safety-critical-rust-coding-guidelines))
— o análogo funcional do que o MISRA é para C++.

> — [Rust Blog — What does it take to ship Rust in safety-critical? (2026-01-14)](https://blog.rust-lang.org/2026/01/14/what-does-it-take-to-ship-rust-in-safety-critical/), acesso em 2026-08-06.

## As lacunas reais — fonte oficial, e vale ler inteira

O post do Rust Blog de janeiro de 2026 é a avaliação mais honesta que encontrei, e vem
do próprio projeto:

- **O ecossistema afina rápido acima de protótipo.** Dependências de terceiros ficam
  "difíceis de justificar" além do estágio de protótipo, em contexto ASIL B+. Cada crate
  precisa da mesma evidência que o resto do produto.
- **Não há geração de código Rust a partir de MATLAB/Simulink.** Isso é grande: boa parte
  do software de controle automotivo é gerada a partir de modelos.
- **Não há RTOS em Rust compatível com OSEK ou AUTOSAR Classic.**
- **Deriva de versão**: equipes fixam a versão do Rust, mas quase todas as crates são
  implementadas para as versões mais recentes.
- **Runtime assíncrono não está resolvido** para uso de criticidade mais alta — ver [[embassy]].
- **Atrito de plataforma-alvo**: QNX é suportado, mas atualmente apenas `no_std`.

## Adoção por montadoras

Volvo é citada como usando Rust para desenvolver software novo para seus carros, e
listas de fabricantes "adotando Rust" circulam amplamente (Ford, GM, BMW, Bosch,
Volkswagen, Toyota).

> ⚠️ **Não verificado.** Só encontrei essas afirmações em fontes secundárias, sem
> comunicado oficial das montadoras e sem escopo definido — "usa Rust" pode significar
> desde ferramental interno até código embarcado em ECU. Não use como evidência de
> adoção em produção crítica.

A SAE International formou uma força-tarefa para produzir um documento de diretrizes de
escrita de software crítico em Rust para automotivo e aviônica — também não verificado
em fonte primária.

## Leitura honesta do estado atual

O caminho está aberto e não é mais teórico: existe toolchain qualificado a ASIL D,
existe especificação de linguagem com casa institucional, existe grupo no AUTOSAR e
existe consórcio produzindo guidelines. O que ainda não existe é o **ecossistema
periférico** que a indústria assume como dado em C++: geração a partir de modelo, RTOS
compatível, crates com evidência de qualificação, e uma história resolvida de async.

Para quem estuda hoje: aprender Rust embarcado é investimento com horizonte, não
habilidade imediatamente empregável em ECU crítica. C++ continua sendo onde estão as vagas.

## Relacionadas

[[embassy]] · [[cpp-e-rust-interop]] · [[normas-e-processo]] · [[plataformas-autosar]] · [[roteiro-de-estudos]]
