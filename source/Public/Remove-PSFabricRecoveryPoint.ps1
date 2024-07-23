<#
.SYNOPSIS
Remove a selected Fabric Recovery Point.

.DESCRIPTION
Remove a selected Fabric Recovery Point.

.PARAMETER CreateTime
The specific unique time of the restore point to remove. Get this from Get-PSFabricRecoveryPoint.

.PARAMETER BaseUrl
Defaults to api.powerbi.com

.PARAMETER WorkspaceGUID
This is the workspace GUID in which the data warehouse resides.

.PARAMETER DataWarehouseGUID
The GUID for the data warehouse which we want to retrieve restore points for.

.EXAMPLE
#TODO: better examples
$restorePoint = Get-PSF...
Remove-PSFabricRecoveryPoint - CreateTime $restorePoint

.NOTES
General notes
#>
function Remove-PSFabricRecoveryPoint {
    [CmdletBinding(SupportsShouldProcess)]
    param (
        [string]$CreateTime,

        [String]$WorkspaceGUID,

        [String]$DataWarehouseGUID,

        [String]$BaseUrl = 'api.powerbi.com'

        #TODO - implement piping from get? or a way of interactively choosing points to remove
        )


    #region handle the config parameters
    if($WorkspaceGUID) {
        Set-PSFabricConfig -WorkspaceGUID $WorkspaceGUID
    } else {
        $WorkspaceGUID = Get-PSFConfigValue -FullName PSFabricTools.WorkspaceGUID
    }

    if($DataWarehouseGUID) {
        Set-PSFabricConfig -DataWarehouseGUID $DataWarehouseGUID
    } else {
        $DataWarehouseGUID = Get-PSFConfigValue -FullName PSFabricTools.DataWarehouseGUID
    }

    if($BaseUrl) {
        Set-PSFabricConfig -BaseUrl $BaseUrl
    } else {
        $BaseUrl = Get-PSFConfigValue -FullName PSFabricTools.BaseUrl
    }

    if (-not $WorkspaceGUID -or -not $DataWarehouseGUID -or -not $BaseUrl) {
        Stop-PSFFunction -Message 'WorkspaceGUID, DataWarehouseGUID, and BaseUrl are required parameters. Either set them with Set-PSFabricConfig or pass them in as parameter values' -EnableException $true
    } else {
        Write-PSFMessage -Level Verbose -Message ('WorkspaceGUID: {0}; DataWarehouseGUID: {1}; BaseUrl: {2}' -f $WorkspaceGUID, $DataWarehouseGUID, $BaseUrl)
    }
    #endregion


    if ($PSCmdlet.ShouldProcess("Remove recovery point for a Fabric Data Warehouse")) {
        #region setting up the API call
        try {
            # Get token and setup the uri
            $getUriParam = @{
                BaseUrl = $BaseUrl
                WorkspaceGUID = $WorkspaceGUID
                DataWarehouseGUID = $DataWarehouseGUID
            }
            $iwr = Get-PSFabricUri @getUriParam
        } catch {
            Stop-PSFFunction -Message 'Failed to get Fabric URI - check authentication and parameters.' -ErrorRecord $_ -EnableException $true
        }
        #endregion

        #region call the API
        if (-not $iwr) {
            Stop-PSFFunction -Message 'No URI received from API - check authentication and parameters.' -ErrorRecord $_ -EnableException $true
        } else {

            # for the API this needs to be an array, even if it's just one item
            [string[]]$CreateTimeObj = $CreateTime

            #region check restore point exists
            #Get the restore point to make sure it exists - the fabric API doesn't really confirm we deleted anything so we will manually check
            $getSplat = @{
                WorkspaceGUID = $WorkspaceGUID
                DataWarehouseGUID = $DataWarehouseGUID
                BaseUrl = $BaseUrl
                CreateTime = $CreateTimeObj
            }

            try {
                if(Get-PSFabricRecoveryPoint @getSplat) {
                    Write-PSFMessage -Level Verbose -Message ('WorkspaceGUID: {0}; DataWarehouseGUID: {1}; BaseUrl: {2}; CreateTime: {3} - restore point exists' -f $WorkspaceGUID, $DataWarehouseGUID, $BaseUrl, $CreateTime)
                } else {
                    Stop-PSFFunction -Message ('WorkspaceGUID: {0}; DataWarehouseGUID: {1}; BaseUrl: {2}; CreateTime: {3} - restore point not found!' -f $WorkspaceGUID, $DataWarehouseGUID, $BaseUrl, $CreateTime) -ErrorRecord $_ -EnableException $true
                }
            } catch {
                Stop-PSFFunction -Message 'Issue calling Get-PSFabricRecoveryPoint to check restore point exists before removal' -ErrorRecord $_ -EnableException $true
            }
            #endregion

            #region remove the restore point
            $command = [PSCustomObject]@{
                commands = @([ordered]@{
                    '$type' = 'WarehouseDeleteRestorePointsCommand'
                    'RestorePointsToDelete' = $CreateTimeObj
                })
            }

            try {
                # add the body and invoke
                $iwr.Add('Body', ($command | ConvertTo-Json -Compress -Depth 3))
                $content = Invoke-WebRequest @iwr

                if($content) {
                    # change output to be a PowerShell object and view new restore point
                    #TODO: output - select default view but return more?
                    $results = ($content.Content | ConvertFrom-Json)
                } else {
                    Stop-PSFFunction -Message 'No Content received from API - check authentication and parameters.' -ErrorRecord $_ -EnableException $true
                }
            } catch {
                Stop-PSFFunction -Message 'Issue calling Invoke-WebRequest' -ErrorRecord $_ -EnableException $true
            }
            #endregion

            #region check restore point exists
            try {
                #Get the restore point to make sure it exists - the fabric API doesn't really confirm we deleted anything so we will manually check
                if(Get-PSFabricRecoveryPoint @getSplat) {
                    Stop-PSFFunction -Message ('WorkspaceGUID: {0}; DataWarehouseGUID: {1}; BaseUrl: {2}; CreateTime: {3} - restore point not was not successfully removed!' -f $WorkspaceGUID, $DataWarehouseGUID, $BaseUrl, $CreateTime) -ErrorRecord $_ -EnableException $true
                } else {
                    Write-PSFMessage -Level Output -Message ('WorkspaceGUID: {0}; DataWarehouseGUID: {1}; BaseUrl: {2}; CreateTime: {3} - restore point successfully removed' -f $WorkspaceGUID, $DataWarehouseGUID, $BaseUrl, $CreateTime)
                    $results
                }
            } catch {
                Stop-PSFFunction -Message 'Issue calling Get-PSFabricRecoveryPoint to check restore point exists before removal' -ErrorRecord $_ -EnableException $true
            }
            #endregion
        }
        #endregion
    }
}