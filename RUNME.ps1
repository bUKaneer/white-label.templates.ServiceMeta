param([String]$aspireProjectName, [String]$aspireSolutionFolder, [String]$serviceDefaultsPackage)

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

# Setup Service in Aspire Host 

Set-Location $aspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($ProjectName).UserInterface.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($ProjectName).UserInterface.Client.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$WebApiProjectFilePath = "$ApiProjectFolder\$($ProjectName).WebApi.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$DomainProjectFilePath = "$DomainProjectFolder\$($ProjectName).Domain.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $DomainProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$InfrastructureProjectFilePath = "$InfrastructureProjectFolder\$($ProjectName).Infrastructure.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $InfrastructureProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$UseCasesProjectFilePath = "$UseCasesProjectFolder\$($ProjectName).UseCases.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UseCasesProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$aspireSolutionFolder\$($aspireProjectName).AppHost"

Set-Location $AspireAppHostFolder

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceServerProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceClientProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath

# Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $DomainProjectFilePath

# Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $InfrastructureProjectFilePath

# Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UseCasesProjectFilePath

