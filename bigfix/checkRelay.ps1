#check if BESClient is installed
$hostname = hostname

try{
	$info = Get-CimInstance -ClassName win32_operatingsystem -erroraction stop
	$installed = Get-ItemProperty HKLM:\Software\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall\* | Select-Object DisplayName
	$match = $installed -match "IBM BigFix Client"
	write-host "Hostname is" $hostname "CIM name is" $info.CSName
	write-host "Last boot time of the computer is " $info.LastBootUpTime
	$BootUpTime = $info.LastBootUpTime
}
catch{
	write-host "CIM instance was not captured"
	write-host "Hostname is" $hostname
	$BootUpTime = "Unable to Gather Time"
}


$prop = @{prop=0;reg=0;numOfMatching=0;bootUp=$BootUpTime}
if(!$match){
	
	write-host "BESClient is not installed"
    
	$prop.prop =1;
}
else{
	write-host "BESClient is installed"
#check if BESClient process is started
	try{
		$bes = get-process -name "besclient" -erroraction stop
		write-host "BESClient is running"
		$prop.prop =3
	}
	catch{
		write-host "BESClient is not started"
		$prop.prop =2
		
	}
	
#get reg values and compare
    $firstPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__Relay_Control_RootServer;

    $firstProBool = $firstPro.value -eq "http://UCSFBIGFIX.campus.net.ucsf.edu:52311/cgi-bin/bfgather.exe/actionsite"

    $secondPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelaySelect_Automatic;

    $secondProBool = $secondPro.value -eq "0"

    $thirdPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer2;

    $thirdProBool = $thirdPro.value -eq "http://vchobfout1.core.in.cho.org:52311/bfmirror/downloads/"

    $fourthPro = Get-itemproperty HKLM:\SOFTWARE\WOW6432Node\BigFix\EnterpriseClient\Settings\Client\__RelayServer1;

    $fourthProBool = $fourthPro.value -eq "http://vCHOBFMainRela1.core.in.cho.org:52311/bfmirror/downloads/"

#write host if the value of relays are true or false


    write-host "UCSF link is"  $firstPro.value "Match?" $firstProBool

    write-host "Automatic is"  $secondPro.value "Match?" $secondProBool

    write-host "RelayServer2 is"  $thirdPro.value "Match?" $thirdProBool

    write-host "RelayServer1 is"  $fourthPro.value "Match?" $fourthProBool	
	$prop.reg = 1
	$loop = @($firstProBool,$secondProBool,$thirdProBool,$fourthProBool)
	$count =0
	foreach($Bool in $loop){
		if($Bool){
			$count++
		}
	}
	$prop.numOfMatching = $count
}
#return object
new-object -typename PSObject -property $prop
