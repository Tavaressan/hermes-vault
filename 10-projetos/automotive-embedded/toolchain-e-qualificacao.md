---
tags: [automotive, toolchain, static-analysis, iso26262, qualificacao]
status: parcial
---

# Toolchain e qualificação de ferramenta

## Por que a ferramenta precisa de evidência

Recapitulando [[normas-e-processo]]: a ISO 26262-8 exige que toda ferramenta capaz de
introduzir um erro no produto — ou de deixar de detectar um — tenha sua confiança
justificada. O mecanismo é o **TCL** (Tool Confidence Level), derivado do impacto
potencial da ferramenta (TI) e da probabilidade de o erro ser detectado por outro meio (TD).

Ferramentas de teste são classificadas em **TCL3**, o nível mais exigente, porque um
defeito nelas deixa um erro passar sem detecção.

> — [Solid Sands](https://solidsands.com/safety/iso-26262) e
> [MathWorks — Qualifying Software Tools According to ISO 26262](https://www.mathworks.com/content/dam/mathworks/tag-team/Objects/m/61793_CMR10-16.pdf), acesso em 2026-08-06.

A consequência econômica: **não se troca de compilador em projeto ASIL com leveza.** O
kit de qualificação é caro e vem do fornecedor.

## Compiladores

O mercado é dominado por fornecedores que vendem o compilador **junto do kit de
qualificação** — o artefato comercial é a evidência, não só o binário.

- **Green Hills** (MULTI / Compiler) — presença histórica forte em automotivo e aviônica
- **TASKING** — compiladores para TriCore/AURIX (Infineon), muito usado em powertrain
- **QNX / BlackBerry** — SO e toolchain, forte na Adaptive Platform
- **Wind River (VxWorks)** — mais aviônica/industrial, presente em automotivo
- **GCC / LLVM com kit de qualificação de terceiro** — existe caminho via fornecedores
  que vendem qualificação para toolchain open source

Para bibliotecas C/C++, há kits de qualificação dedicados — a HighTec, por exemplo,
comercializa um *Library Qualification Kit* para ASIL D.
> — [HighTec — ASIL-D Qualification of C/C++ Libraries](https://hightec-rt.com/products/qkit-library-qualification-kit), acesso em 2026-08-06.

Comparação útil: é exatamente esse modelo que o **Ferrocene** replica para Rust — ver
[[rust-na-industria-automotiva]]. Ele não é "um Rust diferente"; é o `rustc` acompanhado
do corpo de evidência que a norma exige.

## Análise estática

Obrigatória na prática — é o que operacionaliza o [[misra-cpp-2023]]. As ferramentas de
referência:

| Ferramenta | Fornecedor | Nota |
|---|---|---|
| **Polyspace** (Bug Finder / Code Prover) | MathWorks | Code Prover faz *abstract interpretation* — prova ausência de certas classes de erro em runtime, não apenas detecta padrões |
| **Helix QAC** | Perforce | Linhagem QA-C/QA-C++; forte em conformidade MISRA, com módulo de compliance |
| **Coverity** | Black Duck (ex-Synopsys) | Análise de fluxo interprocedural |
| **LDRA** | LDRA | Suíte que cobre análise estática + cobertura estrutural + rastreabilidade |
| **PC-lint Plus** | Gimpel | Mais leve e barato; muito usado |
| **Parasoft C/C++test** | Parasoft | Análise + teste unitário + cobertura |

Distinção que vale entender: **detecção de padrão** (encontra construções suspeitas, pode
ter falso positivo e falso negativo) versus **verificação formal / interpretação
abstrata** (prova que uma classe de erro não ocorre em nenhum caminho, ao custo de tempo
de análise e de falsos positivos por imprecisão). Polyspace Code Prover é do segundo tipo;
a maioria é do primeiro.

Lembrete de [[misra-cpp-2023]]: rodar a ferramenta e zerar avisos **não** é conformidade
MISRA. É preciso o processo do MISRA Compliance — matriz de conformidade e desvios
registrados e justificados.

## Regras indecidíveis

Nem toda regra MISRA é verificável por ferramenta. As classificadas como *undecidable*
exigem revisão humana ou análise mais custosa. Isso significa que a conformidade tem um
componente irredutível de revisão manual — e que o custo de conformidade não cai a zero
comprando ferramenta.

## O que ainda falta verificar nesta nota

- Quais compiladores têm certificação vigente e para quais ASIL/alvos — muda por versão
  e não consultei os certificados
- Se há kit de qualificação estabelecido para Clang/LLVM em automotivo
- Posição de mercado atual: o setor de ferramentas passou por consolidação (Synopsys
  Software Integrity → Black Duck) e não confirmei a situação atual de cada produto

## Relacionadas

[[normas-e-processo]] · [[misra-cpp-2023]] · [[verificacao-e-teste]] · [[rust-na-industria-automotiva]]
