<#
.SYNOPSIS
	Download video and audio from the internet, mainly from youtube.com

.DESCRIPTION
	This script downloads audio and video from the internet using the programs youtube-dl and ffmpeg. This script can be ran as a command using parameters, or it can be ran without parameters to use its GUI. Files are downloaded to the user's "Videos" and "Music" folders by default. See README.md for more information.

.PARAMETER Video
	Download the video of the provided URL. Output file formats will vary.
.PARAMETER Audio
	Download only the audio of the provided URL. Output file format will be mp3.
.PARAMETER Playlists
	Download playlist URL's listed in videoplaylists.txt and audioplaylists.txt
.PARAMETER Convert
	Convert the downloaded video to the default file format using the default settings.
.PARAMETER URL
	The video URL to download from.
.PARAMETER OutputPath
	The directory where to save the output file.
.PARAMETER DownloadOptions
	Additional youtube-dl parameters for downloading.
.PARAMETER Install
	Install the script to "C:\Users\%USERNAME%\Scripts\Youtube-dl" and create desktop and Start Menu shortcuts.
.PARAMETER Update-Exe
	Update youtube-dl.exe and the ffmpeg files to the most recent versions.
.PARAMETER Update-Script
	Update the youtube-dl.ps1 script file to the most recent version.

.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1
	Runs the script in GUI mode.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads the video at the specified URL.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0"
	Downloads only the audio of the specified video URL.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Playlists
	Downloads video URL's listed in videoplaylists.txt and audioplaylists.txt files. These files are generated when the script is ran for the first time.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Audio -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -OutputPath "C:\Users\%USERNAME%\Desktop"
	Downloads the audio of the specified video URL to the user provided location.
.EXAMPLE
	C:\Users\%USERNAME%\Scripts\Youtube-dl\youtube-dl.ps1 -Video -URL "https://www.youtube.com/watch?v=oHg5SJYRHA0" -DownloadOptions "-f bestvideo+bestaudio"
	Downloads the video at the specified URL and utilizes the provided youtube-dl parameters.

.NOTES
	Requires Windows 7 or higher, PowerShell 5.0 or greater, and Microsoft Visual C++ 2010 Redistributable Package (x86).
	Author: mpb10
	Updated: May 7th, 2018
	Version: 2.0.3

.LINK
	https://github.com/mpb10/PowerShell-Youtube-dl
#>
#* =============================================================================== #
#* =============================================================================== #
Param(
    [Switch]$Video,
    [Switch]$Audio,
    [Switch]$Playlists,
    [Switch]$Convert,
    [Switch]$Install,
    [Switch]$UpdateExe,
    [Switch]$UpdateScript,

    [String]$URL,
    [String]$OutputPath,
    [String]$DownloadOptions

)
<#* =============================================================================== #>
<#!                                 SCRIPT SETTINGS                                 #>
<#* =============================================================================== #>

$BaseUrl = "K:\"
$VideosUrl = "videos\"
$MusiqueUrl = "musique\"

$VideoSaveLocation = "$BaseUrl$VideosUrl"
$AudioSaveLocation = "$BaseUrl$MusiqueUrl"
$PortableSaveLocation = "$PSScriptRoot\portableDl"
$UseArchiveFile = $True
$EntirePlaylist = $False
$VerboseDownloading = $False
$CheckForUpdates = $False

$ConvertFile = $False
$FileExtension = "webm"
$VideoBitrate = "-b:v 800k"
$AudioBitrate = "-b:a 128k"
$Resolution = "-s 640x360"
$StartTime = ""
$StopTime = ""
$StripAudio = ""
$StripVideo = ""


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
        [System.ConsoleColor]$LetterColor = 'Green',
        [System.ConsoleColor]$Orange = '#ff7500'
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
            Write-Host "Warn" -NoNewline -ForegroundColor $Orange
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
<#* =============================================================================== #>
<#!                                     FUNCTIONS                                   #>
<#* =============================================================================== #>

