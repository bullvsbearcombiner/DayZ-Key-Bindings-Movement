#Requires AutoHotkey v2.0
#SingleInstance Force

SetCapsLockState("AlwaysOff") ; <--- IMPEDE QUE O CAPSLOCK SEJA ATIVADO POR ACIDENTE

global teclaAtiva := ""
global correndo := false

; --- VARIÁVEIS DE CONTROLE DE ESTADO ---
global shiftPausado := false
global macroDesativado := true  ; Inicia desativado para o Shift não ligar sozinho

; --- VARIÁVEIS DO MODO DE COMBATE ---
global modoCombate := false
global direcaoCombate := ""
global modoManualFixo := false  ; Indica se o modo manual está imposto via Q/E
global direcaoAntesDoTab := ""  ; Armazena a inclinação prévia para restauração via Tab

; --- CONFIGURAÇÃO DE COMPENSAÇÃO DE MIRA (X = Lado | Y = Altura) ---
global intensidadeCorrecaoEsquerda := 23 ; Movimento lateral para o Q
global intensidadeCorrecaoDireita  := 23 ; Movimento lateral para o E

; Ajustes Individuais de Altura (Y):
; Valores positivos (+) movem a mira para BAIXO. Valores negativos (-) movem a mira para CIMA.
global intensidadeCorrecaoAlturaEsquerda := +7  ; Ajuste de altura para a inclinação Q
global intensidadeCorrecaoAlturaDireita  := -7  ; Ajuste de altura para a inclinação E

; --- CONFIGURAÇÃO DE SUAVIZAÇÃO DO MOVIMENTO DA MIRA ---
global passosSuavizacao := 5   ; Quantidade de micro-passos em que o movimento será dividido (quanto maior, mais suave/lento)
global atrasoPassos    := 5   ; Tempo em milissegundos (ms) de pausa entre cada micro-passo

; ==============================================================================
; FUNÇÃO AUXILIAR DE MOVIMENTO SUAVE DA MIRA
; ==============================================================================
MoverMouseSuave(totalX, totalY) {
    global passosSuavizacao, atrasoPassos
    
    if (passosSuavizacao <= 0) {
        DllCall("mouse_event", "UInt", 0x0001, "Int", totalX, "Int", totalY, "UInt", 0, "UPtr", 0)
        return
    }
    
    passos := passosSuavizacao
    deltaX := totalX / passos
    deltaY := totalY / passos
    
    acumuladoX := 0.0
    acumuladoY := 0.0
    
    Loop(passos) {
        acumuladoX += deltaX
        acumuladoY += deltaY
        
        passoX := Round(acumuladoX)
        passoY := Round(acumuladoY)
        
        if (passoX != 0 || passoY != 0) {
            DllCall("mouse_event", "UInt", 0x0001, "Int", passoX, "Int", passoY, "UInt", 0, "UPtr", 0)
            acumuladoX -= passoX
            acumuladoY -= passoY
        }
        
        Sleep(atrasoPassos)
    }
}

; ==============================================================================
; GARANTIA GLOBAL: Solta TODAS as teclas ao sair / recarregar / encerrar
; ==============================================================================
OnExit(SoltarTodasAsTeclas)

SoltarTodasAsTeclas(ExitReason, ExitCode) {
    global teclaAtiva
    teclaAtiva := ""
    SendEvent("{LShift up}{RShift up}{w up}{vk51 up}{vk45 up}{vk41 up}{vk44 up}")
    Sleep(60)
}

; ==============================================================================
; Restrição Global: Todo o script funciona APENAS com o DayZ aberto e em foco
; ==============================================================================
#HotIf WinActive("ahk_exe DayZ_x64.exe")

; ==============================================================================
; PAUSA / SUSPENSÃO
; ==============================================================================
~Pause:: {
    SoltarTodasAsTeclas("Pause", 0)
    ResetarEstadoCompleto()
    Pause(-1)
}

^!s:: {
    SoltarTodasAsTeclas("Suspend", 0)
    ResetarEstadoCompleto()
    Suspend(-1)
}

; ==============================================================================
; DESTRAVAR TUDO (ESC E WINDOWS RESETA TUDO)
; ==============================================================================
~*Esc::
~*LWin::
~*RWin:: {
    ResetarEstadoCompleto()
}

; ==============================================================================
; TAB: Salva/solta Q e E ao abrir o inventário e restaura ao fechar
; ==============================================================================
~Tab:: {
    global direcaoAntesDoTab, direcaoCombate, modoCombate
    
    SendInput("{LShift up}")
    
    ; Salva a inclinação atual antes de entrar na interface do inventário
    direcaoAntesDoTab := direcaoCombate
    
    ; Solta as teclas no motor do jogo para não travar o movimento do personagem
    SendInput("{Blind}{vk51 up}{vk45 up}")
}

~Tab up:: {
    global direcaoAntesDoTab, modoCombate, modoManualFixo
    
    Sleep(50) ; Pausa de sincronização com o fechamento da UI
    
    ; Restaura a inclinação caso houvesse alguma ativa prévia (sem re-aplicar o pulso do mouse)
    if (direcaoAntesDoTab == "q") {
        SendInput("{Blind}{vk51 down}")
    } else if (direcaoAntesDoTab == "e") {
        SendInput("{Blind}{vk45 down}")
    }
    
    direcaoAntesDoTab := ""
}

; ==============================================================================
; FUNÇÕES DO MODO DE COMBATE COM COMPENSAÇÃO DE MIRA E SUAVIZAÇÃO
; ==============================================================================

