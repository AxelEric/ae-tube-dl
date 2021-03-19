function Write-Colored {
    param (
        [string]$Text,
        [switch]$NoNewline,
        [switch]$I,
        [switch]$W,
        [switch]$E,
        [System.ConsoleColor]$BracketsColor = 'Red',
        [System.ConsoleColor]$PonctuationColor = 'Red',
        [System.ConsoleColor]$ForegroundColor = "Green",
        [System.ConsoleColor]$ControlColor = 'Red',
        [System.ConsoleColor]$NumberColor = 'Green',
        [System.ConsoleColor]$SeparatorColor = 'Green',
        [System.ConsoleColor]$SymbolColor = 'Red',
        [System.ConsoleColor]$LetterColor = 'Green'
    )

    if ( $null -eq $Text) {
        Write-Host "null" -ForegroundColor DarkBlue
    }
    else {
        if ($I) {
            Write-Host "[" -NoNewline -ForegroundColor Green
            Write-Host "Info" -NoNewline -ForegroundColor Yellow
            Write-Host "]" -NoNewline -ForegroundColor Green
        }
        if ($W) {
            Write-Host "[" -NoNewline -ForegroundColor Green
            Write-Host "Warn" -NoNewline -ForegroundColor DarkYellow
            Write-Host "]" -NoNewline -ForegroundColor Green
        }
        if ($E) {
            Write-Host "["-NoNewline -ForegroundColor Green
            Write-Host "Error"-NoNewline -ForegroundColor Red
            Write-Host "]"-NoNewline -ForegroundColor Green
        }

        $String = $Text.ToCharArray()
        foreach ($char in $String) {
            switch ( $char ) {
                { [Char]::IsControl($_) } { Write-Host $char -NoNewline -ForegroundColor $ControlColor }
                { [Char]::IsLetter($_) } { Write-Host $char -NoNewline -ForegroundColor $ForegroundColor }
                { [Char]::IsNumber($_) } { Write-Host $char -NoNewline -ForegroundColor $NumberColor }
                { [Char]::IsPunctuation($_) } { Write-Host $char -NoNewline -ForegroundColor $PonctuationColor }
                { [Char]::IsSeparator($_) } { Write-Host $char -NoNewline -ForegroundColor $SeparatorColor }
                { [Char]::IsSymbol($_) } { Write-Host $char -NoNewline -ForegroundColor $SymbolColor }
                Default { }
            }
        }
    }
    if ($NoNewline) { Write-Host -NoNewline }
    else { Write-Host }

}
$MenuOption="5"
While ( ($MenuOption -match "[01234]") -eq $False ) {║

    Write-Colored "`n`t`t
    `t`t ╔════════════════════════════════════════════════════════════════════════════════════════╗
    `t`t ║                               PowerShell-Youtube-dl                                    ║
    `t`t ╠════════════════════════════════════════════════════════════════════════════════════════╣
    `t`t ║                                                                                        ║
    `t`t ║                            Please select an option:                                    ║
    `t`t ║                                                                                        ║
    `t`t ║                                1) to Download video                                    ║
    `t`t ║                                2) to Download audio                                    ║
    `t`t ║                                3) to Download a playlist file                          ║
    `t`t ║                                4) to Open Settings                                     ║
    `t`t ║                                0) to Exit                                              ║
    `t`t ║                                                                                        ║
    `t`t ╚════════════════════════════════════════════════════════════════════════════════════════╝"
    $MenuOption = Read-Host -Prompt (Write-Colored "`n`t`t`t`t`t`t [0-4] : " -NoNewline)
}

Write-Host "`n`tYou choose the option: $MenuOption`n"
