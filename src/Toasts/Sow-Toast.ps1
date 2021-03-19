[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$objNotifyIcon= [System.Windows.Forms.NotifyIcon]::new()
$objNotifyIcon.Icon = [System.Drawing.Icon]::new("J:\PowerShell-Youtube-dl\src\Toasts\img\folder-empty.ico", [System.Drawing.Size]::new(32, 32))
$ErrorIcon = "Error"
$objNotifyIcon.BalloonTipIcon = $ErrorIcon
$objNotifyIcon.BalloonTipText = "A file needed to complete the operation could not be found."
$objNotifyIcon.BalloonTipTitle = "File Not Found"

$objNotifyIcon.Visible = $True
$objNotifyIcon.ShowBalloonTip(10000)
