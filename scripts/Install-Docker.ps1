################################################################################
##  File:  Install-Docker.ps1
##  Desc:  Install Docker.
##         Must be an independent step because it requires a restart before we
##         can continue.
################################################################################

# Docker EE 20.10.8 has the regression
# fatal: open C:\ProgramData\docker\panic.log: Access is denied.
Write-Host "Install-Package Docker"
 
Install-Module -Name DockerMsftProvider -Repository PSGallery -Force
Install-Package -Name docker -ProviderName DockerMsftProvider -RequiredVersion 20.10.7 -Force
Start-Service docker

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
$dockerImages = @(
    "mcr.microsoft.com/dotnet/core/sdk:3.1",
    "mcr.microsoft.com/dotnet/framework/sdk:4.8"
    "mcr.microsoft.com/windows/nanoserver:1809",
    "scr.sitecore.com/sitecore-redis:$SitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-mssql:$SitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-solr:$SitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-solr-init:$SitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cd:$SitecoreVersion-ltsc2019",
    "scr.sitecore.com/sitecore-xp1-cm:$SitecoreVersion-ltsc2019"
)

foreach ($dockerImage in $dockerImages) {
    Write-Host "Pulling docker image $dockerImage ..."
    docker pull $dockerImage

    if (!$?) {
        Write-Host "Docker pull failed with a non-zero exit code"
        exit 1
    }
}