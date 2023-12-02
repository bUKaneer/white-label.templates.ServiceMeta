param([String]$ProjectNameBase = "WhiteLabel", [String]$AspireProjectName = "WhiteLabel.Aspire", [String]$AspireSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.Aspire", [String]$ServiceDefaultsPackage = "WhiteLabel.Aspire.ServiceDefaults", [String]$PackagesAndContainersSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.PackagesAndContainers")

# Welcome 
Clear-Host
$DemoProjectName = Split-Path -Path (Get-Location) -Leaf

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceServerProjectFolder = "$SolutionRootFolder\src\App\UI\$($DemoProjectName).UI"
$UserInterfaceClientProjectFolder = "$SolutionRootFolder\src\App\UI\$($DemoProjectName).UI.Client"
$ApiProjectFolder = "$SolutionRootFolder\src\App\$($DemoProjectName).WebApi"
$DomainProjectFolder = "$SolutionRootFolder\src\$($DemoProjectName).Domain"
$InfrastructureProjectFolder = "$SolutionRootFolder\src\$($DemoProjectName).Infrastructure"
$UseCasesProjectFolder = "$SolutionRootFolder\src\$($DemoProjectName).UseCases"

# Add Nuget Configuration so Service Defaults are findble

$NugetConfigFilePath = "$AspireSolutionFolder\$AspireProjectName.AppHost\nuget.config"
#$ConfigurationFolder = "$ProjectFolder\Configuration"

Copy-Item -Path $NugetConfigFilePath -Destination $UserInterfaceServerProjectFolder
Copy-Item -Path $NugetConfigFilePath -Destination $ApiProjectFolder

# Add Service Defaults Reference to User Interface and Api 

Set-Location $UserInterfaceServerProjectFolder 

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $ServiceDefaultsPackage
$Process.WaitForExit()

Set-Location $ApiProjectFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $ServiceDefaultsPackage
$Process.WaitForExit()

# Add Shared Kernel to All Projects

$SharedKernelPackageName = "$ProjectNameBase.SharedKernel"

Set-Location $UserInterfaceServerProjectFolder
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $UserInterfaceClientProjectFolder
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $ApiProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $DomainProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $InfrastructureProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $UseCasesProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()


# Pack and Push Class Libraries to Baget

$PortConfigPath = "$PackagesAndContainersSolutionFolder\ports.config.json"
$PortConfigJson = Get-Content $PortConfigPath | Out-String | ConvertFrom-Json
$PackageSourcePort = $PortConfigJson.PackagesUserInterfacePort

Set-Location $DomainProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.Domain.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $InfrastructureProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.Infrastructure.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $UseCasesProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.UseCases.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

# Setup Service in Aspire Host 

Set-Location $AspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($DemoProjectName).UI.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
$Process.WaitForExit()

$UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($DemoProjectName).UI.Client.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
$Process.WaitForExit()

$WebApiProjectFilePath = "$ApiProjectFolder\$($DemoProjectName).WebApi.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
$Process.WaitForExit()

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$AspireSolutionFolder\$($AspireProjectName).AppHost"

Set-Location $AspireAppHostFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceServerProjectFilePath
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceClientProjectFilePath
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath
$Process.WaitForExit()

# Setup Package References for Projects

$DomainPackageName = "$DemoProjectName.Domain"
$InfrastructurePackageName = "$DemoProjectName.Infrastructure"
$UseCasesPackageName = "$DemoProjectName.UseCases"

Set-Location $UserInterfaceServerProjectFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $DomainPackageName
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $InfrastructurePackageName
$Process.WaitForExit()

Set-Location $ApiProjectFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $DomainPackageName
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $InfrastructurePackageName
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $UseCasesPackageName
$Process.WaitForExit()

Set-Location $AspireAppHostFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "build"
$Process.WaitForExit()

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host @'
All done!

Replace the code in Program.cs with the following setup.


var builder = DistributedApplication.CreateBuilder(args);

var apiBackendForFrontEnd = builder.AddProject<Projects.$ProjectName_Sample_Demo_WebApi>("website-api-backend-for-frontend")
.WithLaunchProfile("https");

var websiteFrontend = builder.AddProject<Projects.$ProjectName_Sample_Demo_UserInterface>("website-frontend")
.WithLaunchProfile("https")
.WithReference(apiBackendForFrontEnd);

builder.Build().Run();

'@

