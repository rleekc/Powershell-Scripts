<#
    Script to change access control list of folder to:
    Owner: "AJLDOMAIN\File Server Admins"
    Access: 
        IdentityReference: "NT AUTHORITY\SYSTEM" 
        FileSystemRights: "Full Control"
        AccessControlType: "Allow"

        IdentityReference: "AJLDOMAIN\raymond.lee" 
        FileSystemRights: "ReadAndExecute, Synchronize"
        AccessControlType: "Allow"

        IdentityReference: "AJLDOMAIN\File Server Admins" 
        FileSystemRights: "Full Control"
        AccessControlType: "Allow"

        IdentityReference: "AJLDOMAIN\File Server Support" 
        FileSystemRights: "Modify, Synchronize"
        AccessControlType: "Allow"
		
	Usage: .\change-aclmigration.ps1 -folder path -user user
#>

param (
    [Parameter(Mandatory=$true)]
    [string]$folder,

    [Parameter(Mandatory=$true)]
    [string]$user

)
if (test-path $folder) {
	write-host "Changing access for $folder and $user"
	$NewAcl = new-object System.Security.AccessControl.DirectorySecurity

	$isProtected = $true
	$preserveInheritance = $false
	$NewAcl.SetAccessRuleProtection($isProtected, $preserveInheritance)

	$owner = New-Object System.Security.Principal.NTAccount("AJLDOMAIN\File Server Admins")
	$NewAcl.setOwner($owner)


	$systemIdentity = "NT AUTHORITY\SYSTEM"
	$fileServerAdmins = "AJLDOMAIN\File Server Admins"
	$fileServerSupport = "AJLDOMAIN\File Server Support"
	$fullControl = "FullControl"
	$allow = "Allow"
	$modify = "Modify, Synchronize"
	$read = "ReadAndExecute, Synchronize"
	$endUser = "AJLDOMAIN\$user"

	$systemArgumentList1 = $systemIdentity, $fullControl, "ContainerInherit,ObjectInherit", "None", $allow
	$fileSystemAccessRule1 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $systemArgumentList1
	$NewAcl.SetAccessRule($fileSystemAccessRule1)

	$systemArgumentList2 = $fileServerAdmins, $fullControl, "ContainerInherit,ObjectInherit", "None", $allow
	$fileSystemAccessRule2 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $systemArgumentList2
	$NewAcl.SetAccessRule($fileSystemAccessRule2)

	$systemArgumentList3 = $fileServerSupport, $modify, "ContainerInherit,ObjectInherit", "None", $allow
	$fileSystemAccessRule3 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $systemArgumentList3
	$NewAcl.SetAccessRule($fileSystemAccessRule3)

	$systemArgumentList4 = $endUser, $read, "ContainerInherit,ObjectInherit", "None", $allow
	$fileSystemAccessRule4 = New-Object -TypeName System.Security.AccessControl.FileSystemAccessRule -ArgumentList $systemArgumentList4
	$NewAcl.SetAccessRule($fileSystemAccessRule4)


	Set-Acl -path $folder -AclObject $NewACL


	# Change owner for child items
	# Get a list of folders and files
	$ItemList = Get-ChildItem -Path $folder -Recurse;
	$Acl = Get-Acl -Path $folder; # Get the ACL from the item
	$Acl.SetOwner($owner); # Update the in-memory ACL
	# Iterate over files/folders
	foreach ($Item in $ItemList) {
		Set-Acl -Path $Item.FullName -AclObject $Acl;  # Set the updated ACL on the target item
	}
	Write-Host "Complete"
}
else {
	Write-Host "`n$folder does not exist `n$folder"
}