---
tags: [automotive, teste, cobertura, mcdc, hil, iso26262]
status: parcial
---

# Verificação e teste

## Cobertura estrutural

A métrica de cobertura exigida escala com o ASIL. Em nível de unidade, o padrão relatado
consistentemente:

| ASIL | Cobertura em nível de unidade |
|---|---|
| A | statement |
| B | **branch** (decisão) |
| C, D | **MC/DC** |

> — [Parasoft — Code Coverage: ISO 26262 Software Compliance](https://www.parasoft.com/learning-center/iso-26262/code-coverage/) e
> [GSAS — ISO 26262 Part 6 Unit Testing Requirements](https://gsasindia.com/blog/razorcat-iso-26262-unit-testing-checklist), acesso em 2026-08-06.
> ⚠️ **Não verificado em fonte primária** — as tabelas da ISO 26262-6 estão em norma paga.
> As fontes acima são de fornecedores de ferramenta de teste (secundárias, mas com
> credencial no domínio) e convergem. Confirme antes de usar em compromisso contratual.

### O que MC/DC realmente exige

*Modified Condition/Decision Coverage* exige demonstrar que **cada condição atômica
dentro de uma decisão afeta o resultado da decisão de forma independente**. Não basta
exercitar a decisão como verdadeira e falsa.

Para `if (a && b)`, cobertura de decisão precisa de dois casos. MC/DC precisa mostrar que
`a` sozinho muda o resultado (com `b` fixo) e que `b` sozinho muda o resultado (com `a`
fixo) — o que exige, no mínimo, três casos de teste.

Implicação de projeto que vale internalizar: **condições booleanas compostas multiplicam
o custo de teste.** Um `if` com cinco condições é caro de cobrir a MC/DC. Isso empurra
para decisões simples e funções pequenas — e é uma das razões pelas quais o código
automotivo tem a forma que tem, independentemente de gosto estético.

Curto-circuito (`&&`, `||`) interage com MC/DC de forma não trivial e é um ponto onde as
ferramentas divergem em interpretação.

## Rastreabilidade

ASPICE e ISO 26262 exigem rastreabilidade **bidirecional**: de cada requisito para o
elemento de projeto, para o código que o implementa e para os testes que o verificam — e
de volta. Todo trecho de código deve ser rastreável a um requisito; requisito sem teste é
achado de auditoria.

Isso é gerido em ferramenta (DOORS, Polarion, Codebeamer) e não em planilha. É também o
que torna "refatoração oportunista" cara nesse ambiente: mexer no código quebra links de
rastreabilidade que precisam ser reestabelecidos e reevidenciados.

## Níveis de teste

| Nível | O que roda | Onde |
|---|---|---|
| **Unit** | função/classe isolada | host (PC) ou alvo |
| **Integração de software** | componentes juntos | host ou alvo |
| **SIL** (Software-in-the-Loop) | software completo contra modelo de planta | host |
| **PIL** (Processor-in-the-Loop) | binário no processador alvo, planta simulada | alvo + host |
| **HIL** (Hardware-in-the-Loop) | ECU real, planta e barramento simulados em tempo real | bancada |
| **Veículo** | tudo real | pista |

O ponto crítico é o **teste no alvo**: cobertura medida no host não substitui execução no
processador real. Compilador, tamanho de word, alinhamento e otimização diferem, e a
norma quer evidência do que efetivamente executa no veículo. Instrumentar para cobertura
no alvo é um problema técnico em si — a instrumentação altera timing e consome memória, o
que pode mascarar ou introduzir comportamento.

## Ferramentas de teste unitário

- **GoogleTest** é comum em código de host e em Adaptive Platform
- Frameworks especializados em embarcado crítico (VectorCAST, Tessy, LDRA tbrun, Cantata)
  são preferidos quando é preciso gerar evidência formatada para auditoria e integrar com
  a cadeia de rastreabilidade

A escolha raramente é técnica: é sobre qual ferramenta produz o pacote de evidência que
o auditor espera.

## O ponto que muda a intuição de quem vem de fora

Neste ambiente, **teste não existe para encontrar bug — existe para produzir evidência**.
Encontrar bug é efeito colateral bem-vindo. Isso explica por que a cobertura é uma meta
numérica dura, por que testes são rastreados a requisitos, e por que "esse teste não
agrega, é óbvio que funciona" não é um argumento aceito.

## O que ainda falta verificar nesta nota

- Conteúdo exato das tabelas 26262-6 sobre métodos de teste por ASIL
- Se há exigência normativa explícita de execução no alvo, ou se é prática consolidada
- Tratamento normativo de código morto e de código desativado (*deactivated code*)

## Relacionadas

[[normas-e-processo]] · [[toolchain-e-qualificacao]] · [[subset-cpp-na-pratica]]
