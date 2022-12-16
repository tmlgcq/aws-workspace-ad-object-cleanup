# aws-workspace-ad-object-cleanup
PowerShell script to compare current AWS workspace inventory against the AWS OU in AD and prompts to delete stale objects from AD
Requires operator to have permissions in AWS to enumerate workspaces and AD permissions to remove computer objects.
 
Requires "AWSPowerShell", "AWSSSOHelper", "ActiveDirectory" Modules to be present on your system
Install-Module -Name AWSPowerShell, AWSSSOHelper, ActiveDirectory -Scope CurrentUser will accomplish that task
