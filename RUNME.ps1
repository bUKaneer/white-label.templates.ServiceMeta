param([String]$projectNameBase = "WhiteLabel", [String]$aspireProjectName = "WhiteLabel.Aspire", [String]$aspireSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.Aspire", [String]$packagesAndContainersSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.PackagesAndContainers")

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

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).UserInterface.csproj", "package", $serviceDefaultsPackage
$Process.WaitForExit()

Set-Location $ApiProjectFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).WebApi.csproj", "package", $serviceDefaultsPackage
$Process.WaitForExit()

# Add Shared Kernel to All Projects

$SharedKernelPackageName = "$projectNameBase.SharedKernel"

Set-Location $UserInterfaceServerProjectFolder
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).UserInterface.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $UserInterfaceClientProjectFolder
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).UserInterface.Client.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $ApiProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).WebApi.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $DomainProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).Domain.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $InfrastructureProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).Infrastructure.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()

Set-Location $UseCasesProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", ".\$($ProjectName).UseCases.csproj", "package", $SharedKernelPackageName
$Process.WaitForExit()


# Pack and Push Class Libraries to Baget

$PortConfigPath = "$packagesAndContainersSolutionFolder\ports.config.json"
$PortConfigJson = Get-Content $PortConfigPath | Out-String | ConvertFrom-Json
$PackageSourcePort = $PortConfigJson.PackagesUserInterfacePort

Set-Location $DomainProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.Domain.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $InfrastructureProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.Infrastructure.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $UseCasesProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$ProjectName.UseCases.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

# Setup Service in Aspire Host 

Set-Location $aspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($ProjectName).UserInterface.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($ProjectName)"
$Process.WaitForExit()

$UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($ProjectName).UserInterface.Client.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($ProjectName)"
$Process.WaitForExit()

$WebApiProjectFilePath = "$ApiProjectFolder\$($ProjectName).WebApi.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($ProjectName)"
$Process.WaitForExit()

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$aspireSolutionFolder\$($aspireProjectName).AppHost"

Set-Location $AspireAppHostFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceServerProjectFilePath
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceClientProjectFilePath
$Process.WaitForExit()

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath
$Process.WaitForExit()

# Setup Package References for Projects

$DomainPackageName = "$ProjectName.Domain"
$InfrastructurePackageName = "$ProjectName.Infrastructure"
$UseCasesPackageName = "$ProjectName.UseCases"

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


