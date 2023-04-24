<# 
.SYNOPSIS
    Deploy the simpleRace mod to your local BeamMP server.

.DESCRIPTION 
    Run the script using .\deploy.ps1 [serverPath]. This will deploy the mod on your server.
 
.Parameter serverPath 
    The path of your BeamMp server folder.
#>

param(
  [Parameter(Mandatory = $true,ParameterSetName = "BeamMP Server Folder Path")][string]$serverPath
)

# Compress the client part of the mod
$compress = @{
  Path = ".\Client\lua", ".\Client\scripts"
  CompressionLevel = "Fastest"
  DestinationPath = ".\Client\simpleRace.zip"
  Force = $true
}
Compress-Archive @compress

# Copy the client part to the server client folder
$clientPartServerPath = Join-Path $serverPath '\Resources\Client\'
Copy-Item -Path .\Client\simpleRace.zip -Destination $clientPartServerPath -PassThru

# Copy the server part to the server folder
$serverPartServerPath = Join-Path $serverPath '\Resources\Server\'
Copy-Item -Path .\Server\* -Destination $serverPartServerPath -PassThru -Recurse