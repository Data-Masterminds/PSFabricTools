Describe "Remove-PSFabricRecoveryPoint Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $CommandName = 'Remove-PSFabricRecoveryPoint'
            [array]$params = ([Management.Automation.CommandMetaData]$ExecutionContext.SessionState.InvokeCommand.GetCommand($CommandName, 'Function')).Parameters.Keys
            [object[]]$knownParameters = 'CreateTime','WorkspaceGUID','DataWarehouseGUID','BaseUrl'
            Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params | Should -BeNullOrEmpty
        }
    }
}
