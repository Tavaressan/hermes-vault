---
tags: [rust, embassy, async, embedded, no-std]
status: verificado
---

# Embassy — async embarcado em Rust

## O que é

Embassy é um conjunto de crates que traz `async`/`await` para embarcado `no_std`. A peça
central é o **`embassy-executor`**: um executor async para sistemas embarcados que
**não requer alocação dinâmica de memória nem heap**.

Propriedades do executor, da documentação oficial:

- **Tarefas são alocadas estaticamente**, com tamanho exato de memória determinado em
  tempo de compilação — o que previne pânico por esgotamento de memória em runtime
- Suporta número variável de tarefas sem configuração
- Fila de temporizadores integrada, o que torna trivial dormir
- **Não faz busy-loop**: coloca a CPU para dormir quando ocioso, usando interrupções ou
  as instruções WFE/SEV
- Faz *poll* apenas das tarefas acordadas
- Escalonamento justo — nenhuma tarefa monopoliza a CPU

> — [docs.embassy.dev/embassy-executor](https://docs.embassy.dev/embassy-executor/0.10.0/cortex-m/index.html), acesso em 2026-08-06 via Context7.

Esse conjunto — alocação estática, tamanho conhecido em compile time, sem heap, sem
busy-loop — é notável porque são exatamente as propriedades que [[subset-cpp-na-pratica]]
descreve como exigência de um projeto ASIL. Embassy chega nelas por construção, não por
restrição imposta de fora.

## HALs

O projeto mantém camadas de abstração de hardware por família:

| Crate | Cobertura |
|---|---|
| `embassy-stm32` | **todas as famílias de chips STM32** |
| `embassy-nrf` | família nRF da Nordic — APIs seguras e idiomáticas, sem manipulação de registrador cru; operação bloqueante e assíncrona |
| `embassy-rp` | RP2040 |

As HALs aderem ao padrão **`embedded-hal`**, o que garante interoperabilidade com o
restante do ecossistema Rust embarcado. As APIs async têm a vantagem de tratar espera de
periférico e interrupção em modo de baixo consumo, liberando a aplicação para outras
tarefas.

## `embassy-time` e o driver de tempo

O tempo é abstraído por uma trait `Driver` implementável pelo integrador
(`now()` e `schedule_wake()`), registrada globalmente pela macro `time_driver_impl!`.
Isso desacopla o executor do timer de hardware específico.

## Comparação com as alternativas

| | Embassy | RTIC | RTOS clássico (FreeRTOS, AUTOSAR OS) |
|---|---|---|---|
| Modelo | tarefas async cooperativas | tarefas orientadas a interrupção, escalonador por prioridade em hardware | threads preemptivas |
| Pilha | uma pilha compartilhada | uma pilha compartilhada | **uma pilha por thread** |
| Custo de troca | poll de future, muito baixo | disparo de interrupção | troca de contexto completa |
| Concorrência | cooperativa — uma tarefa que não `.await` bloqueia | preemptiva por prioridade | preemptiva |
| Certificação | **nenhuma** | nenhuma | variantes certificadas existem (SafeRTOS, AUTOSAR OS comerciais) |

O ponto de economia de memória é real: N tarefas async compartilham uma pilha, enquanto N
threads de RTOS exigem N pilhas dimensionadas pelo pior caso. Em microcontrolador com
dezenas de KB de RAM, isso decide a arquitetura.

O ponto de risco também é real: **concorrência cooperativa**. Uma tarefa que executa
trabalho longo sem ponto de `.await` bloqueia todas as outras da mesma prioridade. Em
sistema com deadline duro, isso transfere para o desenvolvedor uma responsabilidade que
o RTOS preemptivo assumia.

## O estado quanto a safety — sem rodeios

**Embassy não tem qualificação de segurança funcional.** Não há certificação TÜV, não há
kit de qualificação, não é reconhecido em nenhuma norma. Isso não é uma crítica ao
projeto — não é o objetivo dele.

E há um problema mais profundo que o simples "falta certificado": o próprio Rust Project
registra que **a história de runtime e qualificação de async não está resolvida** para
uso de criticidade mais alta.

> "the runtime and qualification story is not settled for higher-criticality use."
> — [Rust Blog — What does it take to ship Rust in safety-critical? (2026-01-14)](https://blog.rust-lang.org/2026/01/14/what-does-it-take-to-ship-rust-in-safety-critical/), acesso em 2026-08-06.

A dificuldade é de fundo: um executor async gera uma máquina de estados pelo compilador,
e argumentar sobre pior caso de tempo de execução (WCET) e sobre a cobertura estrutural
dessa máquina de estados gerada é território pouco trilhado nas normas. Nenhuma tabela
da ISO 26262 foi escrita pensando em `async fn`.

Some-se a isso a lacuna registrada em [[rust-na-industria-automotiva]]: não existe RTOS
em Rust compatível com OSEK ou AUTOSAR Classic.

## Onde Embassy faz sentido hoje

- Protótipo e pesquisa em embarcado Rust
- Produto embarcado **sem requisito de certificação** — IoT, consumo, industrial QM,
  ferramental de bancada
- Aprendizado: é provavelmente a melhor porta de entrada para embarcado Rust moderno
- Domínios QM dentro de um veículo (infotenimento não-crítico, telemetria)

**Não** faz sentido, hoje, para o item com ASIL atribuído. Confundir "Rust é seguro" com
"esta stack Rust é certificável" é o erro mais comum nessa conversa.

## Relacionadas

[[rust-na-industria-automotiva]] · [[cpp-e-rust-interop]] · [[subset-cpp-na-pratica]] · [[roteiro-de-estudos]]