AtivarModoCombate(lado := "", manual := false) {
    global modoCombate, direcaoCombate, teclaAtiva, modoManualFixo
    global intensidadeCorrecaoEsquerda, intensidadeCorrecaoDireita, intensidadeCorrecaoAlturaEsquerda, intensidadeCorrecaoAlturaDireita

    ; Verifica se houve mudança real de direção antes de disparar a correção
    mudouDirecao := (direcaoCombate != lado)

    if (teclaAtiva != "") {
        vkTecla := (teclaAtiva == "q") ? "vk51" : "vk45"
        SendInput("{Blind}{" . vkTecla . " up}")
        teclaAtiva := ""
    }

    modoCombate := true
    if (manual)
        modoManualFixo := true

    if (lado == "q" || lado == "e") {
        vkAlvo   := (lado == "q") ? "vk51" : "vk45"
        vkOposto := (lado == "q") ? "vk45" : "vk51"

        SendInput("{Blind}{" . vkOposto . " up}")
        Sleep(10)

        SendInput("{Blind}{" . vkAlvo . " down}")

        ; COMPENSAÇÃO AUTOMÁTICA COM SUAVIZAÇÃO: Só executa no primeiro acionamento da direção
        if (mudouDirecao) {
            if (lado == "q") {
                MoverMouseSuave(intensidadeCorrecaoEsquerda, intensidadeCorrecaoAlturaEsquerda)
            } else if (lado == "e") {
                MoverMouseSuave(-intensidadeCorrecaoDireita, intensidadeCorrecaoAlturaDireita)
            }
        }

        direcaoCombate := lado

    } else if (lado == "centro") {
        SendInput("{Blind}{vk51 up}{vk45 up}")
        direcaoCombate := "centro"
    }

    SetTimer(DesativarModoCombatePorInatividade, -300000)
}

DesativarModoCombatePorInatividade() {
    global modoCombate, direcaoCombate, modoManualFixo
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := ""
    SendInput("{Blind}{vk51 up}{vk45 up}")
}

; ==============================================================================
; HOTKEYS DE COMBATE PADRÃO (A ativa Q | D ativa E)
; ==============================================================================

~*a:: {
    if (!modoManualFixo) {
        AtivarModoCombate("q", false)
    }
}

~*d:: {
    if (!modoManualFixo) {
        AtivarModoCombate("e", false)
    }
}

; ==============================================================================
; TECLA SHIFT: Cancela o modo manual fixo de Q/E e restaura o macro padrão
; ==============================================================================

~*LShift::
~*RShift:: {
    global modoManualFixo, modoCombate, direcaoCombate, teclaAtiva
    
    if (modoManualFixo) {
        DesativarModoCombatePorInatividade()
        teclaAtiva := ""
    }
}

; ==============================================================================
; Loop de Força Bruta para a Corrida com Shift
; ==============================================================================
ManterCorridaForçada() {
    global correndo, shiftPausado, macroDesativado
    if (macroDesativado || !WinActive("ahk_exe DayZ_x64.exe")) {
        SetTimer(ManterCorridaForçada, 0)
        return
    }
    if (correndo) {
        SendInput("{w down}")
        if (!shiftPausado) {
            SendInput("{LShift down}")
        } else {
            SendInput("{LShift up}")
        }
    }
}

; ==============================================================================
; FUNÇÕES DE RESET E PARADA
; ==============================================================================
ResetarEstadoCompleto() {
    global correndo, shiftPausado, macroDesativado, modoCombate, direcaoCombate, teclaAtiva, modoManualFixo, direcaoAntesDoTab
    correndo := false
    shiftPausado := false
    macroDesativado := true
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := ""
    teclaAtiva := ""
    direcaoAntesDoTab := ""
    
    SetTimer(ManterCorridaForçada, 0)
    SetTimer(DesativarModoCombatePorInatividade, 0)
    
    SendInput("{Blind}{LShift up}{RShift up}{w up}{vk51 up}{vk45 up}{vk41 up}{vk44 up}")
}

PararCorrida() {
    global correndo, shiftPausado, macroDesativado
    correndo := false
    shiftPausado := false
    macroDesativado := true
    SetTimer(ManterCorridaForçada, 0)
    SendInput("{LShift up}{w up}")
}

; ==============================================================================
; INTERRUPTORES
; ==============================================================================

~NumpadSub::
~-::
~vkBD:: {
    ResetarEstadoCompleto()
}

~NumpadAdd::
~+:: {
    global correndo, shiftPausado, macroDesativado
    macroDesativado := false
    correndo := true
    shiftPausado := false
    SetTimer(ManterCorridaForçada, 50)
}

~*s:: {
    PararCorrida()
}

~w:: {
    return
}

; ==============================================================================
; CONTROLE MANUAL E ALTERNÂNCIA (Q e E acionam o modo fixo manual)
; ==============================================================================
$*q:: {
    global teclaAtiva, modoCombate, direcaoCombate, modoManualFixo

    if (modoManualFixo) {
        if (direcaoCombate == "q") {
            SendInput("{Blind}{vk51 up}")
            direcaoCombate := "centro"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        } else {
            AtivarModoCombate("q", true)
        }
        return
    }

    AtivarModoCombate("q", true)
}

$*e:: {
    global teclaAtiva, modoCombate, direcaoCombate, modoManualFixo

    if (modoManualFixo) {
        if (direcaoCombate == "e") {
            SendInput("{Blind}{vk45 up}")
            direcaoCombate := "centro"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        } else {
            AtivarModoCombate("e", true)
        }
        return
    }

    AtivarModoCombate("e", true)
}

#HotIf