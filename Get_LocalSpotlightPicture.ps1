#Gets 1920x1080 spotlight background pictures and copies them to a folder in the desktop 

cd ~\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets
$picturelist = New-Object System.Collections.Generic.List[string]
foreach($picture in (get-childitem)){ if($picture.length -gt 1000000) { $picturelist.add($picture.name) } }
foreach($s in $picturelist){$s}
$foldername = "Spotlight_Pictures_" + (Get-Date).tostring('MM-dd-yyyy')
mkdir ~\OneDrive\Desktop\Spotlight -ErrorAction SilentlyContinue
New-item -itemtype Directory -Path ~\OneDrive\Desktop\Spotlight -Name $foldername
$destinationDir = "~\OneDrive\Desktop\Spotlight\" + $foldername
foreach($item in $picturelist){$newName = $item + ".jpg"; Copy-Item .\$item -destination $destinationDir\$newName }
pause
