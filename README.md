# LCWMermaidGenerator

A PowerShell module that connects to Microsoft Graph and generates comprehensive Markdown reports with embedded Mermaid flowchart diagrams for all [Entra ID Identity Governance Lifecycle Workflows](https://learn.microsoft.com/en-us/entra/id-governance/what-are-lifecycle-workflows) in your tenant.

## Prerequisites

- **PowerShell 7.1** or later (Core edition)
- **Microsoft.Graph PowerShell SDK** — install it from the PowerShell Gallery:

  ```powershell
  Install-Module Microsoft.Graph -Scope CurrentUser
  ```

- An Entra ID account with one of the following permissions:
  - `LifecycleWorkflows.Read.All`
  - `LifecycleWorkflows.ReadWrite.All`

## Installation

### From the PowerShell Gallery (recommended)

```powershell
Install-Module LCWMermaidGenerator -Scope CurrentUser
```

### From source

```powershell
git clone https://github.com/goodworkaround/LCWMermaidGenerator.git
Import-Module ./LCWMermaidGenerator -Force
```

## Usage

### 1. Connect to Microsoft Graph

```powershell
Connect-MgGraph -Scopes 'LifecycleWorkflows.Read.All'
```

### 2. Run the generator

```powershell
# Generate a report at the default location (LifecycleWorkflowsReport.md in the current directory)
Invoke-LCWMermaidGenerator

# Generate a report at a custom path
Invoke-LCWMermaidGenerator -ReportPath 'C:\Reports\MyWorkflowsReport.md'
```

### Full example

```powershell
# Import the module (skip if installed from the Gallery)
Import-Module "./LCWMermaidGenerator" -Force

# Authenticate
Connect-MgGraph -Scopes 'LifecycleWorkflows.Read.All'

# Generate the report
Invoke-LCWMermaidGenerator -ReportPath './LifecycleWorkflowsReport.md'
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `-ReportPath` | String | No | `LifecycleWorkflowsReport.md` | Path where the Markdown report file will be written. |

## Output

Running `Invoke-LCWMermaidGenerator` produces:

1. **Console output** — a human-readable text summary of every workflow, including trigger, scope, and task details.
2. **Markdown report file** — a structured `.md` file containing:
   - A metadata table per workflow (ID, display name, category, enabled status, created/modified dates).
   - A numbered task list with task definitions and all configured arguments.
   - An embedded [Mermaid](https://mermaid.js.org/) flowchart diagram visualizing the workflow execution path with color-coded nodes:
     - 🔵 Dark blue — workflow entry node
     - 🟢 Light green — enabled tasks
     - ⚫ Gray dashed — disabled tasks
     - 🟠 Orange — custom Logic App extension tasks
     - 🟢 Light green — trigger / scope metadata nodes

The report can be rendered in any Markdown viewer that supports Mermaid (e.g. GitHub, VS Code with the Markdown Preview Mermaid Support extension, or Obsidian).

## License

This project is licensed under the [MIT License](LICENSE).