Describe "Get-PSFabricRecoveryPoint Unit Tests" -Tag 'UnitTests' {
    Context "Validate parameters" {
        It "Should only contain our specific parameters" {
            $CommandName = 'Get-PSFabricRecoveryPoint'
            [array]$params = ([Management.Automation.CommandMetaData]$ExecutionContext.SessionState.InvokeCommand.GetCommand($CommandName, 'Function')).Parameters.Keys
            [object[]]$knownParameters = 'WorkspaceGUID','DataWarehouseGUID','BaseUrl','Since','Type','CreateTime'
            Compare-Object -ReferenceObject $knownParameters -DifferenceObject $params | Should -BeNullOrEmpty
        }
    }
}
