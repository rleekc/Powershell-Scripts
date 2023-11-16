#import list of computers
$computer = Import-Csv "H:\WindowsPowerShell\bigfix\Bigfixcomputers11-21-18.csv"
$checkRelayFile = "H:\WindowsPowerShell\bigfix\checkRelay.ps1"
$exportFile = "H:\WindowsPowerShell\bigfix\checkRelay3.csv"

#initialize count of succeeded and failed connections
$connection = 0
$failed = 0
$notinstalled = 0
$exist = 0
$regKeyCollected = 0
$propObj = @{prop=0;reg=0;numOfMatching=0;bootUp="N/A"}
$prop = new-object -typename PSObject -property $propObj
$tempConnection =0
#creating csv file
$export = "ComputerName,Connection,BESClientStatus,MatchingRelays,LastBootUpTime"
set-content -path $exportFile -value $export
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
			$prop = invoke-command -session $newsession -filepath $checkRelayFile -erroraction stop
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

    if($prop.prop -eq 1){
		write-host "BESClient not installed exception"
		$notinstalled++
	}elseif($prop.prop -eq 2){
		write-host "BESClient process not started exception"
        $exist++
	}
	if($prop.reg -eq 1){
		$regKeyCollected++
	}
	
#adding content to string for exporting of csv
	if($tempConnection -eq 1){
		$tempExport = $tempExport + ",True"
	}else{
		$tempExport = $tempExport + ",False"
	}

	if($prop.prop -eq 1){
		$tempExport = $tempExport + ",Not Installed"
	}elseif($prop.prop -eq 2){
		$tempExport = $tempExport + ",Not Started"
	}elseif($prop.prop -eq 3){
		$tempExport = $tempExport + ",Running"
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($tempConnection -eq 1){
		$tempExport = $tempExport + "," +$prop.numOfMatching
	}else{
		$tempExport = $tempExport + ",N/A"
	}
	
	if($tempConnection -eq 1){
		$tempExport = $tempExport + "," + $prop.bootUp
	}else{
		$tempExport = $tempExport + ",N/A"
	}
#reseting values	
	$prop.prop = 0
	$prop.reg =0
	$prop.numOfMatching =0
	$tempConnection =0
#adding content to csv
	add-content -path $exportFile -value $tempExport
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
Write-host "Connection failed on" $failed "computers"