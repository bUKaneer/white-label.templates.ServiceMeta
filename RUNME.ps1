param([String]$aspireAppHostFolder, [String]$serviceDefaultsPackage)

# Welcome 
Clear-Host

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"
$GitExecutablePath = "C:\Program Files\Git\bin\git.exe"
$DockerExecutablePath = "C:\Program Files\Docker\Docker\resources\bin\docker.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceServerProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\UserInterface"
$ApiProjectFolder = "$SolutionRootFolder\src\Application\WebApi"

# Add Service Defaults Reference 

Set-Location $UserInterfaceServerProjectFolder 

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\UserInterface.csproj", "package", $serviceDefaultsPackage

Set-Location $ApiProjectFolder

Start-Process -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\WebApi.csproj", "package", $serviceDefaultsPackage

