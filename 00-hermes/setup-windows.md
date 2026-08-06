# Replicar o setup no Windows

> ⚠️ **Leia isto antes de seguir.** Esta página descreve uma **segunda instalação
> independente** do Hermes no Windows — um agente separado, com sua própria sessão.
> A memória é compartilhada via Git, mas os dois agentes escrevem no mesmo arquivo e
> podem gerar conflito.
>
> **Se o que você quer é acessar o mesmo agente a partir do Windows, não faça isto.**
> Use o gateway: um único agente rodando no servidor ([[deploy-lightsail]]), acessado do
> Windows por Telegram Desktop, WhatsApp Desktop ou navegador. Nada a instalar aqui —
> o Obsidian sozinho, para ler o vault, basta.
>
> Esta página serve só para o caso de você querer um agente **local e offline** no
> Windows, independente do servidor.

Ordem importa: clone o vault antes de mexer no Hermes, porque os symlinks apontam para dentro dele.

## 1. Clonar o vault

```powershell
git clone git@github.com:<usuario>/hermes-vault.git $env:USERPROFILE\Obsidian\hermes-vault
```

Abrir o Obsidian → "Open folder as vault" → apontar para essa pasta. Instalar o plugin
**Obsidian Git** em Settings → Community plugins, com auto pull ao iniciar e auto commit-and-sync
por intervalo.

## 2. Ollama

Baixar o instalador em [ollama.com/download](https://ollama.com/download). No Windows o Ollama
usa GPU quando há uma compatível (NVIDIA/AMD via Vulkan) — diferente do iMac, onde a inferência
é 100% CPU. Se a máquina Windows tiver GPU dedicada, o `granite4:32b-a9b-h` (19,5 GB) passa a ser
uma opção realista; caso contrário, mantenha o `7b-a1b-h`.

```powershell
ollama pull granite4:7b-a1b-h
```

Criar o modelo com contexto expandido (o default do Ollama é pequeno demais para uso agêntico).
Grave um arquivo `Modelfile`:

```
FROM granite4:7b-a1b-h
PARAMETER num_ctx 32768
PARAMETER num_thread <número de núcleos físicos desta máquina>
```

```powershell
ollama create granite4-agent -f Modelfile
```

Variáveis do servidor (Painel de Controle → Variáveis de Ambiente, ou `setx`):

```
OLLAMA_FLASH_ATTENTION=1
OLLAMA_KV_CACHE_TYPE=q8_0
OLLAMA_KEEP_ALIVE=30m
```

## 3. Hermes Agent

```powershell
iex (irm https://hermes-agent.nousresearch.com/install.ps1)
```

No Windows o `HERMES_HOME` fica em `%LOCALAPPDATA%\hermes`, não em `~/.hermes`.

Copiar `00-hermes/config.example.yaml` do vault para `%LOCALAPPDATA%\hermes\config.yaml` e
ajustar `num_thread`/modelo conforme a máquina.

Criar `%LOCALAPPDATA%\hermes\.env` com:

```
HERMES_API_TIMEOUT=1800
OPENROUTER_API_KEY=<sua chave>
```

## 4. Symlinks para a memória

Os links precisam de **Developer Mode ligado** (Settings → Privacy & security → For developers)
ou de um terminal como Administrador.

```powershell
$V = "$env:USERPROFILE\Obsidian\hermes-vault"
$H = "$env:LOCALAPPDATA\hermes"

# Rode o Hermes uma vez antes, para ele criar os arquivos; depois remova os originais:
Remove-Item -Recurse -Force "$H\memories"
Remove-Item -Force "$H\SOUL.md"

cmd /c mklink /D "$H\memories" "$V\00-hermes\memories"
cmd /c mklink    "$H\SOUL.md"  "$V\00-hermes\SOUL.md"
```

Note que `mklink /D` (diretório) e `mklink` sem flag (arquivo) são comandos diferentes — usar o
errado cria um link quebrado.

## 5. Verificar

```powershell
hermes doctor
cd $env:USERPROFILE\Obsidian\hermes-vault
hermes
```

Peça ao agente para registrar um fato, saia, e confira se ele apareceu em
`00-hermes\memories\MEMORY.md`. Depois um `git status` no vault deve mostrar o arquivo modificado.

## Conflitos de merge na memória

Editar a memória nas duas máquinas sem sincronizar gera conflito em `MEMORY.md`. O arquivo usa
`§` como separador de entradas, então a resolução é quase sempre manter os dois lados e apagar
os marcadores de conflito. Para evitar: deixe o auto pull ao iniciar ligado nas duas máquinas.
