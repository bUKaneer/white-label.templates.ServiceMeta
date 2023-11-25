param([String]$aspireSolutionFolder, [String]$serviceDefaultsPackage)

# Welcome 
Clear-Host
$ProjectName = Split-Path -Path (Get-Location) -Leaf

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceServerProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\UserInterface"
$ApiProjectFolder = "$SolutionRootFolder\src\Application\WebApi"
$DomainProjectFolder = "$SolutionRootFolder\src\Application\Domain"
$InfrastructureProjectFolder = "$SolutionRootFolder\src\Application\Infrastructure"
$UseCasesProjectFolder = "$SolutionRootFolder\src\Application\UseCases"

# Add Service Defaults Reference to User Interface and Api 

Set-Location $UserInterfaceServerProjectFolder 

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\UserInterface.csproj", "package", $serviceDefaultsPackage

Set-Location $ApiProjectFolder

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\WebApi.csproj", "package", $serviceDefaultsPackage

# Setup Service in Aspire Host 

Set-Location $aspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceProjectFilePath = "$UserInterfaceServerProjectFolder\$($ProjectName).UserInterface.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$WebApiProjectFilePath = "$ApiProjectFolder\$($ProjectName).WebApi.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$DomainProjectFilePath = "$DomainProjectFolder\$($ProjectName).Domain.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $DomainProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$InfrastructureProjectFilePath = "$InfrastructureProjectFolder\$($ProjectName).Infrastructure.csproj"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $InfrastructureProjectFilePath, "--solution-folder", "Services\$($ProjectName)"

$UseCasesProjectFilePath = "$UseCasesProjectFolder\$($ProjectName).UseCases.csproj", "--solution-folder"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UseCasesProjectFilePath, "Services\$($ProjectName)"

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$aspireSolutionFolder\AppHost"

Set-Location $AspireAppHostFolder

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $DomainProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $InfrastructureProjectFilePath

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UseCasesProjectFilePath

