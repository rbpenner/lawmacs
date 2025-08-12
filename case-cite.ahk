#Requires AutoHotkey v2.0

; Case citation helper — mirrors Emacs case-cite-skeleton.el
; Hotkey: Ctrl+Alt+C opens a prompt wizard, inserts the long cite at the caret,
; and defines three hotstrings:
;   ::<trigger>   -> "<Case Name>, <Main reporter cite> (<Court and date>)"  ; no pincite, case name italicized via Ctrl+I
;   ::<trigger>sh -> "<Short case name>, <Main reporter cite (shortened unless contains WL)> at" ; case name italicized via Ctrl+I
;   ::<trigger>n  -> "<Short case name>" ; italicized via Ctrl+I
; Immediate insertion: italicizes the Case Name by sending Ctrl+I before and after the name (no slash wrappers).

gCaseTriggerSet := Map()

^!c:: {
    global gCaseTriggerSet
    try {
        caseName := Prompt("Case Name:")
        mainReporter := Prompt("Main reporter cite:")
        pincite := Prompt("Pincite (optional):")
        courtDate := Prompt("Court and date:")
        trigger := Prompt("Abbrev trigger:")
        gCaseTriggerSet[trigger] := true
        shortCaseName := Prompt("Short case name:")

        ; Build the tail of the citation (text following the case name)
        restAfterCase := ", " mainReporter
        if (Trim(pincite) != "")
            restAfterCase .= ", " Trim(pincite)
        restAfterCase .= " (" courtDate ")"

        ; Build long-form hotstring textual tail (no pincite)
        longTail := ", " mainReporter " (" courtDate ")"

        ; Build short reporter portion: if mainReporter contains "WL", keep as-is;
        ; otherwise drop the last whitespace-separated token (e.g., the page).
        tokens := StrSplit(mainReporter, " ")
        hasWL := false
        for token in tokens {
            if (token = "WL") {
                hasWL := true
                break
            }
        }
        if (!hasWL && tokens.Length > 1) {
            shortReporter := ""
            Loop tokens.Length - 1 {
                shortReporter .= (A_Index = 1 ? "" : " ") . tokens[A_Index]
            }
        } else {
            shortReporter := mainReporter
        }

        shortTail := ", " shortReporter " at"

        ; Define dynamic hotstrings with callbacks to apply italics (Ctrl+I) around names
        Hotstring("::" . trigger, (*) => TypeItalicThen(caseName, longTail))
        Hotstring("::" . trigger . "sh", (*) => TypeItalicThen(shortCaseName, shortTail))
        Hotstring("::" . trigger . "n", (*) => TypeItalic(shortCaseName))

        ; Insert the citation at the caret, italicizing the case name via Ctrl+I
        TypeItalic(caseName)
        SendText(restAfterCase)

        ; Brief confirmation
        ToolTip("Defined hotstrings: " . trigger . ", " . trigger . "sh, " . trigger . "n", , , 1)
        SetTimer(() => ToolTip(), -1500)
    } catch as err {
        ; Canceled — do nothing
    }
}

Prompt(prompt) {
    ib := InputBox(prompt, "Case Cite", "w400")
    if (ib.Result != "OK")
        throw Error("Canceled")
    return ib.Value
}

TypeItalic(text) {
    Send("^i")
    SendText(text)
    Send("^i")
}

TypeItalicThen(name, tail) {
    Send("^i")
    SendText(name)
    Send("^i")
    SendText(tail)
}

^!l:: {
    global gCaseTriggerSet
    triggers := []
    for trig, _ in gCaseTriggerSet
        triggers.Push(trig)
    if (triggers.Length = 0) {
        MsgBox("No case triggers defined.")
        return
    }
    triggers.Sort()
    MsgBox("Active case triggers:`n" . triggers.Join("`n"))
}