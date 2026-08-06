---
tags: [ollama, llm-local, hardware, benchmark]
status: verificado
---

# Ollama no iMac 2015 — o que a medição mostrou

Medido em 2026-08-06. **Conclusão: inferência local neste hardware não serve para uso
agêntico.** O número abaixo é o fato que decide a arquitetura do agente.

## Hardware

| | |
|---|---|
| Máquina | iMac17,1 (Retina 5K, late 2015) |
| CPU | Intel Core i5-6500 — 4 núcleos, 4 threads, sem SMT |
| Instruções | AVX2; **sem AVX-512** |
| RAM | 24 GB |
| GPU | AMD Radeon R9 M380, 2 GB VRAM — **inutilizável** |
| Disco | SSD APFS, ~54 GB livres |

## GPU: descartada, com motivo

O Ollama só despacha Metal em Apple Silicon; em Mac Intel ele ignora GPUs de terceiros,
porque a Apple removeu os drivers de eGPU e não há caminho Metal/ROCm para a Radeon.
Ainda que houvesse, 2 GB de VRAM não comportam nem um modelo 3B com contexto.
**Toda a inferência roda em CPU** (`num_gpu = 0`).

> — [ollama/ollama#1016](https://github.com/ollama/ollama/issues/1016),
> [#5071](https://github.com/ollama/ollama/issues/5071), acesso em 2026-08-06.

## Configuração testada

```
FROM granite4:7b-a1b-h
PARAMETER num_ctx 32768
PARAMETER num_thread 4
```
Servidor com `OLLAMA_FLASH_ATTENTION=1`, `OLLAMA_KV_CACHE_TYPE=q8_0`,
`OLLAMA_KEEP_ALIVE=30m`, `OLLAMA_NUM_PARALLEL=1`. Pesos em Q4_K_M (default das tags).

## Resultado

Prompt idêntico nos dois (49 tokens de entrada, resposta técnica em dois parágrafos):

| modelo | arquitetura | params ativos | **eval rate** | duração total |
|---|---|---|---|---|
| `granite4-agent` (7b-a1b-h) | MoE híbrido Mamba-2 | ~1B | **1,90 tok/s** | 2m42s (283 tok) |
| `granite4:3b-h` | denso híbrido | 3B | **0,44 tok/s** | 9m13s (237 tok) |

Prompt eval (leitura da entrada) ficou em 9,6 e 11,9 tok/s respectivamente — a leitura é
~5–25× mais rápida que a geração, como esperado em CPU.

## Leitura honesta do resultado

**A hipótese arquitetural se confirmou; a expectativa de magnitude, não.**

O que acertei: em CPU, a velocidade escala com parâmetros **ativos**, não totais. O MoE de
~1B ativos foi **4,3× mais rápido** que o denso de 3B, apesar de ser um modelo maior em
disco (4,2 GB contra 1,9 GB). Escolher MoE híbrido em vez de denso foi a decisão certa.

O que errei: previ que isso resultaria em algo utilizável. **1,90 tok/s não é.** Uma
resposta curta leva ~2,5 minutos. Um turno agêntico real — system prompt de milhares de
tokens, várias chamadas de ferramenta, cada uma com nova passada de contexto — leva
dezenas de minutos. Não há tuning que resolva uma ordem de magnitude: o gargalo é a
largura de banda de memória de uma plataforma de 2015 sem aceleração.

Corolário: `q8_0` no cache K/V e `flash attention` estavam ativos na medição e não
mudaram o quadro. Num híbrido Mamba-2 só ~1 em cada 10 camadas usa atenção, então o
ganho do cache quantizado é estruturalmente pequeno aqui — como eu suspeitava, mas por
um motivo que agora é irrelevante diante do número absoluto.

## Decisão que isso força

O agente usa **Claude via assinatura Pro** como modelo principal
([[00-hermes/config.example.yaml]]). O granite local fica no `fallback_providers` apenas
como último recurso offline — na prática, decorativo. Não vale ocupar disco com o
`granite4:32b-a9b-h` (19,5 GB): com ~9B ativos, seria da ordem de 0,2 tok/s.

O que **ainda** faz sentido rodar localmente neste hardware: embeddings, classificação
curta, tarefas de uma frase. Não conversa, não agente.

## Se um dia houver hardware novo

O `granite4:7b-a1b-h` é uma boa escolha padrão em qualquer máquina — a arquitetura MoE
híbrida (proporção 9:1 Mamba-2/transformer) escala **linearmente** com o comprimento do
contexto em vez de quadraticamente. Em máquina com GPU, refazer esta medição antes de
assumir qualquer coisa.

## Relacionadas

[[00-hermes/setup-windows]]
