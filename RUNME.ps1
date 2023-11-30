param([String]$DemoProjjectNameBase = "WhiteLabel", [String]$AspireProjectName = "WhiteLabel.Aspire", [String]$AspireSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.Aspire", [String]$ServiceDefaultsPackage = "WhiteLabel.Aspire.ServiceDefaults", [String]$PackagesAndContainersSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.PackagesAndContainers")

# Welcome 
Clear-Host
$DemoProjjectName = Split-Path -Path (Get-Location) -Leaf

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceServerProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\$($DemoProjjectName).UserInterface"
$UserInterfaceClientProjectFolder = "$SolutionRootFolder\src\Application\UserInterface\$($DemoProjjectName).UserInterface.Client"
$ApiProjectFolder = "$SolutionRootFolder\src\Application\$($DemoProjjectName).WebApi"
$DomainProjectFolder = "$SolutionRootFolder\src\$($DemoProjjectName).Domain"
$InfrastructureProjectFolder = "$SolutionRootFolder\src\$($DemoProjjectName).Infrastructure"
$UseCasesProjectFolder = "$SolutionRootFolder\src\$($DemoProjjectName).UseCases"

# Add Nuget Configuration so Service Defaults are findble

$NugetConfigFilePath = "$AspireSolutionFolder\$AspireProjectName.AppHost\nuget.config"

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

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjjectName.Domain.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $InfrastructureProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjjectName.Infrastructure.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

Set-Location $UseCasesProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjjectName.UseCases.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

# Setup Service in Aspire Host 

Set-Location $AspireSolutionFolder

# Add Projects to Aspire Solution

$UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($DemoProjjectName).UserInterface.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($DemoProjjectName)"
$Process.WaitForExit()

$UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($DemoProjjectName).UserInterface.Client.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($DemoProjjectName)"
$Process.WaitForExit()

$WebApiProjectFilePath = "$ApiProjectFolder\$($DemoProjjectName).WebApi.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($DemoProjjectName)"
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

$DomainPackageName = "$DemoProjjectName.Domain"
$InfrastructurePackageName = "$DemoProjjectName.Infrastructure"
$UseCasesPackageName = "$DemoProjjectName.UseCases"

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

Write-Host "All done!"
Write-Host ""
Write-Host "Replace the code in Program.cs with the following setup."
Write-Host @'

'@

