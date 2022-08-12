cd ~\AppData\Local\Packages\Microsoft.Windows.ContentDeliveryManager_cw5n1h2txyewy\LocalState\Assets
$picturelist = New-Object System.Collections.Generic.List[string]
foreach($picture in (get-childitem)){ if($picture.length -gt 1000000) { $picturelist.add($picture.name) } }
foreach($s in $picturelist){$s}
$foldername = "Spotlight_Pictures_" + (Get-Date).tostring('MM-dd-yyyy')
New-item -itemtype Directory -Path ~\OneDrive\Desktop -Name $foldername
$destinationDir = "~\OneDrive\Desktop\" + $foldername
foreach($item in $picturelist){$newName = $item + ".jpg"; Copy-Item .\$item -destination $destinationDir\$newName }
$image = new-object -ComObject Wia.ImageFile
cd $destinationDir
foreach($item in (get-childitem)) {$fullPath = $destinationDir + $item; $image.loadfile("$fullPath"); if($image.Height -ne 1080 -and $image.Width -ne 1920) {Remove-Item $item}}