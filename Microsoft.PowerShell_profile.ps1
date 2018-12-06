Set-Location  "C:\Users\mezo\projects\nevisfido"
Set-Alias ll dir
Set-Alias gw ./gradlew
Set-Alias n "C:\Program Files (x86)\Notepad++\notepad++.exe"
$env:JAVA_HOME="C:\Program Files\Java\jdk1.8.0_161"

function cl() { gw clean --rerun-tasks }

function b() {
	$TestsToIgnore = @(
		'application/src/test/java/ch/nevis/auth/fido/uaf/application/resolver/CommandExecutorIntTest.java',
		'common/src/test/java/ch/nevis/auth/fido/uaf/common/filewatcher/DefaultPathChangeSupplierTest.java'
	)
	$PublicClass = 'public class'
	$Ignore = 'import org.junit.Ignore; @Ignore '
	
	ReplaceInFiles $TestsToIgnore $PublicClass ($Ignore + $PublicClass)
	SwitchParallel
	
	gw build
	
	ReplaceInFiles $TestsToIgnore $Ignore ''
	SwitchParallel
}

function ReplaceInFiles($Files, $What, $With) {
	foreach ($File in $Files) {
		ReplaceInFile $File $What $With
	}
}

function SwitchParallel() {
		$GradleProperties = 'gradle.properties'
		$ParallelTrue = 'org.gradle.parallel=true'
		$ParallelFalse = 'org.gradle.parallel=false'
		$IsParallelTrue = Get-Content $GradleProperties | Select-String $ParallelTrue
		if ($IsParallelTrue) {
			ReplaceInFile $GradleProperties $ParallelTrue $ParallelFalse
		} else {
			ReplaceInFile $GradleProperties $ParallelFalse $ParallelTrue
		}
}

function ReplaceInFile($File, $What, $With) {
	(Get-Content -path $File) -replace $What, $With | Set-Content $File
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
