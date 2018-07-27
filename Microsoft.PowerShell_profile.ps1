Set-Location  "C:\Users\mezo\projects\nevisfido"
Set-Alias ll dir
Set-Alias gw ./gradlew
Set-Alias n "C:\Program Files (x86)\Notepad++\notepad++.exe"
$env:JAVA_HOME="C:\Program Files\Java\jdk1.8.0_161"
function st() { git status }
function cdfido() { set-location "C:\Users\mezo\projects\nevisfido" }
function cdproj() { set-location "C:\Users\mezo\projects" }
function rmf($path) { Remove-Item -Force -Recurse -Path $path }
function killf($port) {
    $process = netstat -ona | ConvertFrom-String | Select p3, p6 | Where-Object {$_ -match "[.]*:$port"} | Select-Object -first 1
    if ($process.P6) { Stop-Process -Force $process.P6 }
}
function find($pattern) {
	Get-ChildItem -recurse | Select-String -pattern $pattern | group path | select name
}



