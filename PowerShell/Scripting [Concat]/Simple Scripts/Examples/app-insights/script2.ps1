# Connect to Azure (you might want to include authentication logic if needed)
Connect-AzAccount

# Get all subscriptions
$subscriptions = Get-AzSubscription 

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
}

# Output the total counts
Write-Host 'Total App Insights Scanned:', $totalAppInsightsScanned
Write-Host 'Total Classic App Insights Found:', $totalClassicAppInsights

$today = Get-Date -Format "dd-MM-yyyy"
$filePath = ("./data/ApplicationInsightsTable ({0}).csv" -f $today)

# Export the array to a CSV file
$tableData | Export-Csv -Path $filePath -NoTypeInformation
Write-Host "Exported table to: ", $filePath
