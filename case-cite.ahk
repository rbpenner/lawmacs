#Requires AutoHotkey v2.0

; Case citation helper — mirrors Emacs case-cite-skeleton.el
; Hotkey: Ctrl+Alt+C opens a prompt wizard, inserts the long cite at the caret,
; and defines three hotstrings:
;   ::<trigger>   -> "/<Case Name>/, <Main reporter cite> (<Court and date>)"  ; no pincite (matches abbrev behavior)
;   ::<trigger>sh -> "/<Short case name>/, <Main reporter cite (shortened unless contains WL)> at"
;   ::<trigger>n  -> "/<Short case name>/"
; Immediate insertion: italicizes the Case Name by sending Ctrl+I before and after the name (no slash wrappers).

^!c:: {
    try {
        caseName := Prompt("Case Name:")
        mainReporter := Prompt("Main reporter cite:")
        pincite := Prompt("Pincite (optional):")
        courtDate := Prompt("Court and date:")
        trigger := Prompt("Abbrev trigger:")
        shortCaseName := Prompt("Short case name:")

        ; Build the tail of the citation (text following the case name)
        restAfterCase := ", " mainReporter
        if (Trim(pincite) != "")
            restAfterCase .= ", " Trim(pincite)
        restAfterCase .= " (" courtDate ")"

        ; Build long-form hotstring text (no pincite, mirrors Emacs abbrev)
        longCiteAbbrev := "/" caseName "/, " mainReporter " (" courtDate ")"

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

        shortCite := "/" shortCaseName "/, " shortReporter " at"
        shortNameText := "/" shortCaseName "/"

        ; Define dynamic hotstrings
        Hotstring("::" . trigger, longCiteAbbrev)
        Hotstring("::" . trigger . "sh", shortCite)
        Hotstring("::" . trigger . "n", shortNameText)

        ; Insert the citation at the caret, italicizing the case name via Ctrl+I
        Send("^i")
        SendText(caseName)
        Send("^i")
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