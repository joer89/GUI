<#
  .Description
    This is a little GUI script that retrieves all the profiles from the remote computer specified with parameters such as last logon time, creation time etc, and you can ping the target computer to see if it's active.
 .Example
    .\Find Remote Profiles.ps1
  .Notes
  Name  : Find Remote Profiles
  Author: Joe Richards
  .Link
  https://github.com/joer89/GUI/
#>

#Load the GUI Form.
function frmLoad {
    #Load System.Windows.Forms.
    [void][reflection.assembly]::loadwithpartialname("System.Windows.Forms") 
  
    #Set the form parameters.
    $frmMain = New-Object System.Windows.Forms.Form
    $frmMain.Text = "Find Remote Users"
    $frmMain.StartPosition = 1
    $frmMain.ClientSize = "490,340"

    #Set the label parameters.
    $lblCom = New-Object System.Windows.Forms.Label    
    $lblCom.Size = New-Object System.Drawing.Size(150,20) 
    $lblCom.Location = New-Object System.Drawing.Size(10,20) 
    $lblCom.Text = "Target computer name:"
    $frmMain.Controls.Add($lblCom) 

    #Set the listbox parameters.
    $txtRemoteCom = New-Object System.Windows.Forms.TextBox    
    $txtRemoteCom.Size = New-Object System.Drawing.Size(200,20) 
    $txtRemoteCom.Location = New-Object System.Drawing.Size(10,40) 
    $frmMain.Controls.Add($txtRemoteCom) 

    #Set the gridview paramters.
    $displayGridData = New-Object System.Windows.Forms.DataGrid 
    $displayGridData.Size = New-Object System.Drawing.Size (470,200)
    $displayGridData.Location = New-Object System.Drawing.Point(10,70)
    $displayGridData.DataBindings.DefaultDataSourceUpdateMode = 0
    $displayGridData.HeaderForeColor = [System.Drawing.Color]::FromArgb(255,0,0,0)
    $displayGridData.Name = "DisplayGridData"
    $displayGridData.DataMember = ""
    $displayGridData.TabIndex = 0
    $frmMain.Controls.Add($displayGridData)

    #Set the button parameters.
    $btnInvoke = New-Object System.Windows.Forms.Button
    $btnInvoke.Size = New-Object System.Drawing.Size(50,50) 
    $btnInvoke.Location = New-Object System.Drawing.Size(10,280)    
    $btnInvoke.Text = "Invoke" 
    $btnInvoke.Add_click($btnInvoke_click)
    $frmMain.Controls.Add($btnInvoke) 
    
    #Set the button parameters.
    $btnPing = New-Object System.Windows.Forms.Button
    $btnPing.Size = New-Object System.Drawing.Size(50,50) 
    $btnPing.Location = New-Object System.Drawing.Size(70,280)    
    $btnPing.Text = "Ping" 
    $btnPing.Add_click($btnPing_click)
    $frmMain.Controls.Add($btnPing)
    
    #Set the button parameters.
    $btnClose = New-Object System.Windows.Forms.Button
    $btnClose.Size = New-Object System.Drawing.Size(50,50) 
    $btnClose.Location = New-Object System.Drawing.Size(130,280)    
    $btnClose.Text = "Close" 
    $btnClose.Add_click($btnClose_click)
    $frmMain.Controls.Add($btnClose)
    
    #Set the label parameters.
    $lblProgress = New-Object System.Windows.Forms.Label
    $lblProgress.Size = New-Object System.Drawing.Size(430,20)
    $lblProgress.Location = New-Object System.Drawing.Size(190,310) 
    $lblProgress.Text = "Progress: User input."
    $frmMain.Controls.Add($lblProgress)    
    
    #Show the form.
    $frmMain.ShowDialog()
}

#On close button.
$btnClose_click = {
    #Close the form.
    $frmMain.Close()
}

#On invoke button.
$btnInvoke_click = {
    try{
        #Invoke the network computer name to retrieve profiles.
        retrieveProfileList
    }
    catch{
        #Display the current progress.
        $lblProgress.Text = "Problems connecting to " + $txtRemoteCom.Text + "."
    }
}

#On ping button.
$btnPing_click = {
    try{
         #Ping the computer name.
         pingComputerName
    }
    catch{
        #Display the current progress.
        $lblProgress.Text = "Problems pinging " + $txtRemoteCom.Text + "."
    }
}

#Retrieve the remote computer's profiles.
#Start function.
Function retrieveProfileList{
    #Display the current progress.
    $lblProgress.Text = "Progress: creating a session on computer " +$txtRemoteCom.Text+"."   
    #Create a sesion with the computer name.
    $session = New-PSSession -ComputerName $txtRemoteCom.Text    
    
    #Display the current progress.
    $lblProgress.Text = "Progress: Retrieving profiles from " + $txtRemoteCom.Text + "."
    #Invoke the computer and retrive the profile list with parameters.
    $result = Invoke-Command -Session $session -ScriptBlock {
        #Retrieves a list of profiles from C:\Users with the Name, Creation Time, Last access time and last write time.
        $profiles = (Get-ChildItem C:\Users | Select-Object BaseName, CreationTime, LastAccessTime, LastwriteTime )
        #Returns $profiles.
        return $profiles        
    }#End script block.
    
    #Display the current progress.
    $lblProgress.Text = "Progress: Removing session."
    #Removes the session.
    Remove-PSSession $session   
   
    #Creates an array.
    $list = New-Object System.collections.ArrayList
    #Adds the invoke result to the array.
    $list.AddRange($result)
   
    #Display the current progress.
    $lblProgress.Text = "Progress: Dislaying content..."
    #Display the result in a Gridview. 
    $displayGridData.DataSource = $list;

    #Display the current progress.
    $lblProgress.Text = "Progress: Finished."
}#End function.


 #Ping the computer name.
 #Start function
Function pingComputerName{
    #Display the current progress.
    $lblProgress.Text = "Progress: Pinging " + $txtRemoteCom.Text + "."   
    #Ping the computer name.
    $ping =  Test-Connection -ComputerName $txtRemoteCom.Text 
    
    if($ping){
        #Display the current progress.
        $lblProgress.Text = "Progress: Pinged " + $txtRemoteCom.Text + "."
     }
     else{
        #Display the current progress.
        $lblProgress.Text = "Progress: Failed to Ping " + $txtRemoteCom.Text + "."
     }
}#End function
        
#Loads the form.
frmLoad

