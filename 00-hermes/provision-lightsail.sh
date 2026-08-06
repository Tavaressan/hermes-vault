#!/usr/bin/env bash
# Provisiona o Hermes Agent numa instância Lightsail (Ubuntu 24.04, ARM ou x86).
# Idempotente: rodar de novo não quebra nada.
#
#   bash provision-lightsail.sh git@github.com:<usuario>/hermes-vault.git
#
# NÃO grava segredos. Os tokens você cola por SSH — ver deploy-lightsail.md, passo 3.

set -euo pipefail

VAULT_REPO="${1:-}"
VAULT_DIR="$HOME/hermes-vault"
HERMES_HOME="$HOME/.hermes"

if [ -z "$VAULT_REPO" ]; then
    echo "uso: bash provision-lightsail.sh <url-git-do-vault>" >&2
    exit 1
fi

log() { printf '\n\033[1;34m==>\033[0m %s\n' "$*"; }

log "Pacotes do sistema"
sudo DEBIAN_FRONTEND=noninteractive apt-get update -qq
sudo DEBIAN_FRONTEND=noninteractive apt-get install -y -qq \
    git curl xz-utils ripgrep ffmpeg unattended-upgrades

# Patches de segurança automáticos — o motivo de sair do macOS sem suporte
log "Atualizações automáticas de segurança"
sudo dpkg-reconfigure -f noninteractive unattended-upgrades

log "Chave SSH para o GitHub"
if [ ! -f "$HOME/.ssh/id_ed25519" ]; then
    ssh-keygen -t ed25519 -N '' -f "$HOME/.ssh/id_ed25519" -C "hermes-lightsail"
    echo
    echo "───────────────────────────────────────────────────────────────"
    echo "  Adicione esta chave como DEPLOY KEY (com acesso de escrita)"
    echo "  em: github.com/<usuario>/hermes-vault → Settings → Deploy keys"
    echo "───────────────────────────────────────────────────────────────"
    cat "$HOME/.ssh/id_ed25519.pub"
    echo "───────────────────────────────────────────────────────────────"
    read -rp "Pressione Enter depois de cadastrar a chave... "
fi
ssh-keyscan -t ed25519 github.com >> "$HOME/.ssh/known_hosts" 2>/dev/null
sort -u -o "$HOME/.ssh/known_hosts" "$HOME/.ssh/known_hosts"

log "Vault"
if [ -d "$VAULT_DIR/.git" ]; then
    git -C "$VAULT_DIR" pull --ff-only
else
    git clone "$VAULT_REPO" "$VAULT_DIR"
fi
git -C "$VAULT_DIR" config user.name  "Hermes (Lightsail)"
git -C "$VAULT_DIR" config user.email "hermes@lightsail.local"

log "Hermes Agent"
if [ ! -x "$HOME/.local/bin/hermes" ]; then
    curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-setup
else
    echo "já instalado, pulando"
fi
export PATH="$HOME/.local/bin:$PATH"

log "Symlinks da memória para o vault"
mkdir -p "$HERMES_HOME" "$VAULT_DIR/00-hermes/memories"
# Preserva qualquer memória que o instalador tenha criado antes de trocar pelo symlink
if [ -d "$HERMES_HOME/memories" ] && [ ! -L "$HERMES_HOME/memories" ]; then
    find "$HERMES_HOME/memories" -maxdepth 1 -type f -exec mv -n {} "$VAULT_DIR/00-hermes/memories/" \;
    rmdir "$HERMES_HOME/memories" 2>/dev/null || mv "$HERMES_HOME/memories" "$HERMES_HOME/memories.bak.$(date +%s)"
fi
[ -L "$HERMES_HOME/memories" ] || ln -s "$VAULT_DIR/00-hermes/memories" "$HERMES_HOME/memories"

if [ -f "$HERMES_HOME/SOUL.md" ] && [ ! -L "$HERMES_HOME/SOUL.md" ]; then
    mv "$HERMES_HOME/SOUL.md" "$HERMES_HOME/SOUL.md.factory.bak"
fi
[ -L "$HERMES_HOME/SOUL.md" ] || ln -s "$VAULT_DIR/00-hermes/SOUL.md" "$HERMES_HOME/SOUL.md"

log "Script de sincronização do vault"
cat > "$HOME/vault-sync.sh" <<'SYNC'
#!/usr/bin/env bash
# Commita e envia o que o agente escreveu. Puxa antes para reduzir conflito.
set -uo pipefail
cd "$HOME/hermes-vault" || exit 0
git pull --rebase --autostash --quiet || exit 0
git add -A
git diff --cached --quiet && exit 0   # nada mudou
git commit -q -m "memória do agente: $(date -u +%Y-%m-%dT%H:%MZ)"
git push --quiet
SYNC
chmod +x "$HOME/vault-sync.sh"

log "Cron a cada 10 minutos"
CRON_LINE="*/10 * * * * $HOME/vault-sync.sh >> $HOME/.hermes/logs/vault-sync.log 2>&1"
mkdir -p "$HERMES_HOME/logs"
( crontab -l 2>/dev/null | grep -v 'vault-sync.sh' ; echo "$CRON_LINE" ) | crontab -

cat <<EOF

╭──────────────────────────────────────────────────────────────╮
│  Provisionamento concluído.                                  │
╰──────────────────────────────────────────────────────────────╯

memories -> $(readlink -f "$HERMES_HOME/memories")
SOUL.md  -> $(readlink -f "$HERMES_HOME/SOUL.md")

Faltam os passos manuais (ver deploy-lightsail.md):

  3. Gravar os segredos em ~/.hermes/.env
       CLAUDE_CODE_OAUTH_TOKEN, TELEGRAM_BOT_TOKEN,
       TELEGRAM_ALLOWED_USERS, HERMES_API_TIMEOUT=1800
     ATENÇÃO: use um bot do Telegram NOVO, ou pare o gateway do iMac —
     dois gateways com o mesmo token brigam pelo polling.

  4. cp ~/hermes-vault/00-hermes/config.example.yaml ~/.hermes/config.yaml
     e remova a entrada 'granite4-agent' do fallback (não há Ollama aqui)

  5. hermes doctor && hermes gateway install && hermes gateway status

EOF
