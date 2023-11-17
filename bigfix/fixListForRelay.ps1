#import list of computers
#$computer = Import-Csv "H:\WindowsPowerShell\bigfix\Bigfixcomputers11-21-18.csv"
$computer = Import-Csv "H:\WindowsPowerShell\bigfix\testcomputers.csv"
$exportCSV = "H:\WindowsPowerShell\bigfix\fixRelay.csv"
$fixRelayFile = "H:\WindowsPowerShell\bigfix\fixRelay.ps1"

#initialize count of succeeded and failed connections
$connection = 0
$failed = 0
$notinstalled = 0
$exist = 0
$regKeyCollected = 0
$fixOccurred = 0
$processAfter=0
$propObj = @{prop1=0;reg1=0;numOfMatching1=0;bootUp="N/A";fix=0;prop2=0;reg2=0;numOfMatching2=0}
$prop = new-object -typename PSObject -property $propObj
$tempConnection =0
#creating csv file
$export = "ComputerName,Connection,BESClientStatus,MatchingRelays,LastBootUpTime,FixApplied,MatchingRelaysAfterFix,BESClientStatusAfterFix"
set-content -path $exportCSV -value $export
#iterate through each computer
foreach($comp in $computer){
    $comp1 = $comp.ComputerName
    $tempExport = $comp1
    write-host " "
	write-host $comp1
#invoke script on computer    
    try{
        $pssession = new-pssessionoption -opentimeout 60 -canceltimeout 60
		$newsession = new-pssession $comp1 -sessionoption $pssession -erroraction stop 
		try {
			$prop = invoke-command -session $newsession -filepath $fixRelayFile -erroraction stop
		}
		catch{
			write-host "invoking error occurred"
		}
		
		if($newsession -ne "Closed"){
			$connection++
			$tempConnection =1
		}	
    }
	catch{
		write-host "Connection Error:" $comp1     
		$failed++
	}
#count number of actions that occurred
    if($prop.prop1 -eq 1){
		write-host "BESClient not installed exception"
		$notinstalled++
	}elseif($prop.prop1 -eq 2){
		write-host "BESClient process not started exception"
        $exist++
	}
	if($prop.reg1 -eq 1){
		$regKeyCollected++
	}
	
	if($prop.fix -eq 2 -or $prop.fix -eq 3){
		$fixOccurred++
	}
	if($prop.prop2 -eq 2){
		write-host "BESClient process not started after fix"
        $processAfter++
	}
	
#adding content to string for exporting of csv
	if($tempConnection -eq 1){
		$tempExport = $tempExport + ",True"
	}else{
		$tempExport = $tempExport + ",False"
	}

	if($prop.prop1 -eq 1){
		$tempExport = $tempExport + ",Not Installed"
	}elseif($prop.prop1 -eq 2){
		$tempExport = $tempExport + ",Not Started"
	}elseif($prop.prop1 -eq 3){
		$tempExport = $tempExport + ",Running"
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($tempConnection -eq 1){
		$tempExport = $tempExport + "," +$prop.numOfMatching1
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($tempConnection -eq 1){
		$tempExport = $tempExport + "," + $prop.bootUp
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($prop.fix -eq 1){
		$tempExport = $tempExport + ",No Changes Needed"
	}elseif($prop.prop1 -eq 2){
		$tempExport = $tempExport + ",Relays Changed Process Not Started"
	}elseif($prop.prop1 -eq 3){
		$tempExport = $tempExport + ",Relays Changed"
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($tempConnection -eq 1){
		$tempExport = $tempExport + "," +$prop.numOfMatching2
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($prop.prop2 -eq 1){
		$tempExport = $tempExport + ",Not Installed"
	}elseif($prop.prop2 -eq 2){
		$tempExport = $tempExport + ",Not Started"
	}elseif($prop.prop2 -eq 3){
		$tempExport = $tempExport + ",Running"
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	
	
	
#reseting values	
	$prop.prop1 = 0
	$prop.reg1 =0
	$prop.numOfMatching1 =0
	$prop.prop2 = 0
	$prop.reg2 =0
	$prop.numOfMatching2 =0
	$prop.fix =0;
	$tempConnection =0
#adding content to csv
	add-content -path $exportCSV -value $tempExport
	$tempExport =""
	try{
		remove-pssession $newsession
    }catch{
	}
}
#print results of the script
write-host " "
Write-host "Connection succeeded on" $connection "computers"
write-host "Registry key collected on" $regKeyCollected "computers"
write-host "BESClient is not installed on" $notinstalled "computers"
write-host "BESClient is not started on" $exist "computers"
write-host "Relays changed on" $fixOccurred "computers"
write-host "BESClient not running after fix are" $processAfter "computers"
Write-host "Connection failed on" $failed "computers"
