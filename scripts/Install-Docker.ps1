################################################################################
##  File:  Install-Docker.ps1
##  Desc:  Install Docker.
##         Must be an independent step because it requires a restart before we
##         can continue.
################################################################################

# Docker EE 20.10.8 has the regression
# fatal: open C:\ProgramData\docker\panic.log: Access is denied.
Write-Host "Install-Package Docker"
 
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
.\install-docker-ce.ps1 -NoRestart

Write-Host "Download docker images"
$sitecoreVersion = $env:SC_VERSION
$solrVersion = $env:SOLR_VERSION
$winServerVersion = $env:WIN_VERSION
if ($null -eq $sitecoreVersion) {
    $sitecoreVersion = '10.2'
}
if ($null -eq $solrVersion) {
    $solrVersion = '8.4.0'
}
if ($null -eq $winServerVersion) {
    $winServerVersion = 'ltsc2019'
}
$dockerImages = @(
    "mcr.microsoft.com/dotnet/core/sdk:3.1",
    "mcr.microsoft.com/dotnet/framework/sdk:4.8"
    "mcr.microsoft.com/windows/nanoserver:1809",
    "scr.sitecore.com/sxp/sitecore-id:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-id6:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/nonproduction/solr:-$solrVersion-$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-redis:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-mssql:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-solr-init:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-cd:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-cm:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-cortexprocessing:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-cortexprocessingworker:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-cortexreporting:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-prc:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbautomation:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbautomationrpt:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbautomationworker:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbcollection:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbrefdata:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbsearch:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xp1-xdbsearchworker:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xm1-mssql:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xm1-solr-init:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xm1-cd:$sitecoreVersion-$winServerVersion",
    "scr.sitecore.com/sxp/sitecore-xm1-cm:$sitecoreVersion-$winServerVersion"
)

foreach ($dockerImage in $dockerImages) {
    Write-Host "Pulling docker image $dockerImage ..."
    docker pull $dockerImage

    if (!$?) {
        Write-Host "Docker pull failed with a non-zero exit code"
        exit 1
    }
}