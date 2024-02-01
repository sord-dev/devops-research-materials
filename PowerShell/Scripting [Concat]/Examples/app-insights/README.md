# Classic Application Insights Detection Script

## Overview

This script is designed to find all Classic Application Insights by checking their association with Log Analytics workspaces. The script uses two commands: one to retrieve information about Application Insights and another to find associated workspaces. If there are no associated workspaces, the script assumes that the Application Insight is a classic one.

## Usage

1. Open a terminal within the directory containing the script.

   **Option 1: Run the Script**
   - Execute the following command in a **PowerShell** terminal:
     ```
     ./src/script3.ps1
     ```
   - The script will prompt you to log in and then loop through each subscription to gather information about Application Insights and their associated workspaces.

   **Option 2: Run the Batch File**
   - Execute the following command in the terminal:
     ```
     ./run-latest.bat
     ```
   - This batch file is configured to run the latest version of the script (`./src/script3.ps1`).
  
   Note: Ensure that the appropriate permissions are set to execute the scripts.

## Versions

### Version 1
**src/script.ps1**

Returns a simplified list of all Application Insights with their associated workspace's ResourceID or nothing if it doesn't exist.

### Version 2
**src/script2.ps1**

Returns a list including more details about the Application Insights and their associated workspaces, including workspace name and resource group.

### Version 3
**src/script3.ps1**

Introduces additional features and improvements to enhance the script's functionality. This version provides even more detailed information about Application Insights and their associated workspaces. It also includes a feature to convert Classic Application Insights to workspace-based, enhancing the usability of the script.


### Version 4 (Latest)
**src/script4.ps1**

- **Params:**
1. **Log Analytics Workspace Resource ID:**
   - The Resource ID of the Log Analytics Workspace that you want to associate with the Classic Application Insights instances.

2. **Subscription ID:**
   - The ID of the Azure subscription to be scanned for Classic Application Insights. If left empty, the script will scan all available subscriptions.

This script aims to simplify the association of a Log Analytics Workspace with Classic Application Insights within a specified Azure subscription. The Log Analytics Workspace is identified by its Resource ID, allowing for efficient configuration.

#### Execution:

```powershell
  .\script4.ps1 -LogAnalyticsWorkspaceResourceId <LogAnalyticsWorkspaceResourceID> -SubscriptionId <SubscriptionID>
```

#### Converting Classic Application Insights

If you want to convert Classic Application Insights to workspace-based using the script:
- The script will prompt you after displaying information about Classic App Insights.
- Respond 'Y' or 'y' to initiate the conversion process.
- The script will update each Classic Application Insight with the corresponding Log Analytics workspace.

## Additional Notes

Feel free to explore and customize the script based on your specific needs. If you encounter any issues or have suggestions for further improvements, please let us know!
