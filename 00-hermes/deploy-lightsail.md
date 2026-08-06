---
tags: [infra, aws, lightsail, deploy, hermes]
status: provisionado
---

# O agente no Amazon Lightsail

Registro do que foi provisionado e do que falta. A instância **já existe**.

## Estado atual

| item | valor |
|---|---|
| Instância | `hermes-agent`, região `sa-east-1a` |
| Bundle | `micro_3_1` — **US$ 7,00/mês**, 1 GB RAM, 2 vCPU, 40 GB SSD, 2 TB transferência |
| SO | Ubuntu 24.04.4 LTS, **x86_64** |
| IP | 54.233.15.35 (+ IPv6) |
| Firewall | **só TCP/22, só a partir do IP do iMac**. Porta 80 removida, IPv6 de entrada removido |
| Swap | 2 GB — 911 MB de RAM não sobrevivem ao `pip install` sem ele |
| Chave SSH | `~/.ssh/lightsail-hermes.pem` no iMac |
| Vault | clonado em `~/hermes-vault`, deploy key com escrita registrada |
| Sync | cron a cada 10 min, testado com push e pull reais |
| Hermes | v0.20.0 instalado, symlinks de `memories/` e `SOUL.md` ativos |

**Falta apenas**: gravar os segredos (passo 3), copiar a config (passo 4) e subir o
gateway (passo 5).

⚠️ **O firewall está preso ao IP do iMac** (187.10.236.26/32 no momento do provisionamento).
Se sua internet trocar de IP, o SSH para de funcionar. Para reabrir:
```bash
aws lightsail put-instance-public-ports --region sa-east-1 --instance-name hermes-agent \
  --port-infos "fromPort=22,toPort=22,protocol=TCP,cidrs=$(curl -s https://checkip.amazonaws.com)/32"
```
Ou use o SSH pelo navegador no console do Lightsail, que não depende disso.

---

## Por que este desenho

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

## Pré-requisitos — já cumpridos

- Repositório privado: **github.com/Tavaressan/hermes-vault** (criado, `main`)
- PAT exposto no `~/.claude.json`: removido pelo usuário (estavam expirados)

## Passo 1 e 2 — instância e provisionamento (feitos)

Reproduzível por CLI, caso precise recriar:

```bash
aws lightsail create-instances --region sa-east-1 \
  --instance-names hermes-agent --availability-zone sa-east-1a \
  --blueprint-id ubuntu_24_04 --bundle-id micro_3_1

# Fecha tudo, deixa só SSH do seu IP
aws lightsail put-instance-public-ports --region sa-east-1 --instance-name hermes-agent \
  --port-infos "fromPort=22,toPort=22,protocol=TCP,cidrs=$(curl -s https://checkip.amazonaws.com)/32"

# Chave SSH (nunca imprima o conteúdo)
aws lightsail download-default-key-pair --region sa-east-1 \
  --query privateKeyBase64 --output text > ~/.ssh/lightsail-hermes.pem
chmod 600 ~/.ssh/lightsail-hermes.pem
```

Depois: gerar `~/.ssh/id_ed25519` na instância, registrar a pública como **deploy key com
escrita** no repositório, e rodar `provision-lightsail.sh <url-ssh-do-repo>`.

### Erros que este provisionamento revelou

Ficam registrados porque custaram tempo e não são óbvios:

1. **IPv6-only não funciona para este caso.** `github.com` e
   `hermes-agent.nousresearch.com` não publicam registro AAAA, e o Lightsail **não tem
   NAT64/DNS64 nativo** — obter isso exigiria peering com VPC do EC2 rodando NAT gateway,
   que custa mais que a instância. Numa instância IPv6-only o instalador do Hermes nem
   baixa e o `git push` falha.
   > — [AWS re:Post](https://repost.aws/questions/QUFaBCYpKeSaqxCdy22wTJfA/ipv6-only-instance-in-lightsail-with-nat64), acesso em 2026-08-06.
2. **1 GB de RAM precisa de swap.** Sem os 2 GB de swap, o `pip install` do Hermes corre
   risco de OOM. O script já cria.
3. **Git não versiona diretório vazio.** `00-hermes/memories/` some no pull quando fica
   vazio, e o symlink `~/.hermes/memories` quebra em toda máquina. Resolvido com um
   `.gitkeep` — **não remova esse arquivo**.
4. **Bug de `pipefail` no script**: `crontab -l | grep -v` sai com 1 quando não há crontab,
   e com `set -euo pipefail` isso abortava o provisionamento em silêncio no último passo.
   Corrigido com `|| true`.

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

## Custo

Preços lidos da API do Lightsail em 2026-08-06. `sa-east-1` custa o mesmo que
`us-east-1`; muda só o sufixo do bundle (`_3_1` vs `_3_0`).

| bundle | RAM | SSD | transf. | **USD/mês** |
|---|---|---|---|---|
| `nano_3_1` | 0,5 GB | 20 GB | 1 TB | 5,00 |
| **`micro_3_1`** ← em uso | 1 GB | 40 GB | 2 TB | **7,00** |
| `small_3_1` | 2 GB | 60 GB | 3 TB | 12,00 |
| `medium_3_1` | 4 GB | 80 GB | 4 TB | 24,00 |

Os planos `*_ipv6_*` custam US$ 2 a menos, mas **não servem** — ver o erro nº 1 acima.

Para comparação, da API de preços do EC2 (us-east-1, on-demand): `t4g.small` a
US$ 0,0168/h → US$ 12,26/mês só de instância, mais disco e IPv4. Lightsail sai mais
barato e com menos peça móvel nesta carga.

**Se a RAM apertar** (Telegram + WhatsApp + Playwright juntos), o caminho é snapshot →
criar `small_3_1` a partir dele → trocar o IP. Não há resize in-place.

## Manutenção

- `sudo unattended-upgrades` fica ativo pelo script — patches de segurança automáticos,
  exatamente o que falta no iMac
- Snapshot do Lightsail antes de cada atualização grande do Hermes
- O vault no GitHub já é o backup da memória

## Relacionadas

[[setup-windows]] · [[ollama-tuning-imac-2015]] · [[config.example.yaml]]
