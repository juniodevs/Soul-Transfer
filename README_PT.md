# Soul Transfer

[![Repository](https://img.shields.io/badge/GitHub-juniodevs%2FSoul--Transfer-blue.svg)](https://github.com/juniodevs/Soul-Transfer)
[![Game](https://img.shields.io/badge/Garry's_Mod-Addon-orange.svg)](https://store.steampowered.com/app/4000/Garrys_Mod/)

> Idiomas disponíveis: [English (README.md)](README.md) | **Português**

Addon open source para Garry's Mod que transfere a sua alma para o corpo de um NPC próximo quando você morre.

Em vez de ir para a tela preta de morte ou respawn tradicional, sua alma se descola do cadáver em terceira pessoa. Você mira em um NPC vivo, mergulha em alta velocidade no corpo dele e continua jogando com o modelo, vida atual, armas e roupas dele.

Repositório: [https://github.com/juniodevs/Soul-Transfer](https://github.com/juniodevs/Soul-Transfer)

---

## Como funciona

1. **Morte:** Você morre no mapa com NPCs vivos ao redor.
2. **Visão Astral:** A câmera sai suavemente da cabeça do seu ragdoll e sobe para uma visão em terceira pessoa.
3. **Limbo e Auras:** O mapa escurece em tom de breu total. Os NPCs vivos no alcance ganham auras em vermelho brilhante.
4. **Auto-Mira e Câmera Lenta:** No singleplayer o tempo desacelera para 0.2x da velocidade normal, e a câmera vira suavemente na direção da alma mais próxima.
5. **Mergulho e Posse:** Mire no NPC desejado e aperte o **Botão Esquerdo** ou a tecla **E**. A câmera viaja em disparada até ele.
6. **Despertar:** Você acorda dentro do corpo do NPC. A iluminação volta ao normal e você assume as armas, munição, vida e visual dele.

Se não houver nenhum NPC no alcance ou o tempo limite acabar, você morre normalmente.

---

## Instalação

Clone ou baixe este repositório na pasta de addons do Garry's Mod:

```bash
git clone https://github.com/juniodevs/Soul-Transfer.git "garrysmod/addons/Soul Transfer"
```

Ou copie a pasta `Soul Transfer` diretamente para:
`Steam/steamapps/common/GarrysMod/garrysmod/addons/`

---

## Configurações

O menu de opções fica dentro do jogo em:
**Spawnmenu (Q) > Utilitários > Soul Transfer > Configurações**

### Comandos de Console (ConVars)

| ConVar | Padrão | Descrição |
|---|---|---|
| `soultransfer_enabled` | `1` | Ativa ou desativa o mod |
| `soultransfer_range` | `2500` | Distância máxima para detectar NPCs |
| `soultransfer_time_limit` | `8` | Segundos para escolher uma alma antes de morrer |
| `soultransfer_slomo` | `1` | Câmera lenta durante a morte (apenas singleplayer) |
| `soultransfer_preserve_health` | `1` | Mantém a vida atual do NPC em vez de resetar para 100 HP |
| `soultransfer_allow_hostiles` | `1` | Permite possuir inimigos (Combine, Zumbis, etc.) |
| `soultransfer_transfer_duration`| `0.4` | Tempo de voo até o corpo em segundos |

---

## Compatibilidade

* Funciona com todos os NPCs padrão da Valve (Half-Life 2, Combine, Rebeldes, Zumbis).
* Funciona com NextBots vivos.
* Testado junto de mods de câmera de morte em terceira pessoa e pacotes de realismo.
