<#
 * Version: 1.0 2022-12-15 Initial Script
 * PowerShell script to compare current AWS workspaces against the AWS OU in AD and prompts to delete stale objects
 * from AD. See script comments for details.
 * 
 * Requires operator to have permissions in AWS to enumerate workspaces and AD permissions to remove computer objects.
 * 
 * Requires "AWSPowerShell", "AWSSSOHelper", "ActiveDirectory" Modules to be present on your system
 * Install-Module -Name AWSPowerShell, AWSSSOHelper, ActiveDirectory -Scope CurrentUser will accomplish that task
#>
# Load modules
$moduleNames = @("AWSPowerShell", "AWSSSOHelper", "ActiveDirectory")

# Import the modules
Import-Module -Name $moduleNames

# This line logs in to AWS Single Sign-On (SSO) and gets a session token. A browser window will be opened for the AWS login process if a credential does not exist.
Set-DefaultAWSRegion "us-east-1"
Get-AWSSSORoleCredential -Region "us-east-1" -StartUrl "https://<yoursite>.awsapps.com/start" -AccountID <YourAccount> -RoleName <YourRole> -UseStoredAwsCredentials

# This line sets the Active Directory organizational unit (OU) that will be checked for computer objects.
$ADOU = "OU=AWS,OU=COMPUTERS,DC=YOURSITE,DC=COM"

# This line gets a list of Amazon WorkSpaces from the AWS account.
$AWSWorkspaces = Get-WKSWorkspace

# This line gets a list of objects in the specified AD OU. Only computer objects are included in the list.
$ADObjects = Get-ADObject -SearchBase $ADOU -LDAPFilter '(objectClass=Computer)' | select -Expand Name

# This line initializes a counter variable to zero. The counter will be used to track the number of objects that are deleted.
$deletedCount = 0

# This loop iterates through the list of AD objects and checks if each object exists in the list of WorkSpaces.
foreach ($ADObject in $ADObjects) {
  # Check if the AD object exists in the list of workspaces
  $workspace = $AWSWorkspaces | Where-Object { $_.Name -eq $ADObject.Name }
  if (!$workspace) {
      # If an AD object is not found in the list of WorkSpaces, this line prompts the user to confirm whether they want to delete the object.
      $confirm = Read-Host "Are you sure you want to delete the object '$($ADObject.Name)'? [Y]es or [N]o"
      if ($confirm -eq "Y") {
          # If the user confirms that they want to delete the object, this line deletes the object from the AD OU.
          Remove-ADObject -Identity $ADObject.DistinguishedName
          # Increment counter
          $deletedCount++
      }
  }
}

# This line checks if the counter variable is still zero, which indicates that no objects were deleted.
if ($deletedCount -eq 0) {
  # If the counter is zero, this line prints a message to the user indicating that no objects needed to be deleted.
  Write-Host "No objects needed to be deleted."
}