#* Function for simulating the 'pause' command of the Windows command line.
Function Stop-Script {
    If ($NumOfParams -eq 0) {
        Write-Host "`nPress any key to continue ...`n" -ForegroundColor "Gray"
        $Wait = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyUp")
    }
    $Null = $Wait
}
Function Get-File {
    Param(
        [String]$URLToDownload,
        [String]$SaveLocation
    )
    New-Object [System.Net.WebClient].Get-File("$URLToDownload", "$TempFolder\download.tmp")
    Move-Item -Path "$TempFolder\download.tmp" -Destination "$SaveLocation" -Force
}
Function Get-YoutubeDL {
    Get-File "http://yt-dl.org/downloads/latest/youtube-dl.exe" "$BinFolder\youtube-dl.exe"
}
Function Get-Ffmpeg {

    Get-File "https://github.com/BtbN/FFmpeg-Builds/releases/download/autobuild-2021-03-15-12-32/ffmpeg-n4.3.2-160-gfbb9368226-win64-gpl-shared-4.3.zip" "$BinFolder\ffmpeg_latest.zip"
    # Get-File "https://www.gyan.dev/ffmpeg/builds/ffmpeg-git-full.7z" "$BinFolder\ffmpeg\gianDev\ffmpeg_latest.7z"

    Expand-Archive -Path "$BinFolder\ffmpeg_latest.zip" -DestinationPath "$BinFolder"

    Copy-Item -Path "$BinFolder\ffmpeg-*-win*-static\bin\*" -Destination "$BinFolder" -Recurse -Filter "*.exe" -ErrorAction Silent
    Remove-Item -Path "$BinFolder\ffmpeg_latest.zip"
    Remove-Item -Path "$BinFolder\ffmpeg-*-win*-static" -Recurse
}
Function Get-ScriptInit {
    $Script:BinFolder = $RootFolder + "\bin"
    If ((Test-Path "$BinFolder") -eq $False) {
        New-Item -Type Directory -Path "$BinFolder" | Out-Null
    }
    $ENV:Path += ";$BinFolder"

    $Script:TempFolder = $RootFolder + "\temp"
    If ((Test-Path "$TempFolder") -eq $False) {
        New-Item -Type Directory -Path "$TempFolder" | Out-Null
    }
    Else {
        Remove-Item -Path "$TempFolder\download.tmp" -ErrorAction Silent
    }

    $Script:CacheFolder = $RootFolder + "\cache"
    If ((Test-Path "$CacheFolder") -eq $False) {
        New-Item -Type Directory -Path "$CacheFolder" | Out-Null
    }

    $Script:ConfigFolder = $RootFolder + "\config"
    If ((Test-Path "$ConfigFolder") -eq $False) {
        New-Item -Type Directory -Path "$ConfigFolder" | Out-Null
    }

    $Script:VideoArchiveFile = $ConfigFolder + "\Get-VideoDownloadArchive.txt"
    If ((Test-Path "$VideoArchiveFile") -eq $False) {
        New-Item -Type file -Path "$VideoArchiveFile" | Out-Null
    }

    $Script:AudioArchiveFile = $ConfigFolder + "\Get-AudioDownloadArchive.txt"
    If ((Test-Path "$AudioArchiveFile") -eq $False) {
        New-Item -Type file -Path "$AudioArchiveFile" | Out-Null
    }

    $Script:PlaylistFile = $ConfigFolder + "\PlaylistFile.txt"
    If ((Test-Path "$PlaylistFile") -eq $False) {
        Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/PlaylistFile.txt" "$PlaylistFile"
    }
}
Function Install-Script {
    If ($PSScriptRoot -eq "$InstallLocation") {
        Write-Host "`nPowerShell-Youtube-dl files are already installed."
        Stop-Script
        Return
    }
    Else {
        $MenuOption = Read-Host "`nInstall PowerShell-Youtube-dl to ""$InstallLocation""? [y/n]"

        If ($MenuOption -like "y" -or $MenuOption -like "yes") {
            Write-Host "`nInstalling to ""$InstallLocation"" ..."

            $Script:RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
            Get-ScriptInit

            $DesktopFolder = $ENV:USERPROFILE + "\Desktop"
            $StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
            If ((Test-Path "$StartFolder") -eq $False) {
                New-Item -Type Directory -Path "$StartFolder" | Out-Null
            }

            Get-YoutubeDL
            Get-Ffmpeg

            Copy-Item "$PSScriptRoot\youtube-dl.ps1" -Destination "$RootFolder"

            Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
            Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder\Youtube-dl.lnk"
            Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder\Youtube-dl.lnk"

            Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE.txt"
            Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"

            Write-Host "`nInstallation complete. Please restart the script." -ForegroundColor "Yellow"
            Stop-Script
            Exit
        }
        Else {
            Return
        }
    }
}
Function Update-Exe {
    Write-Host "`nUpdating youtube-dl.exe and ffmpeg.exe files ..."

    Get-YoutubeDL
    Get-Ffmpeg

    Write-Host "`nUpdate .exe files complete." -ForegroundColor "Yellow"
    Stop-Script

    If ($UpdateScript -eq $False) {
        exit
    }
}
Function Update-Script {
    Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/version-file" "$TempFolder\version-file.txt"
    [Version]$NewestVersion = Get-Content "$TempFolder\version-file.txt" | Select-Object -Index 0
    Remove-Item -Path "$TempFolder\version-file.txt"

    If ($NewestVersion -gt $RunningVersion) {
        Write-Host "`nA new version of PowerShell-Youtube-dl is available: v$NewestVersion" -ForegroundColor "Yellow"
        $MenuOption = Read-Host "`nUpdate to this version? [y/n]"

        If ($MenuOption -like "y" -or $MenuOption -like "yes") {
            Get-File "http://github.com/mpb10/PowerShell-Youtube-dl/raw/master/youtube-dl.ps1" "$RootFolder\youtube-dl.ps1"

            If ($PSScriptRoot -eq "$InstallLocation") {
                $DesktopFolder = $ENV:USERPROFILE + "\Desktop"
                $StartFolder = $ENV:APPDATA + "\Microsoft\Windows\Start Menu\Programs\Youtube-dl"
                If ((Test-Path "$StartFolder") -eq $False) {
                    New-Item -Type Directory -Path "$StartFolder" | Out-Null
                }
                Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/Youtube-dl.lnk" "$RootFolder\Youtube-dl.lnk"
                Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$DesktopFolder\Youtube-dl.lnk"
                Copy-Item "$RootFolder\Youtube-dl.lnk" -Destination "$StartFolder\Youtube-dl.lnk"
                Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/LICENSE" "$RootFolder\LICENSE.txt"
                Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/README.md" "$RootFolder\README.md"
            }

            Get-File "https://github.com/mpb10/PowerShell-Youtube-dl/raw/master/install/files/UpdateNotes.txt" "$TempFolder\UpdateNotes.txt"
            Get-Content "$TempFolder\UpdateNotes.txt"
            Remove-Item "$TempFolder\UpdateNotes.txt"

            Write-Host "`nUpdate complete. Please restart the script." -ForegroundColor "Yellow"

            Stop-Script
            Exit
        }
        Else {
            Return
        }
    }
    ElseIf ($NewestVersion -eq $RunningVersion) {
        Write-Host "`nThe running version of PowerShell-Youtube-dl is up-to-date." -ForegroundColor "Yellow"
    }
    Else {
        Write-Host "`n[ERROR] Script version mismatch. Re-installing the script is recommended." -ForegroundColor "Red" -BackgroundColor "Black"
        Stop-Script
    }
}
Function Get-SettingsInit {
    If ($UseArchiveFile -eq $True) {
        $Script:SetVideoArchiveFile = "--download-archive ""$VideoArchiveFile"""
        $Script:SetAudioArchiveFile = "--download-archive ""$AudioArchiveFile"""
    }
    Else {
        $Script:SetUseArchiveFile = ""
    }

    If ($EntirePlaylist -eq $True) {
        $Script:SetEntirePlaylist = "--yes-playlist"
    }
    Else {
        $Script:SetEntirePlaylist = "--no-playlist"
    }

    If ($VerboseDownloading -eq $True) {
        $Script:SetVerboseDownloading = ""
    }
    Else {
        $Script:SetVerboseDownloading = "--quiet --no-warnings"
    }

    If ($StripVideo -eq $True) {
        $SetStripVideo = "-vn"
    }
    Else {
        $SetStripVideo = ""
    }

    If ($StripAudio -eq $True) {
        $SetStripAudio = "-an"
    }
    Else {
        $SetStripAudio = ""
    }

    If ($ConvertFile -eq $True -or $Convert -eq $True) {
        $Script:FfmpegCommand = "--recode-video $FileExtension --postprocessor-args ""$VideoBitrate $AudioBitrate $Resolution $StartTime $StopTime $SetStripVideo $SetStripAudio"" --prefer-ffmpeg"
    }
    Else {
        $Script:FfmpegCommand = ""
    }
}
Function Get-VideoDownload {
    Param(
        [String]$URLToDownload
    )
    $URLToDownload = $URLToDownload.Trim()
    Write-Host "`nDownloading video from: $URLToDownload`n"
    If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
        $YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions $FfmpegCommand --yes-playlist $SetVideoArchiveFile ""$URLToDownload"""
    }
    Else {
        $YoutubedlCommand = "youtube-dl -o ""$VideoSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions $FfmpegCommand $SetEntirePlaylist ""$URLToDownload"""
    }
    Invoke-Expression "$YoutubedlCommand"
}
Function Get-AudioDownload {
    Param(
        [String]$URLToDownload
    )
    $URLToDownload = $URLToDownload.Trim()
    Write-Host "`nDownloading audio from: $URLToDownload`n"
    If ($URLToDownload -like "*youtube.com/playlist*" -or $EntirePlaylist -eq $True) {
        $YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(playlist)s\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg --yes-playlist $SetAudioArchiveFile ""$URLToDownload"""
    }
    Else {
        $YoutubedlCommand = "youtube-dl -o ""$AudioSaveLocation\%(title)s.%(ext)s"" --ignore-errors --console-title --no-mtime $SetVerboseDownloading --cache-dir ""$CacheFolder"" $DownloadOptions -x --audio-format mp3 --audio-quality 0 --metadata-from-title ""(?P<artist>.+?) - (?P<title>.+)"" --add-metadata --prefer-ffmpeg $SetEntirePlaylist ""$URLToDownload"""
    }
    Invoke-Expression "$YoutubedlCommand"
}
Function Get-PlaylistDownload {
    Write-Host "`nDownloading playlist URLs listed in: ""$PlaylistFile"""

    $PlaylistArray = Get-Content "$PlaylistFile" | Where-Object { $_.Trim() -ne "" -and $_.Trim() -notlike "#*" }

    $VideoPlaylistArray = $PlaylistArray | Select-Object -Index (($PlaylistArray.IndexOf("[Video Playlists]".Trim()))..($PlaylistArray.IndexOf("[Audio Playlists]".Trim()) - 1))
    $AudioPlaylistArray = $PlaylistArray | Select-Object -Index (($PlaylistArray.IndexOf("[Audio Playlists]".Trim()))..($PlaylistArray.Count - 1))

    If ($VideoPlaylistArray.Count -gt 1) {
        $VideoPlaylistArray | Where-Object { $_ -ne $VideoPlaylistArray[0] } | ForEach-Object {
            Write-Verbose "`nDownloading playlist: $_`n"
            Get-VideoDownload "$_"
        }
    }
    Else {
        Write-Verbose "The [Video Playlists] section is empty."
    }

    If ($AudioPlaylistArray.Count -gt 1) {
        $AudioPlaylistArray | Where-Object { $_ -ne $AudioPlaylistArray[0] } | ForEach-Object {
            Write-Verbose "`nDownloading playlist: $_`n"
            Get-AudioDownload "$_"
        }
    }
    Else {
        Write-Verbose "The [Audio Playlists] section is empty."
    }
}
Function Get-CommandLine {

    If ($Install -eq $True) {
        Install-Script
        Exit
    }
    ElseIf ($UpdateExe -eq $True -and $UpdateScript -eq $True) {
        Update-Exe
        Update-Script
        Exit
    }
    ElseIf ($UpdateExe -eq $True) {
        Update-Exe
        Exit
    }
    ElseIf ($UpdateScript -eq $True) {
        Update-Script
        Exit
    }

    If (($OutputPath.Length -gt 0) -and ((Test-Path "$OutputPath") -eq $False)) {
        New-Item -Type directory -Path "$OutputPath" | Out-Null
        $Script:VideoSaveLocation = $OutputPath
        $Script:AudioSaveLocation = $OutputPath
    }
    ElseIf ($OutputPath.Length -gt 0) {
        $Script:VideoSaveLocation = $OutputPath
        $Script:AudioSaveLocation = $OutputPath
    }

    Get-SettingsInit

    If ($Playlists -eq $True -and ($Video -eq $True -or $Audio -eq $True)) {
        Write-Host "`n[ERROR]: The parameter -Playlists can't be used with -Video or -Audio.`n" -ForegroundColor "Red" -BackgroundColor "Black"
    }
    ElseIf ($Playlists -eq $True) {
        Get-PlaylistDownload
        Write-Host "`nDownloads complete. Downloaded to:`n   $VideoSaveLocation`n   $AudioSaveLocation`n" -ForegroundColor "Yellow"
    }
    ElseIf ($Video -eq $True -and $Audio -eq $True) {
        Write-Host "`n[ERROR]: Please select either -Video or -Audio. Not Both.`n" -ForegroundColor "Red" -BackgroundColor "Black"
    }
    ElseIf ($Video -eq $True) {
        Get-VideoDownload "$URL"
        Write-Host "`nDownload complete.`nDownloaded to: ""$VideoSaveLocation""`n" -ForegroundColor "Yellow"
    }
    ElseIf ($Audio -eq $True) {
        Get-AudioDownload "$URL"
        Write-Host "`nDownload complete.`nDownloaded to: ""$AudioSaveLocation`n""" -ForegroundColor "Yellow"
    }
    Else {
        Write-Host "`n[ERROR]: Invalid parameters provided." -ForegroundColor "Red" -BackgroundColor "Black"
    }

    Exit
}
Function Write-MainMenu {
    $MenuOption = $null
    While ($MenuOption -ne "[0-4]")
    <# -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 4 -and $MenuOption -ne 0) #> {
        $URL = ""
        Clear-Host
        Write-Host´n"|========================================================================================|
                     |                       PowerShell-Youtube-dl v${RunningVersion}                         |
                     | =======================================================================================|
                     |                                                                                        |
                     |                   Please select an option:                                             |
                     |                                                                                        |
                     |                                1) to Download video                                    |
                     |                                2) to Download audio                                    |
                     |                                3) to Download from playlist file                       |
                     |                                4) for Settings                                         |
                     |                                0) to Exit                                              |
                     |                                                                                        |
                     |        ${MenuOption} = $(Read-Host "Option")                                           |
                     |                                                                                        |
                     | =======================================================================================|"


        Switch ($MenuOption) {
            1 {
                Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
                $URL = (Read-Host "URL").Trim()

                If ($URL.Length -gt 0) {
                    Clear-Host
                    Get-SettingsInit
                    Get-VideoDownload $URL
                    Write-Host "`nFinished downloading video to: ""$VideoSaveLocation""" -ForegroundColor "Yellow"
                    Stop-Script
                }
                $MenuOption = 99
            }
            2 {
                Write-Host "`nPlease enter the URL you would like to download from:`n" -ForegroundColor "Yellow"
                $URL = (Read-Host "URL").Trim()

                If ($URL.Length -gt 0) {
                    Clear-Host
                    Get-SettingsInit
                    Get-AudioDownload $URL
                    Write-Host "`nFinished downloading audio to: ""$AudioSaveLocation""" -ForegroundColor "Yellow"
                    Stop-Script
                }
                $MenuOption = 99
            }
            3 {
                Clear-Host
                Get-SettingsInit
                Get-PlaylistDownload
                Write-Host "`nFinished downloading URLs from playlist files." -ForegroundColor "Yellow"
                Stop-Script
                $MenuOption = 99
            }
            4 {
                Clear-Host
                SettingsMenu
                $MenuOption = 99
            }
            0 {
                Clear-Host
                Exit
            }
            Default {
                Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
                Stop-Script
            }
        }
    }
}
Function Write-SettingsMenu {
    $MenuOption = 99
    While ($MenuOption -ne 1 -and $MenuOption -ne 2 -and $MenuOption -ne 3 -and $MenuOption -ne 0) {
        Clear-Host
        Write-Host "==================================================================================================="
        Write-Host "                                           Settings Menu                                           " -ForegroundColor "Yellow"
        Write-Host "==================================================================================================="
        Write-Host "`nPlease select an option:`n" -ForegroundColor "Yellow"
        Write-Host "  1   - Update youtube-dl.exe and ffmpeg.exe"
        Write-Host "  2   - Update youtube-dl.ps1 script file"
        If ($PSScriptRoot -ne "$InstallLocation") {
            Write-Host "  3   - Install script to: ""$InstallLocation"""
        }
        Write-Host "`n  0   - Return to Main Menu`n" -ForegroundColor "Gray"
        $MenuOption = Read-Host "Option"

        Write-Host "`n==================================================================================================="

        Switch ($MenuOption) {
            1 {
                Update-Exe
                $MenuOption = 99
            }
            2 {
                Update-Script
                Stop-Script
                $MenuOption = 99
            }
            3 {
                Install-Script
                $MenuOption = 99
            }
            0 {
                Return
            }
            Default {
                Write-Host "`nPlease enter a valid option." -ForegroundColor "Red"
                Stop-Script
            }
        }
    }
}

