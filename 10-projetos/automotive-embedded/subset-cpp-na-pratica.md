---
tags: [automotive, cpp, misra, subset]
status: parcial
---

# O subset de C++ na prática

O que sobra do C++ depois das restrições de um projeto ASIL. A regra que organiza tudo:
**o comportamento em tempo de execução precisa ser previsível e o código precisa ser
analisável estaticamente.** Todo recurso que empurra decisão para o runtime, ou que
torna a análise indecidível, é candidato a restrição.

> ⚠️ **Nota de verificação.** As regras numeradas do MISRA C++:2023 estão em documento
> pago que não consultei. O que segue são os padrões de restrição consolidados na
> indústria, que aparecem consistentemente em material técnico de fornecedores de
> ferramentas e na literatura do AUTOSAR C++14. Trate como **orientação de direção**, não
> como citação de regra: antes de decidir arquitetura, confirme cada item no documento.

## Alocação dinâmica

A restrição mais consequente. O padrão é: **nenhuma alocação depois da fase de
inicialização.** O motivo não é performance — é que um `new` em regime permanente
introduz um modo de falha (esgotamento de heap) sem comportamento definido de
recuperação, e fragmentação torna o pior caso de tempo de alocação não-limitado.

Consequências em cascata:
- `std::vector`, `std::string`, `std::map` saem de uso em regime permanente
- Entram `std::array`, buffers de tamanho fixo, pools pré-alocados
- Bibliotecas de containers determinísticos (ETL — Embedded Template Library, ou
  equivalentes proprietários) são comuns
- Padrões que dependem de alocação implícita — captura de lambda por valor com objeto
  grande, `std::function` — precisam de análise caso a caso

## Exceções

Tipicamente proibidas em código de tempo real duro. O custo não é o `throw`, é o
**desenrolamento de pilha com tempo não determinístico** e a dificuldade de provar que
todo caminho de exceção foi exercitado nos testes. Compila-se com `-fno-exceptions`.

O substituto é o retorno de erro explícito. O AUTOSAR padronizou isso: `ara::core::Result<T, E>`
carrega valor ou erro, sem exceção — conceito equivalente ao `Result` de Rust, o que é uma
observação interessante para [[cpp-e-rust-interop]].

## RTTI e polimorfismo dinâmico

`dynamic_cast` e `typeid` costumam ser proibidos (`-fno-rtti`): custo em runtime e
tabelas que dificultam a análise. Herança e funções virtuais **não** são proibidas em
bloco, mas costumam vir restringidas — hierarquias profundas, herança múltipla de
classes concretas e virtual herdada em diamante são alvos clássicos.

Efeito: o polimorfismo migra para **compile time** — templates, CRTP, despacho estático.

## Templates

Permitidos, mas com atrito. Um template instanciado é código que precisa ser coberto por
teste e analisado; metaprogramação pesada gera código difícil de rastrear até o requisito
e pode explodir o tempo de análise estática. A tendência prática é template como
ferramenta de tipagem e de eliminação de duplicação, não como motor de metaprogramação.

## Outras restrições recorrentes

- **Sem recursão** — o pior caso de profundidade de pilha precisa ser limitável estaticamente
- **Ponteiros restritos** — aritmética de ponteiro limitada, sem cast entre tipos não
  relacionados; sem alocação implica quase sempre ponteiro para memória estática
- **Inicialização obrigatória** — nenhuma variável usada antes de inicializada; a
  ordem de inicialização de objetos estáticos entre unidades de tradução (*static
  initialization order fiasco*) é uma armadilha clássica e costuma ser evitada
  proibindo objetos estáticos não-triviais
- **Sem comportamento indefinido, por construção** — muita regra MISRA existe apenas
  para tornar UB inalcançável
- **Concorrência restrita** — em CP, o escalonamento é do AUTOSAR OS; em AP, threads
  existem mas com padrões restritos e sem alocação dinâmica no caminho crítico

## O que realmente se perde e o que não

Perde-se boa parte da STL em regime permanente e o estilo idiomático de C++ moderno
apoiado em containers dinâmicos. **Não** se perde: `constexpr`, tipos fortes, RAII sobre
recursos estáticos, `std::array`, `std::optional`, `span`, algoritmos que operam sobre
ranges pré-alocados, e todo o ganho de expressividade sobre C.

RAII merece destaque: é o mecanismo que sobrevive intacto e que dá a C++ vantagem clara
sobre C nesse ambiente, porque garante liberação determinística sem custo de runtime.

## A tensão de fundo

Muito do C++ moderno "seguro" — as C++ Core Guidelines — assume alocação livre e
exceções. Por isso o conflito de ~30% com as regras AUTOSAR registrado em
[[misra-cpp-2023]]. Escrever C++ automotivo é escrever um dialeto: as intuições vindas
de C++ de aplicação levam a violações reais.

## Relacionadas

[[misra-cpp-2023]] · [[plataformas-autosar]] · [[cpp-e-rust-interop]] · [[verificacao-e-teste]]
