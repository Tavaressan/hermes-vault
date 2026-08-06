---
tags: [infra, aws, lightsail, deploy, hermes]
status: pronto-para-executar
---

# Migrar o agente para o Amazon Lightsail

Runbook para tirar o gateway do iMac e colocá-lo numa instância sempre ligada, mantendo
a memória sincronizada com este vault.

**Motivo principal:** o iMac roda macOS 12.7.6 — a última atualização do Monterey, de
29/07/2024. O suporte da Apple terminou por volta de novembro de 2024, então a máquina
está há ~21 meses sem patch de segurança. Deixá-la 24/7 exposta à internet com tokens de
API dentro é o risco que esta migração resolve.
> — [UMIT](https://www.it.miami.edu/about-umit/it-news/umit-announcements/macos-12-monterey-eol/index.html),
> [UCSF IT](https://it.ucsf.edu/news-events/news/end-support-macos-monterey-12x), acesso em 2026-08-06.

## Desenho

```
              ┌─────────────────────────────────┐
 Telegram ────┤  Lightsail (Ubuntu 24.04 ARM)   │
 WhatsApp ────┤   gateway Hermes 24/7           │
              │   ~/.hermes/memories ──┐        │
              │   ~/hermes-vault ◄─────┘        │
              └──────────┬──────────────────────┘
                         │ push/pull
                  GitHub (repo privado)
                         │
        ┌────────────────┴────────────────┐
   iMac (Obsidian)              Windows (Obsidian)
```

**A nuvem é o único escritor da memória do agente.** iMac e Windows leem e editam notas
manuais; o agente escreve apenas na instância. Isso evita conflito de merge em
`MEMORY.md`, que dois agentes ativos produziriam.

## Pré-requisito bloqueante

**O vault ainda não tem remoto.** Toda a sincronização depende disso. Antes de qualquer
coisa na AWS:

1. Criar repositório **privado** no GitHub (a memória contém informação pessoal)
2. No iMac:
   ```bash
   cd ~/Obsidian/hermes-vault
   git remote add origin git@github.com:<usuario>/hermes-vault.git
   git push -u origin main
   ```

⚠️ **Antes disso, revogue o PAT exposto.** O `~/.claude.json` guarda um token do GitHub em
texto plano no MCP do projeto Alfabra-Vector (`ghp_atE...`). Com uma máquina em nuvem
entrando na conta, o risco deixa de ser teórico:
https://github.com/settings/tokens

## Passo 1 — Criar a instância

Console do Lightsail → Create instance:

| Campo | Valor |
|---|---|
| Região | `us-east-1` (mais barata) ou `sa-east-1` (menor latência do Brasil) |
| Plataforma | Linux/Unix |
| Blueprint | **Ubuntu 24.04 LTS** |
| Arquitetura | **ARM** — mais barata, e o instalador do Hermes suporta `aarch64` (verificado) |
| Plano | **2 GB de RAM** — 1 GB fica apertado com Python + a ponte Node do WhatsApp |
| Rede | **IPv6-only**, se disponível — mais barato e sem superfície IPv4 |

Sobre IPv6-only: o Telegram em polling e o WhatsApp Baileys são *outbound-only* — o
gateway disca para fora, nada escuta. Só a Cloud API oficial da Meta exigiria IP público.
Se o acesso administrativo ficar difícil sem IPv4, use o **SSH pelo navegador** do próprio
console do Lightsail.

> ⚠️ Confirme o preço do plano no console. Os valores que vi (US$ 3,50 IPv6-only,
> US$ 5 com IPv4) vêm de fontes secundárias, não do console.

## Passo 2 — Provisionar

Copie `provision-lightsail.sh` (nesta mesma pasta do vault) para a instância e execute.
Ele instala dependências, o Hermes, clona o vault e cria os symlinks. É idempotente:
rodar duas vezes não quebra nada.

```bash
scp provision-lightsail.sh ubuntu@<host>:~
ssh ubuntu@<host> 'bash ~/provision-lightsail.sh <URL-do-repo-do-vault>'
```

## Passo 3 — Segredos (você faz, por SSH)

Nada aqui passa por arquivo intermediário nem por transcript de agente. Conectado na
instância:

```bash
# Token do Claude Pro — gere no seu desktop com: claude setup-token
printf 'CLAUDE_CODE_OAUTH_TOKEN=%s\n' 'cole-aqui'  >> ~/.hermes/.env

# Telegram — recomendado criar um bot NOVO para a nuvem, via @BotFather,
# para não competir com o do iMac pelo mesmo polling
printf 'TELEGRAM_BOT_TOKEN=%s\n'      'cole-aqui'  >> ~/.hermes/.env
printf 'TELEGRAM_ALLOWED_USERS=%s\n'  'seu-id'     >> ~/.hermes/.env

printf 'HERMES_API_TIMEOUT=1800\n'                 >> ~/.hermes/.env
chmod 600 ~/.hermes/.env
```

⚠️ **Dois gateways com o mesmo `TELEGRAM_BOT_TOKEN` brigam pelo polling** e as mensagens
alternam entre eles de forma imprevisível. Use um bot novo na nuvem, ou pare o gateway do
iMac (`hermes gateway stop`) antes de subir o da nuvem.

## Passo 4 — Config do modelo

```bash
mkdir -p ~/.hermes
cp ~/hermes-vault/00-hermes/config.example.yaml ~/.hermes/config.yaml
```

Ajuste o bloco de fallback: **remova a entrada do `granite4-agent`** — não há Ollama na
instância, e o modelo é inútil mesmo (ver [[ollama-tuning-imac-2015]]).

## Passo 5 — Subir e verificar

```bash
hermes doctor
hermes gateway install     # supervisão por systemd, sobe no boot
hermes gateway status
```

Verificação de ponta a ponta:
1. Mande mensagem ao bot pelo Telegram — do celular e do Windows
2. Peça para ele registrar um fato sobre você
3. Na instância: `cd ~/hermes-vault && git log --oneline` deve mostrar o commit da memória
4. No iMac: `git pull` e o fato aparece em `00-hermes/memories/MEMORY.md` dentro do Obsidian

## Passo 6 — Sincronização contínua

O cron instalado pelo script faz commit e push do vault a cada 10 minutos. Nos clientes
(iMac e Windows), o plugin **Obsidian Git** com *auto pull* ao iniciar fecha o ciclo.

Se ocorrer conflito em `MEMORY.md`: o arquivo usa `§` como separador de entradas, então a
resolução quase sempre é manter os dois lados e apagar os marcadores de conflito.

## Custo esperado

| item | USD/mês |
|---|---|
| Lightsail 2 GB ARM | ~5–7 |
| Transferência | incluída no plano |
| **Total** | **~5–7** |

Para comparação, medido na API pública de preços da AWS (us-east-1, on-demand): EC2
`t4g.small` custa US$ 0,0168/h → **US$ 12,26/mês** só de instância, mais disco e IPv4.
Lightsail é mais barato e mais simples para esta carga.

## Manutenção

- `sudo unattended-upgrades` fica ativo pelo script — patches de segurança automáticos,
  exatamente o que falta no iMac
- Snapshot do Lightsail antes de cada atualização grande do Hermes
- O vault no GitHub já é o backup da memória

## Relacionadas

[[setup-windows]] · [[ollama-tuning-imac-2015]] · [[config.example.yaml]]
