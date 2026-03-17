function Invoke-LCWMermaidGenerator {
    [CmdletBinding()]
    param (
        [string] $ReportPath = 'LifecycleWorkflowsReport.md',
        [switch] $AzureDevOps
    )

    process {
        $context = Get-MgContext

        if(!$context) {
            Write-Error "Please connect to Microsoft Graph using Connect-MgGraph before invoking this command: Connect-MgGraph -Scopes 'LifecycleWorkflows.Read.All'"
        }

        if(
            !(
                $context.scopes -contains "lifecycleworkflows.read.all" -or 
                $context.scopes -contains "lifecycleworkflows.readwrite.all"
            )
        ) {
            Write-Warning "Current context does not have required permissions to read lifecycle workflows. Please connect with a context that has either 'LifecycleWorkflows.Read.All' or 'LifecycleWorkflows.ReadWrite.All' permissions."
        }

        $workflows = Get-MgIdentityGovernanceLifecycleWorkflow -All

        if(!$workflows) {
            Write-Warning "No lifecycle workflows found in the tenant."
            return
        }
        
        $taskDefinitions = Get-MgIdentityGovernanceLifecycleWorkflowTaskDefinition -All | Group-Object -AsHashTable -Property Id
        $customTaskExtensions = Get-MgIdentityGovernanceLifecycleWorkflowCustomTaskExtension -All | Group-Object -AsHashTable -Property Id

        $workflowRecords = @(
            $workflows | ForEach-Object {
                Get-WorkflowRecord -Workflow $_ -TaskDefinitions $taskDefinitions -CustomTaskExtensions $customTaskExtensions
            }
        )

        foreach ($workflowRecord in $workflowRecords) {
            Write-Host (ConvertTo-WorkflowConsoleText -WorkflowRecord $workflowRecord)
        }

        $reportSections = [System.Collections.Generic.List[string]]::new()
        $reportSections.Add('# Lifecycle Workflows Report')
        $reportSections.Add('')
        $reportSections.Add("Generated: $(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')")
        $reportSections.Add('')

        foreach ($workflowRecord in $workflowRecords) {
            $reportSections.Add((ConvertTo-WorkflowMarkdown -WorkflowRecord $workflowRecord -AzureDevOps:$AzureDevOps))
        }

        $reportContent = $reportSections -join [Environment]::NewLine
        Set-Content -Path $ReportPath -Value $reportContent -Encoding UTF8

        Write-Host ''
        Write-Host "Markdown report written to: $ReportPath"
    } 
}