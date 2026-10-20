#SingleInstance Force

global teclaAtiva := ""
global ultimoTempoMovimento := 0
global lastX := 0, lastY := 0
global correndo := false

; --- VARIÁVEIS DE CONTROLE DE ESTADO ---
global macroDesativado := true  ; Inicia desativado para o Shift não ligar sozinho

; --- VARIÁVEIS DO MODO DE COMBATE ---
global modoCombate := false
global direcaoCombate := ""
global ultimoAcaoCombate := 0
global teclaUltimoToque := ""

; ==============================================================================
; Restrição Global: Todo o script funciona APENAS com o DayZ aberto e em foco
; ==============================================================================
#HotIf WinActive("ahk_exe DayZ_x64.exe")

; Monitor contínuo para inclinamento (Q e E)
SetTimer(MonitorarMouseGlobal, 5)


; ==============================================================================
; FUNÇÕES DO MODO DE COMBATE
; ==============================================================================

AtivarModoCombate(lado := "") {
    global modoCombate, direcaoCombate, teclaAtiva
    
    if (teclaAtiva != "") {
        SendInput("{" . teclaAtiva . " up}")
        teclaAtiva := ""
    }

    modoCombate := true

    if (lado == "q" || lado == "e") {
        if (direcaoCombate != lado) {
            if (direcaoCombate != "")
                SendInput("{" . direcaoCombate . " up}")
            
            SendInput("{" . lado . " down}")
            direcaoCombate := lado
        }
    }

    SetTimer(DesativarModoCombatePorInatividade, -5000)
}

DesativarModoCombatePorInatividade() {
    global modoCombate, direcaoCombate
    if (modoCombate) {
        modoCombate := false
        if (direcaoCombate != "") {
            SendInput("{" . direcaoCombate . " up}")
            direcaoCombate := ""
        }
        SendInput("{q up}{e up}")
    }
}

VerificarComboDuplo(ladoMovimento := "", teclaNome := "") {
    global ultimoAcaoCombate, teclaUltimoToque
    agora := A_TickCount
    janelaTempo := 400

    if (!GetKeyState("RButton", "P"))
        return

    if (teclaUltimoToque == teclaNome && (agora - ultimoAcaoCombate <= janelaTempo)) {
        AtivarModoCombate(ladoMovimento)
        ultimoAcaoCombate := 0
        teclaUltimoToque := ""
    } else {
        ultimoAcaoCombate := agora
        teclaUltimoToque := teclaNome
    }
}


; ==============================================================================
; HOTKEYS DE MONITORAMENTO DE COMBATE (A e D)
; ==============================================================================

~*a:: {
    VerificarComboDuplo("q", "a")
}

~*d:: {
    VerificarComboDuplo("e", "d")
}


; ==============================================================================
; Loop de Força Bruta para a Corrida com Shift Apenas se o Macro Estiver Ativo
; ==============================================================================
ManterCorridaForçada() {
    global correndo, macroDesativado
    if (macroDesativado) {
        SetTimer(ManterCorridaForçada, 0)
        return
    }
    if (correndo) {
        SendInput("{w down}")
        SendInput("{LShift down}")
    }
}


; ==============================================================================
; Função para Parar a Corrida e Soltar as Teclas com Segurança
; ==============================================================================
ResetarEstadoCompleto() {
    global correndo, macroDesativado, modoCombate, direcaoCombate
    correndo := false
    macroDesativado := true
    modoCombate := false
    direcaoCombate := ""
    
    SetTimer(ManterCorridaForçada, 0)
    SetTimer(DesativarModoCombatePorInatividade, 0)
    
    ; Libera apenas W e Shift, preservando o estado natural de Q e E
    SendInput("{LShift up}{RShift up}{w up}")
}


; ==============================================================================
; INTERRUPTORES DE CORRIDA / CANCELAMENTO 
; ==============================================================================

~NumpadSub::
~-::
~vkBD::
~Tab:: {
    ResetarEstadoCompleto()
}

