The scenario for this script is to offboard in a hybrid on-premises setup. This powershell script is to be run on your domain controller where the user is located. On Active Directory Users & Computers, it removes their groups except 'Domain Users', disables the account and moves the user to an OU of your choosing.

You will need to rename the domain name and OU paths if you wish to move the location of the user.

The script utilises modules for removing licenses and permissions on Office 365 and Teams.

Towards the end, it connects to a dirsync server in order to run a Delta sync. You will need to rename -ComputerName path from 'az-dirsync' to the name of the your Dirsync computer. You will require appropriate access to this computer in order to complete this step.