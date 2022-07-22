################################################################################
##  File:  Install-Docker.ps1
##  Desc:  Install Docker.
##         Must be an independent step because it requires a restart before we
##         can continue.
################################################################################

# Docker EE 20.10.8 has the regression
# fatal: open C:\ProgramData\docker\panic.log: Access is denied.
Write-Host "Install-Package Docker"
 
# Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
# Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion 20.10.7 -Force
# Start-Service docker
Invoke-WebRequest -UseBasicParsing "https://raw.githubusercontent.com/microsoft/Windows-Containers/Main/helpful_tools/Install-DockerCE/install-docker-ce.ps1" -o install-docker-ce.ps1
.\install-docker-ce.ps1 -NoRestart

Write-Host "Install-Package Docker-Compose v1"
Choco-Install -PackageName docker-compose

Write-Host "Install-Package Docker-Compose v2"
$dockerComposev2Url = "https://github.com/docker/compose/releases/latest/download/docker-compose-windows-x86_64.exe"
Start-DownloadWithRetry -Url $dockerComposev2Url -Name docker-compose.exe -DownloadPath "C:\Program Files\Docker\cli-plugins"

Write-Host "Install docker-wincred"
$dockerCredLatestRelease = Invoke-RestMethod -Uri "https://api.github.com/repos/docker/docker-credential-helpers/releases/latest"
$dockerCredDownloadUrl = $dockerCredLatestRelease.assets.browser_download_url -match "docker-credential-wincred-.+\.zip" | Select-Object -First 1
$dockerCredArchive = Start-DownloadWithRetry -Url $dockerCredDownloadUrl
Expand-Archive -Path $dockerCredArchive -DestinationPath "C:\Program Files\Docker"

Write-Host "Download docker images"
$sitecoreVersion = $env:SC_VERSION
if ($null -eq $sitecoreVersion) {
    $sitecoreVersion = '10.2'
}
$dockerImages = @(
    "mcr.microsoft.com/dotnet/core/sdk:3.1",
    "mcr.microsoft.com/dotnet/framework/sdk:4.8"
    "mcr.microsoft.com/windows/nanoserver:1809",
    "scr.sitecore.com/sitecore-redis:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-mssql:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-solr:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-solr-init:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cd:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cm:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cortexprocessing:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cortexprocessingworker:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cortexreporting:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-prc:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbautomation:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbautomationrpt:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbautomationworker:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbcollection:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbrefdata:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbsearch:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-xdbsearchworker:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xm1-mssql:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xm1-solr:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xm1-solr-init:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xm1-cd:$sitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xm1-cm:$sitecoreVersion-ltsc2019"
)

foreach ($dockerImage in $dockerImages) {
    Write-Host "Pulling docker image $dockerImage ..."
    docker pull $dockerImage

    if (!$?) {
        Write-Host "Docker pull failed with a non-zero exit code"
        exit 1
    }
}