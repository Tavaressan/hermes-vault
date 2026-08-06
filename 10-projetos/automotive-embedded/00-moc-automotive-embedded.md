---
tags: [automotive, embedded, cpp, rust, safety, moc]
status: parcial
---

# Software embarcado automotivo — mapa do dossiê

Índice do projeto. O foco é a prática de C++ em ECUs automotivas e o estado real da
adoção de Rust nessa indústria.

## Ordem de leitura sugerida

1. [[normas-e-processo]] — o que a ISO 26262 e as normas vizinhas exigem, e por que
   isso determina como o código é escrito antes de qualquer escolha de linguagem
2. [[plataformas-autosar]] — Classic vs Adaptive; onde C++ é de fato permitido
3. [[misra-cpp-2023]] — o guia de codificação vigente e sua relação com o AUTOSAR C++14
4. [[subset-cpp-na-pratica]] — o que sobra do C++ depois das restrições
5. [[toolchain-e-qualificacao]] — compiladores, análise estática, qualificação de ferramenta
6. [[verificacao-e-teste]] — cobertura estrutural, rastreabilidade, SIL/HIL
7. [[rust-na-industria-automotiva]] — Ferrocene, AUTOSAR WG-SAF, lacunas reais
8. [[embassy]] — o modelo async embarcado e seu estado quanto a safety
9. [[cpp-e-rust-interop]] — trade-offs e estratégia de adoção incremental
10. [[roteiro-de-estudos]] — por onde começar, o que é gratuito, o que é pago

## Estado de verificação

| Nota | Estado |
|---|---|
| [[normas-e-processo]] | parcial — normas ISO são pagas; detalhe de tabelas não confirmado em fonte primária |
| [[plataformas-autosar]] | verificado — specs R24-11 públicas em autosar.org |
| [[misra-cpp-2023]] | parcial — existência e escopo verificados; contagem de regras diverge entre fontes secundárias |
| [[subset-cpp-na-pratica]] | parcial — regras específicas exigem o documento MISRA pago |
| [[toolchain-e-qualificacao]] | parcial |
| [[verificacao-e-teste]] | parcial |
| [[rust-na-industria-automotiva]] | verificado |
| [[embassy]] | verificado |
| [[cpp-e-rust-interop]] | rascunho |
| [[roteiro-de-estudos]] | rascunho |

## A tese em uma frase

Nesta indústria a linguagem é a última variável: o que dita a forma do código é a
cadeia de evidências que a ISO 26262 exige — e é exatamente por isso que Rust só
entrou de verdade quando apareceu um toolchain qualificado, não quando a linguagem
ficou boa.

---
*Dossiê iniciado em 2026-08-06.*
