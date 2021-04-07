
##########################################################
## Install Directory Services role on onprem server
##
## Kudos to Chris Walden for this article https://cloudblogs.microsoft.com/industry-blog/en-gb/technetuk/2016/06/08/setting-up-active-directory-via-powershell/
##########################################################

resource "azurerm_virtual_machine_extension" "install-ds-onprem-dc" {

  # Conditionally based on feature flag
  count = local.feature_flags.provision_domaincontroller == true ? 1 : 0

  name                 = "install-dns-onprem-dc"
  virtual_machine_id   = azurerm_virtual_machine.onprem-dns-vm.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.9"

  settings = <<SETTINGS
        install-windowsfeature AD-Domain-Services
        Import-Module ADDSDeployment
        Install-ADDSForest -CreateDnsDelegation:$false -DatabasePath "C:\Windows\NTDS" -DomainMode "WinThreshold" -DomainName "onprem.org" -DomainNetbiosName "ONPREM" -ForestMode "WinThreshold" -InstallDns:$true -LogPath "C:\Windows\NTDS" -NoRebootOnCompletion:$false -SysvolPath "C:\Windows\SYSVOL" -Force:$true
        exit 0"
SETTINGS
  interpreter = ["PowerShell", "-ExecutionPolicy Unrestricted -Command"]
}

