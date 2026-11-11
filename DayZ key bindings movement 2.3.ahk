#Requires AutoHotkey v2.0
#SingleInstance Force

global teclaAtiva := ""
global correndo := false

; --- VARIÁVEIS DE CONTROLE DE ESTADO ---
global shiftPausado := false
global macroDesativado := true  ; Inicia desativado para o Shift não ligar sozinho

; --- VARIÁVEIS DO MODO DE COMBATE ---
global modoCombate := false
global direcaoCombate := ""
global modoManualFixo := false  ; Indica se o modo manual está imposto via Q/E

; --- FLAGS ANTI-AUTO-REPEAT PARA A/D ---
global aDown := false
global dDown := false

; --- CONFIGURAÇÃO DE COMPENSAÇÃO DE MIRA (X = Lado | Y = Altura) ---
global intensidadeCorrecaoEsquerda := 23 ; Movimento lateral para o Q
global intensidadeCorrecaoDireita  := 23 ; Movimento lateral para o E

; Ajustes Individuais de Altura (Y):
; Valores positivos (+) movem a mira para BAIXO. Valores negativos (-) movem a mira para CIMA.
global intensidadeCorrecaoAlturaEsquerda := +7  ; Ajuste de altura para a inclinação Q
global intensidadeCorrecaoAlturaDireita  := -7  ; Ajuste de altura para a inclinação E

; --- CONFIGURAÇÃO DE SUAVIZAÇÃO DO MOVIMENTO DA MIRA ---
global passosSuavizacao := 5   ; Quantidade de micro-passos em que o movimento será dividido
global atrasoPassos     := 5   ; Tempo em milissegundos (ms) de pausa entre cada micro-passo

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
    global teclaAtiva, aDown, dDown
    teclaAtiva := ""
    aDown := false
    dDown := false
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
; TAB: Apenas solta o LShift e o macro de combate (Q e E) sem restaurar depois
; ==============================================================================
~Tab:: {
    global modoCombate, direcaoCombate, modoManualFixo, teclaAtiva
    
    SendInput("{LShift up}")
    
    ; Reseta as variáveis de combate para o estado neutro
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := "centro"
    teclaAtiva := ""
    
    ; Solta fisicamente as teclas Q e E no motor do jogo
    SendInput("{Blind}{vk51 up}{vk45 up}")
}

; ==============================================================================
; FUNÇÕES DO MODO DE COMBATE COM COMPENSAÇÃO DE MIRA E SUAVIZAÇÃO
; ==============================================================================

AtivarModoCombate(lado := "", manual := false) {
    global modoCombate, direcaoCombate, teclaAtiva, modoManualFixo
    global intensidadeCorrecaoEsquerda, intensidadeCorrecaoDireita, intensidadeCorrecaoAlturaEsquerda, intensidadeCorrecaoAlturaDireita

    ; Verifica se houve mudança real de direção antes de disparar a correção
    mudouDirecao := (direcaoCombate != lado)

    ; Solta a tecla anterior se for DIFERENTE da nova direção
    if (teclaAtiva != "" && teclaAtiva != lado) {
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

        ; CORREÇÃO: teclaAtiva agora é setado corretamente
        teclaAtiva := lado

        ; COMPENSAÇÃO AUTOMÁTICA COM SUAVIZAÇÃO: Só executa quando muda de direção
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
        teclaAtiva := ""
    }

    SetTimer(DesativarModoCombatePorInatividade, -300000)
}

DesativarModoCombatePorInatividade() {
    global modoCombate, direcaoCombate, modoManualFixo, teclaAtiva
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := ""
    teclaAtiva := ""
    SendInput("{Blind}{vk51 up}{vk45 up}")
}

; ==============================================================================
; HOTKEYS DE COMBATE PADRÃO (A ativa Q | D ativa E)
; A/D RESPEITAM o modo manual fixo — não reativam combate se estiver em manual.
; Só o Shift sai do modo manual.
; ==============================================================================

~*a:: {
    global modoManualFixo, aDown
    if (aDown)
        return
    aDown := true
    if (!modoManualFixo) {
        AtivarModoCombate("q", false)
    }
}

~*a up:: {
    global aDown
    aDown := false
}

~*d:: {
    global modoManualFixo, dDown
    if (dDown)
        return
    dDown := true
    if (!modoManualFixo) {
        AtivarModoCombate("e", false)
    }
}

~*d up:: {
    global dDown
    dDown := false
}

; ==============================================================================
; TECLA SHIFT: Cancela o modo manual fixo de Q/E e restaura o macro padrão
; (ÚNICO atalho que sai do modo manual fixo)
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
    global correndo, shiftPausado, macroDesativado, modoCombate, direcaoCombate, teclaAtiva, modoManualFixo, aDown, dDown
    correndo := false
    shiftPausado := false
    macroDesativado := true
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := ""
    teclaAtiva := ""
    aDown := false
    dDown := false
    
    SetTimer(ManterCorridaForçada, 0)
    SetTimer(DesativarModoCombatePorInatividade, 0)
    
    SendInput("{Blind}{LShift up}{RShift up}{w up}{vk51 up}{vk45 up}{vk41 up}{vk44 up}")
}

PararCorrida() {
    global correndo, shiftPausado, macroDesativado, modoCombate, teclaAtiva, direcaoCombate
    correndo := false
    shiftPausado := false
    macroDesativado := true
    modoCombate := false
    teclaAtiva := ""
    direcaoCombate := ""
    
    SetTimer(ManterCorridaForçada, 0)
    SetTimer(DesativarModoCombatePorInatividade, 0)
    
    SendInput("{Blind}{LShift up}{w up}{vk51 up}{vk45 up}")
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

; W cancela o combate ativo (solta Q/E virtuais) mas NÃO sai do modo manual fixo
~w:: {
    global modoCombate, teclaAtiva, direcaoCombate
    if (modoCombate || teclaAtiva != "") {
        modoCombate := false
        direcaoCombate := ""
        teclaAtiva := ""
        SendInput("{Blind}{vk51 up}{vk45 up}")
        SetTimer(DesativarModoCombatePorInatividade, 0)
    }
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
            teclaAtiva := ""
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
            teclaAtiva := ""
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        } else {
            AtivarModoCombate("e", true)
        }
        return
    }

    AtivarModoCombate("e", true)
}

#HotIf