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

# Add Service Defaults Reference to User Interface and Api 

Set-Location $UserInterfaceServerProjectFolder 

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\UserInterface.csproj", "package", $serviceDefaultsPackage

Set-Location $ApiProjectFolder

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\WebApi.csproj", "package", $serviceDefaultsPackage

# Setup Service in Aspire Host 

Set-Location $aspireSolutionFolder

# dotnet sln add mylib1\mylib1.csproj --solution-folder mylibs

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", "$UserInterfaceServerProjectFolder\UserInterface.csproj", "--solution-folder", "Services\$($ProjectName)"

Start-Process -Wait -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", "$ApiProjectFolder\WebApi.csproj", "--solution-folder", "Services\$($ProjectName)"