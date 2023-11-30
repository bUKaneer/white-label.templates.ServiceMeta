# Service Template

This template can be used to create a "Service" that can be hosted
as a project by the Aspire AppHost project.

This template comes preconfigured with a skeleton set of
architecture base libraries that are referenced as packages from the
local project package manager.

These library projects are:

- Infrastructure
- UseCases
- Domain

This template also comes preconfigured with two hostable projects.

These projects reside in the Application folder:

- UserInterface & UserInterface.Client
  - UserInterface is the "server" and the one to be referenced in App Host, however Client needs to be included to allow a build to take place from within the App Host because Server has a dependency on Client and Server must build to be findable in the `Projeects` object when calling `builder.AddProject<T>` in the App host `Program.cs` file.
  - This is a Blazor "Auto" app useful for the "front end".
- WebApi
  - This is a full Web Api intended as a "Backend for Frontend" solution for use with the UserInterface.Client project.

## Useful information

You should really fork/copy this project and make your own version tweaked to you requirements but this is a good general start.

Run the dotnet new command to create a new solution based on this temmplate.

`dotnet new whitelabel-service -o WhiteLabel.HostableProject`

If you want the service to take part in 
an Aspire solution change folder into your new Service solution folder.

`cd WhiteLabel.HostableProject`

Then run the following command with appropriate inputs.

`.\RUNME.ps1 -ProjectNameBase "$ProjectName" -AspireProjectName "$AspireProject" -AspireSolutionFolder "$AspireProjectFolder" -ServiceDefaultsPackage "$ProjectName.Aspire.ServiceDefaults" -PackagesAndContainersSolutionFolder "$ProjectPackagesAndContainersFolder"`

## Basic Wireup

Replace the existing code in 'WhiteLabel.Aspire\WhiteLabel.AppHost\Program.cs' with the below.

```csharp
var builder = DistributedApplication.CreateBuilder(args);

var apiBackendForFrontEnd = builder.AddProject<Projects.WhiteLabel_Sample_Demo_WebApi>("website-api-backend-for-frontend")
.WithLaunchProfile("https");

var websiteFrontend = builder.AddProject<Projects.WhiteLabel_Sample_Demo_UserInterface>("website-frontend")
.WithLaunchProfile("https")
.WithReference(apiBackendForFrontEnd);

builder.Build().Run();

```