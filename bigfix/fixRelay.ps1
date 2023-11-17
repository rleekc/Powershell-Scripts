#function that receives the booleans for matching relays, stops besclient, changes relays, starts besclient, 
#returns 1 no changes needed, 2 changed and besclient started, 3 changed besclient not started
function fix-Bigfix {
	param($firstProBool, $secondProBool, $thirdProBool, $fourthProBool)
	$fix =0
	$firstValue = "http://UCSFBIGFIX.campus.net.ucsf.edu:52311/cgi-bin/bfgather.exe/actionsite"
	$secondValue = "0"
	$thirdValue = "http://vchobfout1.core.in.cho.org:52311/bfmirror/downloads/"
	$fourthValue = "http://vCHOBFMainRela1.core.in.cho.org:52311/bfmirror/downloads/"
	if($firstProBool -and $secondProBool -and $thirdProBool -and $fourthProBool){
        write-host "No Changes Needed... "
		$fix=1
		$tempCheck = check-Bigfix -bool check-Installed
		if($tempCheck -eq 2){
			Start-Service -name "besclient"
		}
    }
#change registry keys for values that are incorrect
    else{

#stop besclient service
        write-host "Stopping BESClient"
        Stop-Service -name "besclient"
        write-host "BESClient is Stopped"
#make registry key changes if necessary
        $stringReturn = "Changes were made on "
        if(!$firstProBool){
			Set-ItemProperty -path "HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__Relay_Control_RootServer" -name "value" -value $firstValue
            $stringReturn = $stringReturn + "UCSF Link "
			$firstPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__Relay_Control_RootServer;
			write-host "UCSF link is now" $firstPro.value
        }
        if(!$secondProBool){
			Set-ItemProperty -path "HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelaySelect_Automatic" -name "value" -value $secondValue
            $stringReturn = $stringReturn + "Automatic "
			$secondPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelaySelect_Automatic;
			write-host "Automatic is now" $secondPro.value
        }
        if(!$thirdProBool){
			Set-ItemProperty -path "HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer2" -name "value" -value $thirdValue
            $stringReturn = $stringReturn + "RelayServer2 "
			$thirdPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer2;
			write-host "RelayServer2 is now" $thirdPro.value
        }
        if(!$fourthProBool){
			Set-ItemProperty -path "HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer1" -name "value" -value $fourthValue
            $stringReturn = $stringReturn + "RelayServer1 "
			$fourthPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer1;
			write-host "RelayServer1 is now" $fourthPro.value
        }
        Write-host $stringReturn
#start besclient service
        write-host "Starting BESClient"
        Start-Service -name "besclient"
#test to see if besclient is started
		try{
			$bes = get-process -name "besclient" -erroraction stop
			write-host "BESClient is started"
			$fix=2
		}
		catch{
			write-host "***BESClient is not started***"
			$fix=3
		}
	}
	
	return $fix
}


#function to check the bools again, returns the hashtable of counts and boolean of matching relays
function check-Bool {
#check and compare registry keys
    $firstPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__Relay_Control_RootServer;

    $firstValue = "http://UCSFBIGFIX.campus.net.ucsf.edu:52311/cgi-bin/bfgather.exe/actionsite"

    $firstProBool = $firstPro.value -eq "http://UCSFBIGFIX.campus.net.ucsf.edu:52311/cgi-bin/bfgather.exe/actionsite"

    $secondPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelaySelect_Automatic;

    $secondValue = "0"

    $secondProBool = $secondPro.value -eq "0"

    $thirdPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer2;

    $thirdValue = "http://vchobfout1.core.in.cho.org:52311/bfmirror/downloads/"

    $thirdProBool = $thirdPro.value -eq "http://vchobfout1.core.in.cho.org:52311/bfmirror/downloads/"

    $fourthPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer1;

    $fourthValue = "http://vCHOBFMainRela1.core.in.cho.org:52311/bfmirror/downloads/"

    $fourthProBool = $fourthPro.value -eq "http://vCHOBFMainRela1.core.in.cho.org:52311/bfmirror/downloads/"
	
	write-host "UCSF link is"  $firstPro.value "Match?" $firstProBool

    write-host "Automatic is"  $secondPro.value "Match?" $secondProBool

    write-host "RelayServer2 is"  $thirdPro.value "Match?" $thirdProBool

    write-host "RelayServer1 is"  $fourthPro.value "Match?" $fourthProBool	
	
	$loop = @($firstProBool,$secondProBool,$thirdProBool,$fourthProBool)
	$count =0
	foreach($Bool in $loop){
		if($Bool){
			$count++
		}
	}
	
	return @{count=$count;reg=1;first=$firstProBool;second=$secondProBool;third=$thirdProBool;fourth=$fourthProBool}

}


#function that receives the booleans for matching relays, stops besclient, changes relays, starts besclient, returns 1 for changed and 2 no changed
function check-Bigfix {
	param($bool)
	$return =0
	if(!$bool){
	
	write-host "BESClient is not installed"
    
	$return =1
	}
	else{
		write-host "BESClient is installed"
	#check if BESClient process is started
		try{
			$bes = get-process -name "besclient" -erroraction stop
			write-host "BESClient is running"
			$return =3
		}
		catch{
			write-host "BESClient is not started"
			$return =2
			
		}
	}
	return $return

}


#function to check if bigfix is installed and returns the boolean
function check-Installed {

	$installed = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName
	$match = $installed -match "IBM BigFix Client"
	
	return $match;

}


################################################################################################


#gather computer information
$hostname = hostname

try{
	$info = Get-CimInstance -ClassName win32_operatingsystem -erroraction stop
	write-host "Hostname is" $hostname "CIM name is" $info.CSName
	write-host "Last boot time of the computer is " $info.LastBootUpTime
	$BootUpTime = $info.LastBootUpTime
}
catch{
	write-host "CIM instance was not captured"
	write-host "Hostname is" $hostname
	$BootUpTime = "Unable to Gather Time"
}

#initialize return values
$prop = @{prop1=0;reg1=0;numOfMatching1=0;bootUp=$BootUpTime;fix=0;numOfMatching2=0;prop2=0;reg2=0}

#check if bigfix is installed, started, running, returns 1 for not installed, 2 for not started, 3 for running

$prop.prop1= check-Bigfix -bool check-Installed

#get reg values and compare. write host if the value of relays are true or false, returns number of matching relays
$firstCount = check-Bool

$prop.reg1 = $firstCount.reg
$prop.numOfMatching1 = $firstCount.count

$theFix = fix-Bigfix -firstProBool $firstCount.first -secondProBool $firstCount.second -thirdProBool $firstCount.third -fourthProBool $firstCount.fourth

$prop.fix = $theFix	

$secondCount = check-Bool

$prop.reg2 = $secondCount.reg
$prop.prop2 = check-Bigfix -bool check-Installed
$prop.numOfMatching2= $secondCount.count

#return object
new-object -typename PSObject -property $prop
	
#####################################################################

