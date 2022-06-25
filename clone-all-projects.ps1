$path = "C:\mcb\github\MarceloCas";
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
        Write-Host "-p, --path --> base path to clone. Default: $path";
        Write-Host "-cp, --clearpath --> clear all files include subfolders in base path. Default: $clearPath";
        Write-Host "-gp, --gitpath --> git base path. Default: $gitBasePath";

        return;
    }
}

$repositoryCollection = @(
    # Core
    ("MCB.Core.Infra.CrossCutting.DesignPatterns.Validator.Abstractions", "Core.Infra.CC.DP.Val.Abs"),
    ("MCB.Core.Infra.CrossCutting.DesignPatterns.Validator", "Core.Infra.CC.DP.Val"),
    ("MCB.Core.Infra.CrossCutting.DesignPatterns.Abstractions", "Core.Infra.CC.DP.Abs"),
    ("MCB.Core.Infra.CrossCutting.DesignPatterns", "Core.Infra.CC.DP"),
    ("MCB.Core.Infra.CrossCutting", "Core.Infra.CC"),
    ("MCB.Core.Domain.Entities.Abstractions", "Core.Domain.Entities.Abs"),
    ("MCB.Core.Domain.Entities", "Core.Domain.Entities"),
    ("MCB.Core.Domain.Abstractions", "Core.Domain.Abs"),
    ("MCB.Core.Domain", "Core.Domain"),
    # Test
    ("MCB.Tests", "Tests"),
    # Demos
    ("MCB.Demos.ShopDemo", "Demos.ShopDemo"),
    # Others
    ("Docs", "Docs"),
    ("MCB.Environment", "Environment"),
    ("Benchmarks", "Benchmarks")
);

# enable windows long path
# if($IsWindows){
#     New-ItemProperty `
#     -Path "HKLM:\SYSTEM\CurrentControlSet\Control\FileSystem" `
#     -Name "LongPathsEnabled" `
#     -Value 1 `
#     -PropertyType DWORD `
#     -Force;

#     git config --system core.longpaths true;
# }

# create base path if not exists
if((Test-Path -Path $path) -eq $false){
    New-Item -ItemType directory -Path $path;
}

Set-Location $path;

# clone directories
foreach ($repository in $repositoryCollection) {

    $repositoryName = $repository[0];

    $gitPath = "$gitBasePath/$repositoryName";
    $repositoryPath = Join-Path -Path $path -ChildPath $repository[1];;
    
    # clear or bypass to next repository if exists
    if(Test-Path -Path $repositoryPath){
        if($clearPath){
            Remove-Item -Path $repositoryPath -Force -Recurse;
        } else {
            continue;
        }
    }

    # clone repository
    git clone $gitPath $repositoryPath;

    # trust repository directory
    #git config --global --add safe.directory $repositoryPath;

    # build if has .sln file
    if(Test-Path -Path $repositoryPath\*.sln -PathType Leaf){
        Set-Location $repositoryPath;
        dotnet build;
        Set-Location $path;
    }
}

Set-Location $initialPath;
