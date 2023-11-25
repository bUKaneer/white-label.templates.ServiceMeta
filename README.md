# Service Meta Template

This template should act as a jumping off point for the implementation of your (micro)service. 

You should really fork/copy this project and make your own version tweaked to you requirements but this is a good general start.

## Instructions

Run the dotnet new command to create a new solution based on this temmplate.

`dotnet new whitelabel-service -o WhiteLabel.Sample.Ping`

If you want the service to take part in 
an Aspire solution change folder into your new Service solution folder.

`cd WhiteLabel.Sample.Ping`

Then run the following command with appropriate inputs.

`.\RUNME.ps1 -aspireSolutionFolder "C:\path.to.aspire\WhiteLabel.Aspire" -serviceDefaultsPackage "WhiteLabel.Aspire.ServiceDefaults"`