<#* =============================================================================== #>
<#!                                    MAIN                                         #>
<#* =============================================================================== #>

If ($PSVersionTable.PSVersion.Major -lt 5) {
    Write-Host "[ERROR]: Your PowerShell installation is not version 5.0 or greater.`n        This script requires PowerShell version 5.0 or greater to function.`n        You can download PowerShell version 5.0 at:`n            https://www.microsoft.com/en-us/download/details.aspx?id=50395" -ForegroundColor "Red" -BackgroundColor "Black"
    Stop-Script
    Exit
}

[Version]$RunningVersion = '2.0.3'

[Net.ServicePointManager]::SecurityProtocol = "tls12, tls11, tls"

$NumOfParams = ($PSBoundParameters.Count)

$InstallLocation = "$ENV:USERPROFILE\Scripts\Youtube-dl"

If ($PSScriptRoot -eq "$InstallLocation") {
    $RootFolder = $ENV:USERPROFILE + "\Scripts\Youtube-dl"
}
Else {
    $RootFolder = "$PSScriptRoot"
    $VideoSaveLocation = $PortableSaveLocation
    $AudioSaveLocation = $PortableSaveLocation
}

If ($Install -eq $False) {
    Get-ScriptInit
}

If ($CheckForUpdates -eq $True -and $Install -eq $False) {
    Update-Script
}

If ((Test-Path "$BinFolder\youtube-dl.exe") -eq $False -and $Install -eq $False) {
    Write-Host "`nyoutube-dl.exe not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
    Get-YoutubeDL
}

If (((Test-Path "$BinFolder\ffmpeg.exe") -eq $False -or (Test-Path "$BinFolder\ffplay.exe") -eq $False -or (Test-Path "$BinFolder\ffprobe.exe") -eq $False) -and $Install -eq $False) {
    Write-Host "ffmpeg files not found. Downloading and installing to: ""$BinFolder"" ...`n" -ForegroundColor "Yellow"
    Get-Ffmpeg
}

If ($NumOfParams -gt 0) {
    CommandLineMode
}
Else {

    MainMenu

    Stop-Script
    Exit
}











