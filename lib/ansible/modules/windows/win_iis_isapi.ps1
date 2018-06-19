#!powershell
# This file is part of Ansible

# Copyright 2018, Richard Ruben (richard.ruben@gmail.com)
#
# Ansible is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# Ansible is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with Ansible.  If not, see <http://www.gnu.org/licenses/>.

# WANT_JSON
# POWERSHELL_COMMON

$ErrorActionPreference = "Stop"

Set-StrictMode -Version 2.0

$params = Parse-Args -arguments $args -supports_check_mode $true

$check_mode = Get-AnsibleParam $params -name "_ansible_check_mode" -type "bool" -default $false
$state = Get-AnsibleParam $params "state" -default "present" -validateSet "present","absent"
$IsapiExtensionPath = Get-AnsibleParam $params -name "extensionpath" -type "str" -failifempty $true 
$allowed = Get-AnsibleParam $params -name "allowed" -type "bool" -default $true


$result = @{
    changed = $false
    state = $state
    allowed= $allowed
}

Test-Path -Path $IsapiExtensionPath


Try {

    If (-not (Test-Path $IsapiExtensionPath)) {
        Fail-Json @{} "specified folder must already exist: extensionpath"
    }

    $IsapiConfig = get-webconfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='$IsapiExtensionPath']/@allowed" -WarningAction SilentlyContinue -WarningVariable warningvar
    if(-not $IsapiConfig -and ($state -eq "present"))
    {     
        Add-WebConfiguration -pspath 'MACHINE/WEBROOT/APPHOST' -filter 'system.webServer/security/isapiCgiRestriction' -WhatIf:$check_mode -value @{
            description = 'Contec WS'
            path        = $IsapiExtensionPath
            allowed     = $allowed
        }

        Set-WebConfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='$IsapiExtensionPath']/@allowed" -WhatIf:$check_mode -value $allowed -PSPath:IIS:\

        $result.changed = $true  
    }
    else
    {
        if($state -eq "present")
        {
            if ($IsapiConfig.value -ne $allowed)
            {
                Set-WebConfiguration "/system.webServer/security/isapiCgiRestriction/add[@path='$IsapiExtensionPath']/@allowed" -WhatIf:$check_mode -value $allowed -PSPath:IIS:\        
                $result.changed = $true
            }
        }
        else
        {
            Clear-WebConfiguration -Filter "/system.webServer/security/isapiCgiRestriction/add[@path='$IsapiExtensionPath']" -WhatIf:$check_mode -PSPath: "MACHINE/WEBROOT/APPHOST"
        }
    }
} Catch {
    Fail-Json $result "an error occurred when attempting to change ISAPI CGI Restrictions,  ($_.Exception.Message)"
}

Exit-Json $result

      