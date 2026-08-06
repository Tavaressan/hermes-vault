---
tags: [estudos, automotive, cpp, rust, roteiro]
status: rascunho
---

# Roteiro de estudos e referências

## Ordem sugerida

A sequência importa: estudar MISRA antes de entender por que a ISO 26262 existe produz a
impressão errada de que são regras arbitrárias.

1. **Por que as restrições existem** → [[normas-e-processo]]. Sem isso, o resto parece
   burocracia.
2. **Onde C++ vive** → [[plataformas-autosar]]. Define se você está estudando o mundo
   certo (AP, não CP).
3. **O dialeto** → [[subset-cpp-na-pratica]] e [[misra-cpp-2023]].
4. **Como se prova que funciona** → [[verificacao-e-teste]] e [[toolchain-e-qualificacao]].
5. **O vetor emergente** → [[rust-na-industria-automotiva]] e [[embassy]].

## Gratuito e de fonte primária

O melhor material aberto deste domínio:

- **Especificações AUTOSAR** — `autosar.org/fileadmin/standards/R24-11/`. Todas públicas
  em PDF. Comece por `AUTOSAR_AP_EXP_SWArchitecture.pdf` (arquitetura da Adaptive
  Platform) e pelo Release Overview.
- **[Rust Blog — What does it take to ship Rust in safety-critical? (2026-01-14)](https://blog.rust-lang.org/2026/01/14/what-does-it-take-to-ship-rust-in-safety-critical/)**
  — a avaliação mais honesta das lacunas, vinda do próprio projeto. Leitura curta e de
  alto retorno.
- **[Documentação do Ferrocene](https://github.com/ferrocene/ferrocene)** — o plano de
  qualificação e o documento de escopo são um curso gratuito sobre o que qualificação de
  ferramenta significa na prática, aplicável muito além de Rust.
- **[Safety-Critical Rust Coding Guidelines](https://github.com/rustfoundation/safety-critical-rust-coding-guidelines)**
  — em elaboração; acompanhar é acompanhar o campo se formando.
- **[embassy.dev](https://embassy.dev)** e **[docs.embassy.dev](https://docs.embassy.dev)**
  — documentação e exemplos.
- **[The Embedded Rust Book](https://docs.rust-embedded.org/book/)** — base de embarcado
  Rust, independente de Embassy.
- **[misra.org.uk/compliance](https://misra.org.uk/compliance)** — a página sobre
  conformidade é aberta e explica o conceito de desvio, mesmo sem o documento pago.

## Pago

- **MISRA C++:2023** — misra.org.uk. Não há alternativa legítima gratuita. Se você
  trabalha ou pretende trabalhar com C++ automotivo, é a compra que mais rende.
- **MISRA Compliance** — referência obrigatória do MISRA C++:2023; comprar um sem o outro
  deixa o trabalho incompleto.
- **ISO 26262** (12 partes) — iso.org. Cara. Na prática, a maioria acessa pela empresa.
  As partes que mais importam para quem escreve código: **Parte 6** (desenvolvimento de
  software) e **Parte 8** (processos de suporte, inclui qualificação de ferramenta).
- **ISO 21448 (SOTIF)** e **ISO/SAE 21434** — relevantes se você for para ADAS ou
  cybersecurity, respectivamente.

## Prática — o que dá para fazer sem uma bancada

Sem hardware automotivo, ainda há caminho real:

- **Rust + Embassy em placa barata** — STM32 Nucleo ou Raspberry Pi Pico (RP2040). A
  `embassy-stm32` cobre todas as famílias STM32. É a forma mais rápida de ter async
  embarcado rodando de verdade.
- **C++ com PC-lint Plus ou clang-tidy** em código próprio, aplicando as restrições de
  [[subset-cpp-na-pratica]] manualmente. Compile com `-fno-exceptions -fno-rtti` e
  observe o que quebra — o exercício ensina mais que ler a lista de regras.
- **Escrever um driver duas vezes**, em C++ restrito e em Rust `no_std`, e comparar. É o
  exercício que torna concreta a tabela de convergência em [[cpp-e-rust-interop]].
- **Medir cobertura MC/DC** com `gcov`/`llvm-cov` em uma função com condições compostas,
  para sentir o custo descrito em [[verificacao-e-teste]].

## Realismo sobre empregabilidade

Registrado sem rodeios, porque muda a alocação de tempo:

- **C++ é onde estão as vagas** em automotivo hoje, e continuará sendo pelos próximos
  anos. AUTOSAR Adaptive + C++14/17 + MISRA é o perfil procurado.
- **Rust é investimento com horizonte.** O toolchain qualificado existe, o AUTOSAR está
  investigando, e as lacunas de ecossistema estão documentadas — mas não é habilidade
  imediatamente empregável em ECU crítica.
- **O conhecimento de processo (ISO 26262, ASPICE) é o diferencial menos disputado.**
  Muita gente sabe C++; bem menos gente entende por que o código tem aquela forma e
  consegue conversar com o time de segurança funcional.

## O que ainda falta nesta nota

- Livros específicos — não pesquisei bibliografia; há material clássico de embarcado que
  vale mapear
- Cursos e certificações (TÜV Functional Safety Engineer, treinamentos AUTOSAR)
- Comunidades ativas do domínio

## Relacionadas

[[00-moc-automotive-embedded]] · [[normas-e-processo]] · [[rust-na-industria-automotiva]] · [[embassy]]
