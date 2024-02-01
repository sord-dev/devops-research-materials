param (
    [string]$WorkspaceResourceID,
    [string]$SubscriptionId
)

# Connect to Azure (you might want to include authentication logic if needed)
Connect-AzAccount

# Get subscription or subscriptions depending on the input
if ($SubscriptionId) {
    $subscriptions = Get-AzSubscription -SubscriptionId $SubscriptionId
} else {
    $subscriptions = Get-AzSubscription
}

$len = $subscriptions.length
Write-Host '===========================INIT============================='
Write-Host "Using Workspace ResourceID: $WorkspaceResourceID"

($len -ige 1) ? "Scanning: $($subscriptions[0].Name)" : "Scanning $len Subscriptions"
Write-Host '============================================================'


# Define variables for tracking counts
$totalAppInsightsScanned = 0
$totalClassicAppInsights = 0

# Define an array to store all table data
$tableData = @()

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
        'Subscription'                   = $Subscription
        'Application Insights Name'      = $Name
        'Application Insights RG'        = $AppInsightsRG
        'Classic'                        = $Classic
        'Log Analytics Workspace'        = $LogAnalyticsWorkspace
        'Workspace RG'                   = $WorkspaceRG
    }
}

function Get-ClassicAppInsights {
    param (
        [array]$tableData
    )

    return $tableData | Where-Object { $_.Classic -eq $true }
}

function Convert-ToWorkspaceAppInsights {
    param (
        [array]$classicAppInsights,
        [string]$workspaceID
    )

    foreach ($ai in $classicAppInsights) {
        $aiName = $ai.'Application Insights Name'
        $aiRG = $ai.'Application Insights RG'

        # Update the Application Insights resource with the workspace parameter
        Update-AzApplicationInsights -Name $aiName -ResourceGroupName $aiRG -IngestionMode LogAnalytics -WorkspaceResourceId $workspaceID

        # Log workspace information for debugging
        Write-Host "Debug Conversion | App Insight: $($aiName):$($aiRG) Converted."
    }
}

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

    # Iterate through each Application Insights
    foreach ($ai in $applicationInsights) {
        $totalAppInsightsScanned++

        $workspace = Get-AzResource -ResourceId $ai.ResourceId
        $workspaceId = $workspace.Properties.workspaceResourceId

        # Get additional details for Application Insights
        if ($workspaceId) {
            $workspaceDetails = Get-AzResource -ResourceId $workspaceId

            $tableEntry = New-TableEntry -Subscription $subscription.Name `
                -Name $ai.Name `
                -AppInsightsRG $ai.ResourceGroupName `
                -Classic $false `
                -LogAnalyticsWorkspace $workspaceDetails.Name `
                -WorkspaceRG $workspaceDetails.ResourceGroupName        
        }
        else {
            $totalClassicAppInsights++
            $classicCount++
            $tableEntry = New-TableEntry -Subscription $subscription.Name`
                -Name $ai.Name`
                -AppInsightsRG $ai.ResourceGroupName `
                -Classic $true  
        }
        
        # Add the object to the array
        $tableData += $tableEntry
    }
    Write-Host 'Classic:', $classicCount
    Write-Host '============================================================'
}

# Output the total counts
Write-Host '============================================================'
Write-Host 'Total App Insights Scanned:', $totalAppInsightsScanned
Write-Host 'Total Classic App Insights Found:', $totalClassicAppInsights

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
