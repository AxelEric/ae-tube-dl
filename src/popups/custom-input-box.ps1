[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Drawing")
[void] [System.Reflection.Assembly]::LoadWithPartialName("System.Windows.Forms")

$Form = [System.Windows.Forms.Form]::new()
$Form.Size = [System.Drawing.Size]::new(300, 200)
$Form.Text = "Data Entry Form"
$Form.StartPosition = "CenterScreen"
$Form.KeyPreview = $True

$TextBox1 = [System.Windows.Forms.TextBox]::new()
$TextBox1.Location = [System.Drawing.Size]::new(10, 40)
$TextBox1.Size = [System.Drawing.Size]::new(260, 20)
$Form.Controls.Add($TextBox1)

$TextBox2 = [System.Windows.Forms.TextBox]::new()
$TextBox2.Visible = $false
$Form.Controls.Add($TextBox2)

$Form.Add_KeyDown( { if ($_.KeyCode -eq "Enter") { $TextBox2.Text = $TextBox1.Text; $Form.Close() } } )
$Form.Add_KeyDown( { if ($_.KeyCode -eq "Escape") { $Form.Close() } } )

$OKButton = [System.Windows.Forms.Button]::new()
$OKButton.Location = [System.Drawing.Size]::new(75, 120)
$OKButton.Size = [System.Drawing.Size]::new(75, 23)
$OKButton.Text = "OK"
$OKButton.Add_Click( { $TextBox.Text = $objTextBox.Text; $Form.Close() })
$Form.Controls.Add($OKButton)

$CancelButton = [System.Windows.Forms.Button]::new()
$CancelButton.Location = [System.Drawing.Size]::new(150, 120)
$CancelButton.Size = [System.Drawing.Size]::new(75, 23)
$CancelButton.Text = "Cancel"
$CancelButton.Add_Click( { $Form.Close() } )
$Form.Controls.Add($CancelButton)

$Label1 = [System.Windows.Forms.Label]::new()
$Label1.Location = [System.Drawing.Size]::new(10, 20)
$Label1.Size = [System.Drawing.Size]::new(280, 20)
$Label1.Text = "Please enter the information in the space below:"
$Form.Controls.Add($Label1)

$Form.Topmost = $True

$Form.Add_Shown( { $Form.Activate() })
[void]$Form.ShowDialog()

$TextBox2.Text
