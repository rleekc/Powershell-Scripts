# This script adds a bitlocker pin to boot the computer
# Creates a pin of "123890" for bitlocker
$SecureString = ConvertTo-SecureString "123890" -AsPlainText -Force
Add-BitLockerKeyProtector -MountPoint "C:" -Pin $SecureString -TPMandPinProtector
# Shutdown computer
start-sleep 10
stop-computer -force
