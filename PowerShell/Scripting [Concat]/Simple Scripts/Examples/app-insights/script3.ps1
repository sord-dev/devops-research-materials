# Connect to Azure (you might want to include authentication logic if needed)
Connect-AzAccount

# Get all subscriptions
$subscriptions = Get-AzSubscription -SubscriptionId bf5573ae-714b-4242-bf5b-e002df3894fd

# Define variables for tracking counts
$totalAppInsightsScanned = 0
$totalClassicAppInsights = 0

# Define an array to store all table data
$tableData = @()

# Construct a hashtable to store workspace information for each subscription and resource group
$subscriptionWorkspaceMap = @{}

function New-TableEntry {
    param (
        [string]$Subscription,
        [string]$Name,
        [string]$AppInsightsRG,
        [bool]$Classic,
        [string]$LogAnalyticsWorkspace,
        [string]$WorkspaceRG
    )

    return New-Object PSObject -Property @{
        'Subscription'              = $Subscription
        'Application Insights Name' = $Name
        'Application Insights RG'   = $AppInsightsRG
        'Classic'                   = $Classic
        'Log Analytics Workspace'   = $LogAnalyticsWorkspace
        'Workspace RG'              = $WorkspaceRG
    }
}

# Function to filter out non-classic App Insights
function Get-ClassicAppInsights {
    param (
        [array]$tableData
    )

    return $tableData | Where-Object { $_.Classic -eq $true }
}

function Convert-ToWorkspaceAppInsights {
    param (
        [array]$classicAppInsights,
        [hashtable]$workspaceMap
    )

    foreach ($ai in $classicAppInsights) {
        $aiName = $ai.'Application Insights Name'
        $aiRG = $ai.'Application Insights RG'

        # Get workspace information from the map
        $workspaceInfo = $workspaceMap[$ai.'Subscription'][$aiRG]

        $workspaceName = $workspaceInfo['WorkspaceName']
        $workspaceRG = $workspaceInfo['WorkspaceRG']

        # Get the resource ID of the Log Analytics workspace
        $workspaceResourceId = (Get-AzOperationalInsightsWorkspace -ResourceGroupName $workspaceRG -Name $workspaceName).ResourceId

        # Update the Application Insights resource with the workspace parameter
        Update-AzApplicationInsights -Name $aiName -ResourceGroupName $aiRG -IngestionMode LogAnalytics -WorkspaceResourceId $workspaceResourceId

        # Log workspace information for debugging
        Write-Host "Debug Conversion | App Insight: $($aiName):$($aiRG) & Workspace: $($workspaceName):$($workspaceRG)"
    }
}

# MAIN
# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription context
    Select-AzSubscription -SubscriptionId $subscription.Id

    # Get all Application Insights resources
    $applicationInsights = Get-AzResource -ResourceType "Microsoft.Insights/components";
    
    $count = $applicationInsights.length
    $classicCount = 0;
    
    Write-Host 'Processing Subscription:', $subscription.Name
    Write-Host 'App insights:', $count

    # Hashtable to store workspace information for the current subscription
    $subscriptionResourceMap = @{}

    # Iterate through each Application Insights
    foreach ($ai in $applicationInsights) {
        $totalAppInsightsScanned++

        # Check for the presence of a workspaceId on the application insight
        $aiExpanded = Get-AzResource -ResourceId $ai.ResourceId
        $workspaceId = $aiExpanded.Properties.workspaceResourceId

        # If workspaceId is present append all details to table + this.subscription.resource_group
        if ($workspaceId) {
            $workspaceDetails = Get-AzResource -ResourceId $workspaceId

            $tableEntry = New-TableEntry -Subscription $subscription.Name `
                -Name $ai.Name `
                -AppInsightsRG $ai.ResourceGroupName `
                -Classic $false `
                -LogAnalyticsWorkspace $workspaceDetails.Name `
                -WorkspaceRG $workspaceDetails.ResourceGroupName        

            # Store workspace information in the hashtable for the current resource group
            $subscriptionResourceMap[$ai.ResourceGroupName] = @{
                'WorkspaceName' = $workspaceDetails.Name
                'WorkspaceRG'   = $workspaceDetails.ResourceGroupName
            }
        }
        else { # Else, search for presense of workspace within resource group and append that to table
            $totalClassicAppInsights++
            $classicCount++
        
            $logAnalyticsWorkspace = Get-AzOperationalInsightsWorkspace -ResourceGroupName $ai.ResourceGroupName -ErrorAction SilentlyContinue

            if ($logAnalyticsWorkspace) {
                $workspaceName = $logAnalyticsWorkspace.Name
                $workspaceRG = $logAnalyticsWorkspace.ResourceGroupName

                $tableEntry = New-TableEntry -Subscription $subscription.Name`
                    -Name $ai.Name`
                    -AppInsightsRG $ai.ResourceGroupName `
                    -Classic $true  
                -LogAnalyticsWorkspace $workspaceName `
                    -WorkspaceRG $workspaceRG

                # Store workspace information in the hashtable for the current resource group
                $subscriptionResourceMap[$ai.ResourceGroupName] = @{
                    'WorkspaceName' = $workspaceName
                    'WorkspaceRG'   = $workspaceRG
                }
            }
            else {
                # Handle the case where no Log Analytics workspace is found
                Write-Host "Error: No Log Analytics workspace found for $($ai.ResourceGroupName). Skipping conversion."
                continue
            }
        }
    
        # Add the object to the array
        $tableData += $tableEntry
    }

    # Store the subscription resource map in the main workspace map
    $subscriptionWorkspaceMap[$subscription.Name] = $subscriptionResourceMap
    Write-Host 'Classic:', $classicCount
}

# Display the information to the user
$tableData | Format-Table

# Filter out non-classic App Insights
$classicAppInsights = Get-ClassicAppInsights -tableData $tableData

if ($classicAppInsights.Length -gt 0) {
    # Prompt the user for conversion
    $convertAll = Read-Host "Do you want to convert all Classic App Insights to workspace-based? (Y/N)"

    if ($convertAll -eq 'Y' -or $convertAll -eq 'y') {
        Write-Host "Converting..."
        $classicAppInsights | Format-Table
        Convert-ToWorkspaceAppInsights $classicAppInsights $subscriptionWorkspaceMap
        Write-Host "Conversion completed successfully!"
    }
    else {
        Write-Host "No conversion performed. Have a great day!"
    }
}
else {
    Write-Host "Found only workspace application insights, skipping conversion!"
}