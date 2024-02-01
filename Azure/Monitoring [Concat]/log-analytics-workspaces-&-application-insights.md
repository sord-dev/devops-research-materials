----------------
title: Log Analytics Workspaces and Application Insights
author: sord-dev (Lau)
----------------

# Log Analytics Workspaces and Application Insights

**Application Insights:**

**1. Overview:**
Application Insights, a Microsoft Azure service, empowers developers to monitor and analyze their application's performance and usage. As an Application Performance Management (APM) solution, it facilitates issue identification, diagnosis, and telemetry data collection.

**2. Data Collection:**
Application Insights gathers data from diverse sources:

- *Server-Side Telemetry:* Automatic collection from server-side code, covering response times, failure rates, and dependencies.

- *Client-Side Telemetry:* Integration of the JavaScript SDK for client-side data like page load times and client interactions.

- *Logging and Tracing:* Customizable logging and tracing for specific events or information relevant to the application.

- *Dependency Tracking:* Monitoring of external component performance, such as database or API calls.

- *Custom Events and Metrics:* Developer-instrumented code for capturing application-specific data.

**3. Implementation:**
Flexible implementation options based on application architecture:

- *Server-Side:* Integration of the Application Insights SDK into server-side code for telemetry data transmission.

- *Client-Side:* Inclusion of the Application Insights JavaScript SDK in client-side applications for collecting relevant telemetry.

- *Custom Logging:* Addition of custom logging and instrumentation to capture specific events or metrics.

- *Azure Services Integration:* Seamless integration with Azure services, allowing correlation of data across various application components in the Azure cloud.

### Additional Information:

#### Azure Application Insight Service Association:

In the context of Azure Application Insights, the service itself doesn't need to be directly associated with virtual machines (VMs) .

1. **Instrumentation in Application Code:**
   - To utilize Application Insights, you need to instrument your application code (both server-side and client-side) by adding the Application Insights SDK. 
   - This is typically done in your source code or through a configuration file.

2. **Data Collection and Storage:**
   - Once instrumented, your application sends telemetry data (logs, metrics, traces) to the Application Insights service, which is hosted and managed by Azure. 
   - This telemetry data is then processed, analyzed, and stored in the Azure portal.

3. **Resource Group and Virtual Machines:**
   - While Application Insights doesn't require a direct association with VMs or a specific Resource Group, the VMs hosting your application might be part of a Resource Group. This is because a Resource Group is a logical container for resources that share the same lifecycle, permissions, and policies. 
   - Your VMs, Application Insights, and other Azure resources can coexist in the same or different Resource Groups based on your organizational structure.

4. **Integration with Azure Services:**
   - Application Insights can be integrated with other Azure services and resources to provide a comprehensive view of your application ecosystem. 
   - For example, you can correlate telemetry data with resources like Azure Web Apps, Azure Functions, or databases.

## 2. Log Analytics Workspaces
In essence, a desentralized repository where in which we send all of our logs collected by our Application Insights.

In these workspaces, all logs are stored in tables. Each table can have a different log retention and archiving period.

### Types of logs
Stored within a Log Analytics Workspace (LAW), there are 2 different types of logs.

We're charged differently depending on what ones we are utilizing, how much data we decide to ultimately store in them and how long we want to keep it.

They consist of:

**Analytics Logs**
<Add proper descrition here>

Features:
Retention Period: 13-90 days
Full KQL Access

Costs:
* Data Ingestion
* Data Retention (Beyond 13-90 days)
* Option to prebuy Gb of ingestion at various discounts.

**Basic Logs**
This is the lower cost plan with only search capabilities for debugging and troubleshooting.

Features:
Retention Period: 8 days (non-negotiable)
**Paid** KQL Access

Costs:
* Data Ingestion
* Data Retention

### Table based Log Storage
When we associate an AI to an LAW, we will create a table within the LAW that will store all of the logs pertaining to that specific AI.
We're able to provide granular access to these logs via IAM (Identity and Access Management).

# Notes
Task-Specific Resources and quotes. 
If you're not making a cloud design document, ignore this.

>Having multiple Application Insights instances send data to a single Log Analytics workspace can be beneficial for several reasons:
>
>1. **Unified View**: It provides a unified view of all your application, infrastructure, and platform logs in a single consolidated location². This can simplify the process of analyzing and correlating data across multiple applications or services².
>
>2. **Access Control**: It allows for common Azure role-based access control across your resources, eliminating the need for cross-app/workspace queries².
> 2.1. [example](../Security%20[Concat]/access-management-iam.md)

>
>3. **Resource Management**: It reduces the number of resources you need to manage. The recommendation is to keep the number of workspaces to a minimum unless you need clear separation due to different authorization, billing quotas, retention periods, regions, or environments¹.
>
>4. **Advanced Features**: With workspace-based Application Insights, you can take advantage of the latest capabilities of Azure Monitor and Log Analytics².
>
>However, the decision to use a single workspace or multiple workspaces depends on >your specific needs and the nature of your applications. For example, if you have different environments (dev, test, prod), it might make sense to have separate workspaces for each¹. 
>
> Similarly, if you have applications in different regions and want to handle region outages, having separate workspaces could be beneficial¹.
>
>In conclusion, using a Log Analytics workspace with multiple Application Insights >sending data to it can provide a more streamlined and efficient way to manage and >analyze your telemetry data. But the best approach depends on your specific >scenario and requirements.
>
>(1) [Create a new Azure Monitor Application Insights workspace-based](https://learn.microsoft.com/en-us/azure/azure-monitor/app/create-workspace-resource) .
>(2) [How many Log Analytics workspaces to use for multiple Application](https://stackoverflow.com/questions/69500219/how-many-log-analytics-workspaces-to-use-for-multiple-application-insights-insta).
>(3) [Design a Log Analytics workspace architecture](https://learn.microsoft.com/en-us/azure/azure-monitor/logs/workspace-design)

*Source: Conversation with Bing, 31/01/2024*