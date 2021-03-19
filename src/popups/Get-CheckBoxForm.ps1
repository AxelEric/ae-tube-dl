[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Form = [System.Windows.Forms.Form]::new()
$Form.Size = [System.Drawing.Size]::new(300, 200)
$Form.Text = "Youtube-dl"
$Form.StartPosition = "CenterScreen"
$Form.KeyPreview = $True

$SplitContainer = [System.Windows.Forms.SplitContainer]::new()
$Form.Controls.Add($SplitContainer)
$SplitContainer.Left = "0"
$SplitContainer.Right = "0"
$SplitContainer.Top = "0"
$SplitContainer.Bottom = "0"
$CheckBox1 = [System.Windows.Forms.CheckBox]::new()
$CheckBox1.Location = [System.Drawing.Size]::new(10, 40)
$CheckBox1.Name = "video"
$label1 = [System.Windows.Forms.Label]::new()
$label1.Location = [System.Drawing.Size]::new(30, 40)
$label1.Text="Video Download"
$Form.Controls.Add($label1)
$Form.Controls.Add($CheckBox1)

$CheckBox2 = [System.Windows.Forms.CheckBox]::new()
$CheckBox2.Location = [System.Drawing.Size]::new(10, 60)
$CheckBox2.Name="audio"
$label2 = [System.Windows.Forms.Label]::new()
$label2.Location = [System.Drawing.Size]::new(30, 60)
$label2.Text = "Audio Download"
$Form.Controls.Add($label2)
$Form.Controls.Add($CheckBox2)


$CheckBox3 = [System.Windows.Forms.CheckBox]::new()
$CheckBox3.Location = [System.Drawing.Size]::new(10, 80)
$CheckBox3.Name="playlist"
$label3 = [System.Windows.Forms.Label]::new()
$label3.Location = [System.Drawing.Size]::new(30, 80)
$label3.Text = "Playlist Download"
$Form.Controls.Add($label3)
$Form.Controls.Add($CheckBox3)


$CheckBox4 = [System.Windows.Forms.CheckBox]::new()
$CheckBox4.Location = [System.Drawing.Size]::new(10, 40)
$CheckBox4.Name="settings"
$Form.Controls.Add($CheckBox4)




$Form.Add_Shown( { $Form.Activate() })
[void] $Form.ShowDialog()
