---
tags: [automotive, cpp, misra, autosar, coding-standard]
status: parcial
---

# MISRA C++:2023 e o fim do AUTOSAR C++14

## O fato central

**MISRA C++:2023 — "Guidelines for the use of C++:17 in critical systems" — foi
publicado em outubro de 2023 e é a edição vigente.** Ele tem como alvo o **C++17**.

> — [misra.org.uk](https://misra.org.uk/product-category/misra-c), acesso em 2026-08-06.

A história importa para entender o cenário atual: MISRA C++ nasceu em 2008; em **2017 a
MISRA anunciou que integraria as diretrizes AUTOSAR C++ na nova versão** do MISRA C++,
incorporando o C++17 e, quando disponível, o C++20.

> "in 2017 it was announced that MISRA will integrate the AUTOSAR C++ guidelines in the
> new version of MISRA C++."
> — [misra.org.uk](https://misra.org.uk/), acesso em 2026-08-06.

O efeito prático: **AUTOSAR C++14 e MISRA C++:2008 convergiram em um único documento.**
Projeto novo não deveria mais adotar o AUTOSAR C++14 como standard de codificação —
ele foi absorvido. Projetos legados obviamente continuam nele.

## MISRA Compliance é referência obrigatória

Esse ponto é frequentemente ignorado e é onde as auditorias pegam:

> "a credible claim of compliance with MISRA C and MISRA C++ guidelines can only be made
> when code is developed under a process which meets the principles laid out in the
> MISRA Compliance document. […] forms a Mandatory reference to MISRA C:2023 and
> MISRA C++:2023."
> — [misra.org.uk/compliance](https://misra.org.uk/compliance), acesso em 2026-08-06.

Ou seja: rodar um analisador estático e zerar os avisos **não** produz conformidade
MISRA. Conformidade é uma propriedade do processo — inclui matriz de conformidade,
classificação de desvios e registro justificado de cada um. O documento MISRA Compliance
supersede as regras de conformidade e desvio que vinham nos guias anteriores.

## Estrutura das diretrizes

As diretrizes são organizadas em **directives** (não verificáveis apenas pelo código —
exigem julgamento sobre processo ou documentação) e **rules** (verificáveis no código),
agrupadas em seções que espelham as seções do próprio padrão C++.

Cada uma carrega duas classificações ortogonais:

- **Categoria**: *Mandatory* (desvio não permitido), *Required* (desvio permitido com
  justificativa registrada), *Advisory* (recomendação; a não adesão deve ser documentada).
- **Decidibilidade**: *decidable* ou *undecidable* — se uma ferramenta pode, em geral,
  decidir a conformidade por análise estática. Regras indecidíveis exigem revisão humana
  ou análise mais cara.

> ⚠️ **Não verificado — números conflitantes.** Fontes secundárias divergem sobre a
> contagem: uma reporta "179 diretrizes (4 directives + 175 rules)", outra reporta
> "42 Mandatory, 127 Required, 86 Advisory" — que soma 255 e é incompatível com a
> primeira. Não use nenhum desses números sem checar o documento oficial.
> Fontes: [Parasoft](https://www.parasoft.com/blog/misra-cpp-2023-guide/),
> [all-about-industries](https://www.all-about-industries.com/safety-critical-software-misra-c2023-from-a-to-z-a-b4e8def416835b51d1c27ca7607e14d8/),
> acesso em 2026-08-06.

## MISRA vs AUTOSAR: a diferença de escopo que sobreviveu

O AUTOSAR C++14 não era só um guia de codificação — trazia recomendações sobre projeto,
infraestrutura de toolchain e documentação. **O MISRA foca na implementação.** Ao migrar
de AUTOSAR C++14 para MISRA C++:2023, parte da orientação não-código do AUTOSAR não tem
correspondente direto e precisa ser reancorada no processo (ASPICE, plano de segurança).

## Ponto de atrito com as C++ Core Guidelines

O AUTOSAR publicou uma comparação indicando que **cerca de 30% das C++ Core Guidelines
conflitam com as regras AUTOSAR**.

> — [Perforce — Introduction to MISRA C++:2023](https://www.perforce.com/blog/qac/misra-cpp-2023-intro), acesso em 2026-08-06.

Não é uma curiosidade: significa que trazer hábitos das Core Guidelines para um projeto
automotivo produz violações reais. As duas partem de premissas diferentes — Core
Guidelines otimizam para expressividade segura em C++ moderno de propósito geral; MISRA
otimiza para analisabilidade e previsibilidade em sistema crítico.

Ver [[subset-cpp-na-pratica]] para o efeito concreto disso no código.

## O documento é pago

MISRA C++:2023 é vendido em misra.org.uk. Não há versão gratuita legítima. Ferramentas
de análise estática comerciais embutem os checks — ver [[toolchain-e-qualificacao]].

## Relacionadas

[[normas-e-processo]] · [[plataformas-autosar]] · [[subset-cpp-na-pratica]] · [[toolchain-e-qualificacao]]
