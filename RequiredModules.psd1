@{
    PSDependOptions             = @{
        AddToPath  = $true
        Target     = 'output\RequiredModules'
        Parameters = @{
            Repository = 'PSGallery'
        }
    }

    InvokeBuild                    = 'latest'
    PSScriptAnalyzer               = 'latest'
    Pester                         = 'latest'
    Plaster                        = 'latest'
    ModuleBuilder                  = 'latest'
    ChangelogManagement            = 'latest'
    Sampler                        = 'latest'
    'MicrosoftPowerBIMgmt.Profile' = 'latest'
    'Sampler.GitHubTasks'          = 'latest'
    PowerShellForGitHub            = 'latest'
    PSFramework                    = 'latest'

}