~NumpadAdd::
~+:: {
    global correndo, macroDesativado
    macroDesativado := false
    correndo := true
    SetTimer(ManterCorridaForçada, 50)
}


; ==============================================================================
; INTERRUPTOR DE PARADA RÁPIDA: Tecla S
; ==============================================================================
~*s:: {
    ResetarEstadoCompleto()
}


; ==============================================================================
; W - APENAS MOVE O PERSONAGEM (Não ativa o Shift automático sozinho)
; ==============================================================================
~w:: {
    return
}


; ==============================================================================
; Monitoramento do Cursor (Inclinamento de Q e E) com Inatividade de 30 Segundos
; ==============================================================================
MonitorarMouseGlobal() {
    global teclaAtiva, ultimoTempoMovimento, lastX, lastY, modoCombate

    ; Se estiver no modo combate, o mouse não controla o Q e E por inclinação
    if (modoCombate)
        return

    centerX := A_ScreenWidth / 2
    limiteDistancia := 200

    MouseGetPos(&currentX, &currentY)

    ; Verifica se houve movimento real do mouse
    if (Abs(currentX - lastX) > 2 || Abs(currentY - lastY) > 2) {
        ultimoTempoMovimento := A_TickCount
        lastX := currentX
        lastY := currentY
    }

    ; Tempo limite de inatividade: 20 segundos (20000 ms)
    tempoInatividadeLimite := 20000

    ; Se passou o tempo limite sem mexer o mouse, solta a tecla ativa (se houver)
    if (ultimoTempoMovimento != 0 && (A_TickCount - ultimoTempoMovimento) > tempoInatividadeLimite) {
        if (teclaAtiva != "") {
            SendInput("{" . teclaAtiva . " up}")
            teclaAtiva := ""
        }
        return
    }

    distanciaX := currentX - centerX

    if (distanciaX > limiteDistancia) {
        if (teclaAtiva != "e") {
            if (teclaAtiva != "")
                SendInput("{" . teclaAtiva . " up}")
            SendInput("{e down}")
            teclaAtiva := "e"
        }
    } 
    else if (distanciaX < -limiteDistancia) {
        if (teclaAtiva != "q") {
            if (teclaAtiva != "")
                SendInput("{" . teclaAtiva . " up}")
            SendInput("{q down}")
            teclaAtiva := "q"
        }
    }
}


; ==============================================================================
; Controle Manual do Q e E
; ==============================================================================
$q:: {
    global teclaAtiva, modoCombate, direcaoCombate

    if (modoCombate) {
        if (direcaoCombate == "q") {
            SetTimer(DesativarModoCombatePorInatividade, 0)
            DesativarModoCombatePorInatividade()
        } else {
            SendInput("{e up}{q down}")
            direcaoCombate := "q"
            SetTimer(DesativarModoCombatePorInatividade, -5000)
        }
        return
    }

    if (teclaAtiva == "") {
        SendInput("{q down}")
        teclaAtiva := "q"
    } else if (teclaAtiva == "q") {
        SendInput("{q up}")
        teclaAtiva := ""
    } else if (teclaAtiva == "e") {
        SendInput("{e up}")
        SendInput("{q down}")
        teclaAtiva := "q"
    }
}

$e:: {
    global teclaAtiva, modoCombate, direcaoCombate

    if (modoCombate) {
        if (direcaoCombate == "e") {
            SetTimer(DesativarModoCombatePorInatividade, 0)
            DesativarModoCombatePorInatividade()
        } else {
            SendInput("{q up}{e down}")
            direcaoCombate := "e"
            SetTimer(DesativarModoCombatePorInatividade, -5000)
        }
        return
    }

    if (teclaAtiva == "") {
        SendInput("{e down}")
        teclaAtiva := "e"
    } else if (teclaAtiva == "e") {
        SendInput("{e up}")
        teclaAtiva := ""
    } else if (teclaAtiva == "q") {
        SendInput("{q up}")
        SendInput("{e down}")
        teclaAtiva := "e"
    }
}

#HotIf  ; Fim do contexto restrito ao DayZ