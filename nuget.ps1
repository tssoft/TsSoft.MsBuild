del TsSoft.MsBuild.*.nupkg
del *.nuspec
del .\TsSoft.MsBuild\bin\Release\*.nuspec

function GetNodeValue([xml]$xml, [string]$xpath)
{
	return $xml.SelectSingleNode($xpath).'#text'
}

function SetNodeValue([xml]$xml, [string]$xpath, [string]$value)
{
	$node = $xml.SelectSingleNode($xpath)
	if ($node) {
		$node.'#text' = $value
	}
}

Remove-Item .\TsSoft.MsBuild\bin -Recurse 
Remove-Item .\TsSoft.MsBuild\obj -Recurse 

$build = "c:\Windows\Microsoft.NET\Framework64\v4.0.30319\MSBuild.exe ""TsSoft.MsBuild\TsSoft.MsBuild.csproj"" /p:Configuration=Release" 
Invoke-Expression $build

$Artifact = (resolve-path ".\TsSoft.MsBuild\bin\Release\TsSoft.MsBuild.dll").path

nuget spec -F -A $Artifact

Copy-Item .\TsSoft.MsBuild.nuspec.xml .\TsSoft.MsBuild\bin\Release\TsSoft.MsBuild.nuspec

$GeneratedSpecification = (resolve-path ".\TsSoft.MsBuild.nuspec").path
$TargetSpecification = (resolve-path ".\TsSoft.MsBuild\bin\Release\TsSoft.MsBuild.nuspec").path

[xml]$srcxml = Get-Content $GeneratedSpecification
[xml]$destxml = Get-Content $TargetSpecification
$value = GetNodeValue $srcxml "//version"
SetNodeValue $destxml "//version" $value;
$value = GetNodeValue $srcxml "//description"
SetNodeValue $destxml "//description" $value;
$value = GetNodeValue $srcxml "//copyright"
SetNodeValue $destxml "//copyright" $value;
$destxml.Save($TargetSpecification)


nuget pack $TargetSpecification

del *.nuspec
del .\TsSoft.MsBuild\bin\Release\*.nuspec

exit
