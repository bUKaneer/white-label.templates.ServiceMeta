param(
    [String]$ProjectNameBase = "WhiteLabel", 
    [String]$AspireProjectName = "WhiteLabel.Aspire", 
    [String]$AspireSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.Aspire", 
    [String]$ServiceDefaultsPackage = "WhiteLabel.Aspire.ServiceDefaults", 
    [String]$PackagesAndContainersSolutionFolder = "C:\WhiteLabel\WhiteLabel\WhiteLabel.PackagesAndContainers",
    [bool]$ApiOnly = 1)

# Welcome 
Clear-Host
$DemoProjectName = Split-Path -Path (Get-Location) -Leaf

# Set location for required executables
$DotNetExecutablePath = "C:\Program Files\dotnet\dotnet.exe"

# Set Project Folders 
$SolutionRootFolder = Get-Location 
$UserInterfaceProjectFolder = "$SolutionRootFolder\src\App\UI\"
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

if (!($ApiOnly)) {

    Set-Location $UserInterfaceServerProjectFolder 

    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $ServiceDefaultsPackage
    $Process.WaitForExit()

}

Set-Location $ApiProjectFolder

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $ServiceDefaultsPackage
$Process.WaitForExit()

# Add Shared Kernel to All Projects

$SharedKernelPackageName = "$ProjectNameBase.SharedKernel"

if (!($ApiOnly)) {
    Set-Location $UserInterfaceServerProjectFolder
    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
    $Process.WaitForExit()

    # Create PublishContainer Helper file
    Set-Location $UserInterfaceProjectFolder

    $UserInterfacePublishContainerContent = '
    $Process = Start-Process -PassThru -NoNewWindow "'+ $DotNetExecutablePath + '" -ArgumentList "publish --os linux --arch x64 -c Release -p:PublishProfile=DefaultContainer"
    $Process.WaitForExit()
    '

    $UserInterfacePublishContainerFilePath = "$UserInterfaceServerProjectFolder\PublishContainer.ps1"
    New-Item -Path $UserInterfacePublishContainerFilePath -ItemType File 
    Set-Content -Path $UserInterfacePublishContainerFilePath -Value $UserInterfacePublishContainerContent

    Set-Location $UserInterfaceClientProjectFolder
    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
    $Process.WaitForExit()
}

Set-Location $ApiProjectFolder 
$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $SharedKernelPackageName
$Process.WaitForExit()


# Create PublishContainer Helper file
$ApiPublishContainerContent = '
$Process = Start-Process -PassThru -NoNewWindow "'+ $DotNetExecutablePath + '" -ArgumentList "publish --os linux --arch x64 -c Release -p:PublishProfile=DefaultContainer"
$Process.WaitForExit()
'
$ApiPublishContainerFilePath = "$ApiProjectFolder\PublishContainer.ps1"
New-Item -Path $ApiPublishContainerFilePath -ItemType File 
Set-Content -Path $ApiPublishContainerFilePath -Value $ApiPublishContainerContent

# Shared Kernel for Packages
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
$ContainersRegistryPort = $PortConfigJson.ContainersRegistryPort

Set-Location $DomainProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.Domain.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

$DomainPackPushCommands = '
$Process = Start-Process -NoNewWindow -PassThru "' + $DotNetExecutablePath + '" -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru "' + $DotNetExecutablePath + '" -ArgumentList "nuget", "push", "./nupkgs/' + $DemoProjectName + '.Domain.1.0.0.nupkg", "-s http://localhost:' + $PackageSourcePort + '/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()
'

$DomainPackPushFilePath = "$DomainProjectFolder\PushPackage.ps1"
New-Item -Path $DomainPackPushFilePath -ItemType File 
Set-Content -Path $DomainPackPushFilePath -Value $DomainPackPushCommands

Set-Location $InfrastructureProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.Infrastructure.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

$InfrastructurePackPushCommands = '
$Process = Start-Process -NoNewWindow -PassThru "'+ $DotNetExecutablePath + '" -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru "'+ $DotNetExecutablePath + '" -ArgumentList "nuget", "push", "./nupkgs/' + $DemoProjectName + '.Infrastructure.1.0.0.nupkg", "-s http://localhost:' + $PackageSourcePort + '/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()
'

$InfrastructurePackPushFilePath = "$InfrastructureProjectFolder\PushPackage.ps1"
New-Item -Path $InfrastructurePackPushFilePath -ItemType File 
Set-Content -Path $InfrastructurePackPushFilePath -Value $InfrastructurePackPushCommands


