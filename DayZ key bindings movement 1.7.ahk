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
; TAB: Solta APENAS a tecla Shift (não interfere no W, Q, E ou modo de combate)
; ==============================================================================
~Tab:: {
    SendInput("{LShift up}")
}

; ==============================================================================
; FUNÇÕES DO MODO DE COMBATE
; ==============================================================================

AtivarModoCombate(lado := "", manual := false) {
    global modoCombate, direcaoCombate, teclaAtiva, modoManualFixo

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
    ; Funciona apenas se o modo manual fixo NÃO estiver ativado
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
    
    ; Se houver inclinação manual ativa (mesmo no centro), desativa para voltar ao automático (A e D)
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
    global correndo, shiftPausado, macroDesativado, modoCombate, direcaoCombate, teclaAtiva, modoManualFixo
    correndo := false
    shiftPausado := false
    macroDesativado := true
    modoCombate := false
    modoManualFixo := false
    direcaoCombate := ""
    teclaAtiva := ""
    
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
            ; Segundo clique no Q muda a direção manual para CENTRO (sem desativar o modo manual)
            SendInput("{Blind}{vk51 up}")
            direcaoCombate := "centro"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        } else {
            ; Alterna do E/Centro para o Q no modo manual
            SendInput("{Blind}{vk45 up}")
            Sleep(15)
            SendInput("{Blind}{vk51 down}")
            direcaoCombate := "q"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        }
        return
    }

    ; Ativa o modo manual fixo no Q
    AtivarModoCombate("q", true)
}

$*e:: {
    global teclaAtiva, modoCombate, direcaoCombate, modoManualFixo

    if (modoManualFixo) {
        if (direcaoCombate == "e") {
            ; Segundo clique no E muda a direção manual para CENTRO (sem desativar o modo manual)
            SendInput("{Blind}{vk45 up}")
            direcaoCombate := "centro"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        } else {
            ; Alterna do Q/Centro para o E no modo manual
            SendInput("{Blind}{vk51 up}")
            Sleep(15)
            SendInput("{Blind}{vk45 down}")
            direcaoCombate := "e"
            SetTimer(DesativarModoCombatePorInatividade, -300000)
        }
        return
    }

    ; Ativa o modo manual fixo no E
    AtivarModoCombate("e", true)
}

#HotIf