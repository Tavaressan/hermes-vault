---
tags: [automotive, safety, iso26262, aspice, processo]
status: parcial
---

# Normas e processo

O ponto que não é óbvio para quem vem de software convencional: nesta indústria o
entregável não é o binário, é o **argumento de segurança** — um corpo de evidências
que sustenta a afirmação de que o risco residual é aceitável. O código é uma das
evidências, não o produto. Isso explica quase todas as restrições que parecem
arbitrárias nas outras notas deste dossiê.

## O quadro de normas

| Norma | Objeto | Relação com o código |
|---|---|---|
| **ISO 26262** | Segurança funcional de E/E em veículos de série | Define ASIL, exige rastreabilidade, cobertura estrutural, qualificação de ferramenta |
| **ISO 21448 (SOTIF)** | Segurança da funcionalidade pretendida | Trata do risco quando *não há falha* — o sistema funciona como especificado e ainda assim é inseguro (típico de percepção/ADAS) |
| **ISO/SAE 21434** | Cybersecurity veicular | Análise de ameaça (TARA), ciclo de vida de segurança cibernética |
| **ASPICE** | Maturidade de processo | Avalia *como* a organização desenvolve, não o produto; frequentemente exigido em contrato pela montadora |

ISO 26262 e SOTIF são complementares, não alternativas: a primeira cobre risco por
mau funcionamento, a segunda cobre risco por limitação funcional sem falha.

## ASIL — o que ele realmente controla

ASIL (Automotive Safety Integrity Level) vai de A a D, com QM ("quality managed")
abaixo de A para o que não tem implicação de segurança. É derivado de três eixos na
análise de perigo: **severidade**, **exposição** e **controlabilidade**.

O ASIL não é uma etiqueta de qualidade — ele é a chave que seleciona, nas tabelas da
norma, quais métodos passam de "recomendado" a "altamente recomendado". Duas
consequências diretas no dia a dia de quem escreve C++:

- **Cobertura estrutural** sobe com o ASIL. Em nível de unidade, cobertura de ramo
  (*branch*) é esperada a partir de ASIL B; **MC/DC** entra em ASIL C e D.
  > — [Parasoft — Code Coverage: ISO 26262 Software Compliance](https://www.parasoft.com/learning-center/iso-26262/code-coverage/), acesso em 2026-08-06.
  > ⚠️ **Não verificado em fonte primária** — as tabelas da ISO 26262-6 são pagas.
  > Fontes secundárias (vendedores de ferramenta de teste) convergem nesse ponto, mas
  > confirme na norma antes de usar em decisão contratual.
- **Guia de codificação obrigatório**: a norma exige uso de um subset de linguagem e
  de um coding standard — é daí que vem a obrigatoriedade prática do
  [[misra-cpp-2023]], não de uma preferência técnica.

## Qualificação de ferramenta (ISO 26262-8)

Toda ferramenta que pode introduzir um erro no produto — ou deixar de detectar um —
precisa de justificativa. O mecanismo é o **TCL** (Tool Confidence Level), derivado do
impacto potencial (TI) e da probabilidade de detecção (TD). Ferramentas de teste
costumam cair em TCL3, o nível mais exigente, porque um defeito nelas deixa passar um
erro sem detecção.

> — [Solid Sands — Compiler and Library Qualification for ISO 26262](https://solidsands.com/safety/iso-26262) e
> [MathWorks — Qualifying Software Tools According to ISO 26262](https://www.mathworks.com/content/dam/mathworks/tag-team/Objects/m/61793_CMR10-16.pdf), acesso em 2026-08-06.

Esse mecanismo é a razão de existir do Ferrocene — ver [[rust-na-industria-automotiva]].
Sem um toolchain com evidência de qualificação, a linguagem não entra em projeto ASIL,
por melhor que seja.

## ASPICE — o eixo ortogonal

ASPICE não avalia o produto; avalia se o processo é capaz de produzir consistentemente.
Uma montadora pode exigir nível de capacidade ASPICE em contrato independentemente do
ASIL do item. Na prática isso se traduz em exigência de rastreabilidade bidirecional
entre requisito, projeto, código e teste — ver [[verificacao-e-teste]].

## O que ainda falta verificar nesta nota

- Conteúdo exato das tabelas da ISO 26262-6 (métodos por ASIL) — exige a norma
- Se a edição vigente da ISO 26262 continua sendo a de 2018 (2ª edição) ou se houve
  revisão posterior — não confirmado
