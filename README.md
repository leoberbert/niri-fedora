# niri-fedora

Minha configuração do [niri](https://github.com/YaLTeR/niri) no Fedora, com instalador.
Base: niri-setup adaptado (waybar, dunst, fuzzel, rofi, wlogout, swaylock-effects, pywal).

## Estrutura

| Caminho | Destino | Conteúdo |
|---|---|---|
| `config/niri` | `~/.config/niri` | arquivos `.kdl` (binds, layout, outputs, regras...) |
| `config/rofi` | `~/.config/rofi` | tema do rofi |
| `config/wal/templates` | `~/.config/wal/templates` | templates do pywal (rofi, wlogout) |
| `share/` | `~/.local/share/niri-fedora` | scripts, waybar, dunst, fuzzel, wlogout, wallpapers |

Os arquivos usam placeholders, trocados na instalação: `@HOME@` → `$HOME`, `@NIRICONF@` → `~/.local/share/niri-fedora`.

## Uso

```sh
./install.sh                 # pacotes (dnf/COPR/awww/pywal) + configs
./install.sh --skip-packages # só copia as configs
./install.sh --skip-wal      # não gera as cores do pywal
```

Configs existentes são movidas para `<nome>.bak.<data>`. Depois, faça login escolhendo a sessão niri.

## Guardar mudanças

Edite a config ativa normalmente e rode `./sync.sh`: ele copia de volta para o repositório, restaurando os placeholders. Depois é só `git diff` e commit.

## Atalhos

`Mod` é a tecla Super (Windows). Definidos em `config/niri/binds.kdl` e `config/niri/recent-windows.kdl`.

### Aplicativos

| Atalho | Ação |
|---|---|
| `Mod+Return` | Terminal (zashterminal) |
| `Mod+D` | Lançador rofi (alterna) |
| `Mod+B` | Firefox |
| `Mod+E` | Nautilus |
| `Mod+L` | Menu de energia (wlogout: bloquear, sair, suspender, hibernar, desligar, reiniciar) |
| `Mod+C` | Histórico da área de transferência (cliphist + fuzzel) |
| `Mod+I` | Escolher tempo de inatividade (swayidle) |
| `Mod+P` | Escolher perfil de energia |
| `Mod+U` | Atualizações do sistema (terminal) |
| `Mod+W` | Mostrar/ocultar a waybar |
| `Mod+Ctrl+W` | Seletor de wallpaper (terminal) |

### Brilho, áudio e mídia

Funcionam também com a tela bloqueada.

| Atalho | Ação |
|---|---|
| `XF86MonBrightnessUp` / `Down` | Brilho +5% / -5% |
| `XF86AudioRaiseVolume` / `LowerVolume` | Volume +5% / -5% |
| `XF86AudioMute` | Alterna mudo |
| `XF86AudioPlay` / `Pause` | Play-pause / pausar |
| `XF86AudioNext` / `Prev` | Próxima / anterior |

### Janelas e colunas

| Atalho | Ação |
|---|---|
| `Mod+Q` | Fechar janela |
| `Mod+T` | Alterna janela flutuante |
| `Mod+M` | Maximizar coluna |
| `Mod+F` | Tela cheia |
| `Mod+←` / `→` | Foco na coluna à esquerda / direita |
| `Mod+↑` / `↓` | Foco na janela acima / abaixo |
| `Mod+Ctrl+←` / `→` | Mover coluna para esquerda / direita |
| `Mod+Ctrl+↑` / `↓` | Mover janela para cima / baixo |
| `Mod+Home` / `End` | Foco na primeira / última coluna |
| `Mod+Ctrl+Home` / `End` | Mover coluna para a primeira / última posição |
| `Mod+Shift+←` / `→` | Largura da coluna -10% / +10% |
| `Mod+Shift+↑` / `↓` | Altura da janela -10% / +10% |
| `Mod+[` / `Mod+]` | Consumir ou expulsar janela para a esquerda / direita |
| `Mod+,` | Puxar janela da direita para dentro da coluna |
| `Mod+.` | Expulsar janela da coluna |
| `Alt+Tab` | Alternar entre janelas recentes |

### Workspaces

| Atalho | Ação |
|---|---|
| `Mod+Page_Down` / `Page_Up` | Workspace abaixo / acima |
| `Mod+Ctrl+Page_Down` / `Page_Up` | Mover coluna para workspace abaixo / acima |
| `Mod+Ctrl+1` … `9`, `0` | Mover coluna para o workspace 1–9, 10 |
| `Mod+A` | Visão geral (overview) |

### Capturas de tela

| Atalho | Ação |
|---|---|
| `Print` | Selecionar região |
| `Ctrl+Print` | Janela |
| `Shift+Print` | Tela inteira |

## Manual

- `zashterminal` (terminal do `Mod+Return`) não vem dos repositórios; o `install.sh` oferece instalá-lo (via script do repositório `leoberbert/zashterminal`) se não estiver no PATH.
- `outputs.kdl` tem os monitores do meu notebook (`eDP-1`, `HDMI-A-1`); ajuste para outro hardware.
- `Mod+L` abre o wlogout; `Ctrl+Mod+W` troca o wallpaper (grava em `~/.config/niri/wallpapers.kdl`).
