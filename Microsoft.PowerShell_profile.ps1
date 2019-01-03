Set-Location  "C:\Users\mezo\projects\nevisfido"
Set-Alias ll dir
Set-Alias gw ./gradlew
Set-Alias n "C:\Program Files (x86)\Notepad++\notepad++.exe"
$env:JAVA_HOME="C:\Program Files\Java\jdk1.8.0_161"

function cl() { gw clean --rerun-tasks }

function b() {
	$TestsToIgnore = @(
		'application/src/test/java/ch/nevis/auth/fido/uaf/application/resolver/CommandExecutorIntTest.java',
		'common/src/test/java/ch/nevis/auth/fido/uaf/common/filewatcher/DefaultPathChangeSupplierTest.java',
		'out-of-band/src/integrationTest/java/ch/nevis/auth/fido/uaf/oob/dispatcher/impl/fcm/FcmDispatcherIntegrationTest.java'
	)
	$PublicClass = 'public class'
	$Ignore = 'import org.junit.Ignore; @Ignore '
	
	Write-Host 'PowerShell execution - Ignoring test cases: ' $TestsToIgnore
	ReplaceInFiles $TestsToIgnore $PublicClass ($Ignore + $PublicClass)
	Write-Host 'PowerShell execution - Switching parallel off.'
	ParallelOn $false
	
	gw build
	
	Write-Host 'PowerShell execution - Enabling test cases: ' $TestsToIgnore
	ReplaceInFiles $TestsToIgnore $Ignore ''
	Write-Host 'PowerShell execution - Switching parallel on.'
	ParallelOn $true
}

function ReplaceInFiles($Files, $What, $With) {
	foreach ($File in $Files) {
		ReplaceInFile $File $What $With
	}
}

function ReplaceInFile($File, $What, $With) {
	(Get-Content -path $File) -replace $What, $With | Set-Content $File
}

function ParallelOn($on) {
		$GradleProperties = 'gradle.properties'
		$ParallelTrue = 'org.gradle.parallel=true'
		$ParallelFalse = 'org.gradle.parallel=false'
		$IsParallelTrue = Get-Content $GradleProperties | Select-String $ParallelTrue
		if ($IsParallelTrue -And -Not $on) {
			ReplaceInFile $GradleProperties $ParallelTrue $ParallelFalse
		}
		if (-Not $IsParallelTrue -And $on){
			ReplaceInFile $GradleProperties $ParallelFalse $ParallelTrue
		}
}

function system($MachineNumber) {
	$ZhMachines = 1, 2
	$BpMachines = 3, 4
	If(-Not $ZhMachines.Contains($MachineNumber) -And -Not $BpMachines.Contains($MachineNumber)) {
		Write-Host "ERROR - Invalid system test target: " $MachineNumber
		Write-Host "The accepted machine numbers are: " $ZhMachines $BpMachines
		return
	}
	$MachineDomain = If ($ZhMachines.Contains($MachineNumber)) {".zh.adnovum.ch"} Else {".bp.adnovum.hu"}
	$TargetMachine = "nevisauth-fido-test" + $MachineNumber + $MachineDomain
	Write-Host "System testing against machine: " $TargetMachine
	
	$KarateConfig = "system-test/src/test/resources/karate-config.js"
	$OriginalMachine = "nevisauth-fido-test1.zh.adnovum.ch"
	ReplaceInFile $KarateConfig $OriginalMachine $TargetMachine
	gw systemTest
	ReplaceInFile $KarateConfig $TargetMachine $OriginalMachine
}

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