Set-Location $UseCasesProjectFolder

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru $DotNetExecutablePath -ArgumentList "nuget", "push", "./nupkgs/$DemoProjectName.UseCases.1.0.0.nupkg", "-s http://localhost:$PackageSourcePort/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()

$UseCasesPackPushCommands = '
$Process = Start-Process -NoNewWindow -PassThru "'+ $DotNetExecutablePath + '" -ArgumentList "pack", "--output nupkgs"
$Process.WaitForExit()

$Process = Start-Process -NoNewWindow -PassThru "'+ $DotNetExecutablePath + '" -ArgumentList "nuget", "push", "./nupkgs/' + $DemoProjectName + '.UseCases.1.0.0.nupkg", "-s http://localhost:' + $PackageSourcePort + '/v3/index.json", "-k 8B516EDB-7523-476E-AF43-79CCA054CE9F"
$Process.WaitForExit()
'

$UseCasesPackPushFilePath = "$UseCasesProjectFolder\PushPackage.ps1"
New-Item -Path $UseCasesPackPushFilePath -ItemType File 
Set-Content -Path $UseCasesPackPushFilePath -Value $UseCasesPackPushCommands

# Setup Service in Aspire Host 

Set-Location $AspireSolutionFolder

# Add Projects to Aspire Solution

if (!($ApiOnly)) {
    $UserInterfaceServerProjectFilePath = "$UserInterfaceServerProjectFolder\$($DemoProjectName).UI.csproj"

    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceServerProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
    $Process.WaitForExit()

    $UserInterfaceClientProjectFilePath = "$UserInterfaceClientProjectFolder\$($DemoProjectName).UI.Client.csproj"

    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $UserInterfaceClientProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
    $Process.WaitForExit()
}

$WebApiProjectFilePath = "$ApiProjectFolder\$($DemoProjectName).WebApi.csproj"

$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "sln", "add", $WebApiProjectFilePath, "--solution-folder", "Services\$($DemoProjectName)"
$Process.WaitForExit()

# Add Reference from UserInterface and WebApi to App.Host Project

$AspireAppHostFolder = "$AspireSolutionFolder\$($AspireProjectName).AppHost"

Set-Location $AspireAppHostFolder

if (!($ApiOnly)) {
    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceServerProjectFilePath
    $Process.WaitForExit()

    #$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $UserInterfaceClientProjectFilePath
    #$Process.WaitForExit()
}


$Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "reference", $WebApiProjectFilePath
$Process.WaitForExit()

# Setup Package References for Projects

$DomainPackageName = "$DemoProjectName.Domain"
$InfrastructurePackageName = "$DemoProjectName.Infrastructure"
$UseCasesPackageName = "$DemoProjectName.UseCases"

if (!($ApiOnly)) {
    Set-Location $UserInterfaceServerProjectFolder

    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $DomainPackageName
    $Process.WaitForExit()

    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $InfrastructurePackageName
    $Process.WaitForExit()
    
    $Process = Start-Process -PassThru -NoNewWindow $DotNetExecutablePath -ArgumentList "add", "package", $UseCasesPackageName
    $Process.WaitForExit()
}

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

$AspireProjectsCompatibleProjectName = $DemoProjectName -replace '\.', '_'

Write-Host ""
Write-Host ""
Write-Host ""
Write-Host ""
Write-Host "
All done!

Replace the code in Program.cs with the following setup.


var builder = DistributedApplication.CreateBuilder(args);

"

if ($ApiOnly) {

    Write-Host "var api = builder.AddProject<Projects.$($AspireProjectsCompatibleProjectName)_WebApi>(""api"")
    .WithLaunchProfile(""http"");"

}

if (!($ApiOnly)) {

    Write-Host "var apiBackendForFrontEnd = builder.AddProject<Projects.$($AspireProjectsCompatibleProjectName)_WebApi>(""api-backend-for-frontend"")
    .WithLaunchProfile(""http"");
    
    var frontend = builder.AddProject<Projects.$($AspireProjectsCompatibleProjectName)_UserInterface>(""ui-frontend"")
    .WithLaunchProfile(""http"")
    .WithReference(apiBackendForFrontEnd);
    "

}

Write-Host ""
Write-Host "
    builder.Build().Run();

    -- -

    Edit both the UI Server and WebAPI csproj files (Find in files from the top level folder).

    Replace:
    {CONTAINER_REGISTRY_PORT}

    With this:
    $ContainersRegistryPort

    This will enable publish to container support.

    "

if ($ApiOnly) {

    Remove-Item -Path $UserInterfaceProjectFolder 

}