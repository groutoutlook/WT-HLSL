# Cross platform shebang:
shebang := if os() == 'windows' { 'pwsh.exe' } else { '/usr/bin/env pwsh' }
# Set shell for non-Windows OSs:
set shell := ["pwsh", "-c"]
# Set shell for Windows OSs:
set windows-shell := ["pwsh.exe", "-NoLogo", "-Command"]

hello:
    Write-Host "Hello, world!" -ForegroundColor Yellow

sw: 
    #!{{shebang}}
    Import-Module "$env:p7settingDir/quickTerminalAction"
    swapWtShader -
    Write-Host "Shader switched!" -ForegroundColor Green

build: sw

test:
    echo "Nope"
