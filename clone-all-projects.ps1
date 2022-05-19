$path = "C:\dev\github\mcb";
$clearPath = $false;
$gitBasePath = "https://github.com/MarceloCas";

$initialPath = Get-Location;

for ($i = 0; $i -lt $args.Count; $i++) {
    $arg = $args[$i].ToLower();

    if(($arg -eq "-p") -or ($arg -eq "--path")) {
        $path = $args[$i + 1];
    } elseif(($arg -eq "-cp") -or ($arg -eq "--clearpath")) {
        $clearPath = $true;
    } elseif(($arg -eq "-gp") -or ($arg -eq "--gitpath")) {
        $gitBasePath = $args[$i + 1];
    } elseif(($arg -eq "-h") -or ($arg -eq "--help")) {
        Write-Host ".\clone-all-projects.ps1 [OPTIONS]";
        Write-Host "";
        Write-Host "OPTIONS";
        Write-Host "-p, --path --> base path to clone. Default: C:\dev\github\mcb";
        Write-Host "-cp, --clearpath --> clear all files include subfolders in base path. Default: false";
        Write-Host "-gp, --gitpath --> git base path. Default: https://github.com/MarceloCas";

        return;
    }
}

$repositoryNameCollection = @(
    # Core
    "MCB.Core.Infra.CrossCutting.DesignPatterns.Validator.Abstractions",
    "MCB.Core.Infra.CrossCutting.DesignPatterns.Abstractions",
    "MCB.Core.Domain.Entities.Abstractions",
    "MCB.Core.Infra.CrossCutting.DesignPatterns.Abstractions",
    "MCB.Core.Infra.CrossCutting",
    "MCB.Core.Domain.Abstractions",
    "MCB.Core.Infra.CrossCutting.DesignPatterns",
    "MCB.Core.Domain.Entities",
    "MCB.Core.Domain",
    # Demos
    "MCB.Demos.ShopDemo",
    # Others
    "MCB.Tests",
    "Docs",
    #Demos 
    "Benchmarks"
);

# enable windows long path
if($IsWindows){
    New-ItemProperty `
    -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
    -Name "LongPathsEnabled" `
    -Value 1 `
    -PropertyType DWORD `
    -Force;

    git config --system core.longpaths true;
}

# create base path if not exists
if((Test-Path -Path $path) -eq $false){
    New-Item -ItemType directory -Path $path;
}

Set-Location $path;

# clone directories
foreach ($repositoryName in $repositoryNameCollection) {
    $gitPath = "$gitBasePath/$repositoryName";
    $repositoryPath = Join-Path -Path $path -ChildPath $repositoryName;
    
    # clear or bypass to next repository if exists
    if(Test-Path -Path $repositoryPath){
        if($clearPath){
            Remove-Item -Path $repositoryPath -Force -Recurse;
        } else {
            continue;
        }
    }

    # clone repository
    git clone $gitPath;

    # trust repository directory
    git config --global --add safe.directory $repositoryPath;

    # build if has .sln file
    if(Test-Path -Path $repositoryPath\*.sln -PathType Leaf){
        Set-Location $repositoryPath;
        dotnet build;
        Set-Location $path;
    }
}

Set-Location $initialPath;
