# DayZ Key Bindings Movement

## Descrição

Script em AutoHotkey v2 que automatiza comandos de movimentação, corrida e inclinação no DayZ.

## Requisitos

- Windows.
- AutoHotkey v2.
- DayZ em execução e em foco.

## Funcionalidades

- **Corrida automática:** mantém o personagem correndo ao ativar o macro.
- **Controle do Shift:** permite ativar ou pausar o Shift durante a corrida.
- **Inclinação com Q e E:** controla a inclinação manualmente ou pelo movimento horizontal do mouse.
- **Modo de combate:** ativa a inclinação ao pressionar duas vezes A ou D em até 400 ms, mantendo o botão direito do mouse pressionado.
- **Desativação automática:** o modo de combate é encerrado após 5 segundos de inatividade do temporizador.
- **Parada rápida:** interrompe a corrida e libera as teclas controladas pelo macro.

## Controles

| Tecla | Função |
| --- | --- |
| `Numpad +` ou `+` | Ativa a corrida automática |
| `Numpad -`, `-` ou `Tab` | Desativa o macro e para a corrida |
| `S` | Parada rápida |
| `W` | Movimento normal para frente |
| `Q` | Inclinação para a esquerda |
| `E` | Inclinação para a direita |
| `A` duas vezes + botão direito | Ativa o modo de combate para a esquerda |
| `D` duas vezes + botão direito | Ativa o modo de combate para a direita |

## Como executar

1. Instale o AutoHotkey v2.
2. Salve o script com o nome `DayZ key bindings movement..ahk`.
3. Execute o arquivo `.ahk`.
4. Abra o DayZ e mantenha a janela do jogo em foco.
5. Utilize as teclas descritas na tabela.

## Observações

- O macro inicia desativado.
- Os atalhos automatizados funcionam somente quando o DayZ está em foco.
- O monitoramento do mouse controla a inclinação conforme a posição horizontal do cursor.
- O comportamento pode variar conforme as configurações de teclas e a versão do jogo.

## Arquivo principal

`DayZ key bindings movement..ahk`

Observação: o script usa `#HotIf WinActive("ahk_exe DayZ_x64.exe")` para restringir os atalhos ao jogo, mas o temporizador do mouse pode continuar executando fora dele.