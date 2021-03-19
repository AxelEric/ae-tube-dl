

[void][Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$title = 'Demographics'
$msg = 'Enter your demographics:'

$text = [Microsoft.CSharp.Interaction]::InputBox($msg, $title)

Write-Host $text


[void][System.Reflection.Assembly]::LoadWithPartialName('Microsoft.VisualBasic')

$name = [Microsoft.VisualBasic.Interaction]::InputBox("Enter your name", "Name", "$env:username")

"Your name is $name$"
