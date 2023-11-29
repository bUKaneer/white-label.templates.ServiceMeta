param([String]$aspireProjectName = "WhiteLabel.Aspire", [String]$aspireSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.Aspire", [String]$packagesAndContainersSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.PackagesAndContainers")

# Welcome 
Clear-Host
$ProjectName = Split-Path -Path (Get-Location) -Leaf

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceServerProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\$($ProjectName).UserInterface"
$UserInterfaceClientProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\$($ProjectName).UserInterface.Client"
$ApiProjectFolder = "$SolutionRootFolder\src\Application\$($ProjectName).WebApi"
$DomainProjectFolder = "$SolutionRootFolder\src\$($ProjectName).Domain"
$InfrastructureProjectFolder = "$SolutionRootFolder\src\$($ProjectName).Infrastructure"
$UseCasesProjectFolder = "$SolutionRootFolder\src\$($ProjectName).UseCases"

# Add Nuget Configuration so Service Defaults are findble

$NugetConfigFilePath = "$aspireSolutionFolder\$aspireProjectName.AppHost\nuget.config"

Copy-Item -Path $NugetConfigFilePath -Destination $UserInterfaceServerProjectFolder
Copy-Item -Path $NugetConfigFilePath -Destination $ApiProjectFolder

# Add Service Defaults Reference to User Interface and Api 

Set-Location $UserInterfaceServerProjectFolder 

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).UserInterface.csproj", "package", $serviceDefaultsPackage

Set-Location $ApiProjectFolder

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).WebApi.csproj", "package", $serviceDefaultsPackage

# Pack and Push Service Projects to Baget

$PortConfigPath = "$packagesAndContainersSolutionFolder\ports.config.json"
$PortConfigJson = Get-Content $PortConfigPath | Out-String | ConvertFrom-Json
$PackageSourcePort = $PortConfigJson.PackagesUserInterfacePort

Set-Location $DomainProjectFolder
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.Domain.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

Set-Location $InfrastructureProjectFolder
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.Infrastructure.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

Set-Location $UseCasesProjectFolder
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
Start-Process -NoNewWindow -Wait $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.UseCases.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"

# Setup Service in Aspire Host 

Set-Location $aspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($ProjectName).UserInterface.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($ProjectName).UserInterface.Client.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$WebApiProjectFilePath = "$ApiProjectFolder\$($ProjectName).WebApi.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$aspireSolutionFolder\$($aspireProjectName).AppHost"

Set-Location $AspireAppHostFolder

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceServerProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceClientProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath
