# PSFabricTools

PowerShell module to simplify working with Fabric APIs

## How to Use

This module currently focuses just on Fabric recovery points - but more could be added in the future.

When you start using this module you'll need a token to authenticate - we make use of the Microsoft PowerShell module `MicrosoftPowerBIMgmt.Profile` for the authentication. You'll need to call `Connect-PowerBIServiceAccount` to be able to use this module.

You will also need to know your `WorkspaceGUID` and `DataWarehouseGUID` which you can get from the url when you are connected to the data warehouse.

![View of the data warehouse showing where the WorkspaceGUID and DataWarehouseGUID can be found](https://github.com/user-attachments/assets/5ebf853e-0bcf-4694-96df-4323101210f5)

These parameters can either be passed into each command or you can use the `Set-PSFabricConfig` command to save those to the registry so all commands going forward will use these. If you want to save them just for the session then use the `-SkipPersist` parameter.

```PowerShell
Set-PSFabricConfig -WorkspaceGUID 'GUID-GUID-GUID-GUID' -DataWarehouseGUID 'GUID-GUID-GUID-GUID'
```

### List Recovery Points

To list current recovery points you can use several parameters to filter them down, but if you want to view all:

```PowerShell
Get-PSFabricRecoveryPoint

# If you haven't set the config you can pass in those parameters at run time:
Get-PSFabricRecoveryPoint -WorkspaceGUID 'guid-guid-guid-guid' -DataWarehouseGUID 'guid-guid-guid-guid'
```

You can filter to see recovery points after a certain time, the times on these points are UTC, so take that into consideration.

```PowerShell
Get-PSFabricRecoveryPoint -Since (get-date).AddHours(-2)
```

You can also filter by the type of recovery point, either 'automatic' or 'userDefined'

```PowerShell
Get-PSFabricRecoveryPoint -Type userDefined
```

Finally you can pass in a specific recovery point to select.

```PowerShell
Get-PSFabricRecoveryPoint -CreateTime '2024-07-23T09:42:36Z'
```

You can also combine these parameters to filter multiple conditions at once.

### Create a recovery point

When you want to create a user defined recovery point you can use the following with no parameters if you've already setup your config.

```PowerShell
New-PSFabricRecoveryPoint

# Or if you want to pass in the parameters you can
New-PSFabricRecoveryPoint -WorkspaceGUID 'guid-guid-guid-guid' -DataWarehouseGUID 'guid-guid-guid-guid'
```

### Remove a recovery point

If you want to remove a recovery point you can do that by specifying the exact `CreateTime`, the format of this needs to be exact as this is used as the key. You can get the `CreateTime` from the output of either the `Get-*` or `New-*` commands.

This command will check that the recovery point exists before deleting it, it'll also double check it's been removed before returning successfully. At the time of writing this the Fabric API doesn't return any information on whether the recovery point was found or successfully deleted so we've added some extra checks.

```PowerShell
Remove-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:20:26Z'
```

### Recover to a recovery point

Finally we can recovery our Fabric Data Warehouse to a specific recovery point with the following

```PowerShell
Restore-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:04:03Z'

# If you want to see the progress and when the restore completes you can add the `-Wait` parameter and the command will check the API endpoint for progress until it is complete.
Restore-PSFabricRecoveryPoint -CreateTime '2024-07-23T11:04:03Z'  -Wait
```

There is comment based help for all the functions so it's worth checking out the parameters and examples there as well as you start to use the module.
