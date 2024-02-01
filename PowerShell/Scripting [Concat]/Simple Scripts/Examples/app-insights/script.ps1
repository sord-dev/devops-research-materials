# Connect to Azure (you might want to include authentication logic if needed)
Connect-AzAccount

# Get all subscriptions
$subscriptions = Get-AzSubscription # -SubscriptionId de96849f-b54f-4efe-8faf-32b7ae6955eb

# Define an array to store all table data
$tableData = @()

# Iterate through each subscription
foreach ($subscription in $subscriptions) {
    # Set the current subscription context
    Select-AzSubscription -SubscriptionId $subscription.Id

    # Get all Application Insights resources
    $applicationInsights = Get-AzResource -ResourceType "Microsoft.Insights/components"

    # Iterate through each Application Insights
    foreach ($ai in $applicationInsights) {
        $workspace = Get-AzResource -ResourceId $ai.ResourceId
        $workspaceId = $workspace.Properties.workspaceResourceId

        # Get additional details for Application Insights
        $workspaceDetails = Get-AzResource -ResourceId $workspaceId

        # Display properties of the workspace
        $workspaceDetails | Format-Table -AutoSize

        # Create an object for each entry using New-Object
        $tableEntry = New-Object PSObject -Property @{
            'Subscription'               = $subscription.Name
            'Application Insights Name'  = $ai.Name
            'Log Analytics Workspace ID' = $workspaceId
        }

        # Add the object to the array
        $tableData += $tableEntry
    }
}

# Export the array to a CSV file
$tableData | Export-Csv -Path "./data/app-insights.csv" -NoTypeInformation
Write-Host "Exported the table to app-insights.csv"
