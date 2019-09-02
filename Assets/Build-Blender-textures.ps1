$wshell = New-Object -ComObject Wscript.Shell
$title = "Space Engineers Build Blender textures v1.2"

#START config options

# set the following to tell the script where to find/put things
# Microsoft DirectTex - can be obtained from - https://github.com/Microsoft/DirectXTex/releases
$texconv_raw = "D:\Modding\SpaceEngineers\Utils\TextureConverter\texconv.exe"
# space engineers game directory
# (p.s. you can run this script twice for two differnt sources to build both the Dx11 and Dx9 textures)
$game_dir_raw = "D:\Steam\steamapps\common\SpaceEngineers"
# space engineers modsdk directory
$sdk_dir_raw = "D:\Steam\steamapps\common\SpaceEngineersModSDK"
# resource directory - where you would like the output to be kept (what you then tell blender to use)
$resource_dir_raw = "D:\Modding\SpaceEngineers\Source"

#END config options

$texconv = Get-Item -Path $texconv_raw
if(-not $texconv)
{
    $wshell.Popup("Could not find the texconv in '$texconv_raw'", 0, $title, 0x0)
    exit 1
}

$game_dir = Get-Item -Path $game_dir_raw -ErrorAction SilentlyContinue

if(-not $game_dir)
{
    $wshell.Popup("Could not find the Game directory at:- $game_dir_raw", 0, $title, 0x0)
    exit 1
}

$sdk_dir = Get-Item -Path $sdk_dir_raw -ErrorAction SilentlyContinue

if(-not $game_dir)
{
    $wshell.Popup("Could not find the Game SDK directory at:- $sdk_dir_raw", 0, $title, 0x0)
    exit 1
}

$resource_dir = Get-Item -Path $resource_dir_raw -ErrorAction SilentlyContinue

if(-not $resource_dir)
{
    $create_resource_dir = $wshell.popup("Could not find Resource Directory at $resource_dir_raw. Do you want to create one?", 0,$title, 4)
    if ($create_resource_dir -eq 6) {
        $null = New-Item -ItemType Directory -Path $resource_dir_raw 
        $resource_dir = Get-Item -Path $resource_dir_raw -ErrorAction SilentlyContinue
    } else {
        $wshell.Popup("Could not find the Game directory at:- $resource_dir_raw", 0, $title, 0x0)
        exit 1
    }
}

Write-Output "Building Source Folder. This may take some time."

Try{
    Write-Output "Getting EXE Files"
    $se_exe_dir = $resource_dir.FullName + "\bin64"
    $se_exe = $resource_dir.FullName + "\bin64\SpaceEngineers.exe"
    $null = New-Item -ItemType Directory -Path $se_exe_dir -ErrorAction SilentlyContinue
    $null = New-Item -ItemType File -Path $se_exe -ErrorAction SilentlyContinue

    Write-Output "Getting Materials Files"
    $se_materials_dir = $resource_dir.FullName + "\Content\Materials\"
    $sdk_materials_dir = $sdk_dir.FullName + "\OriginalContent\Materials\*"
    $null = New-Item -ItemType Directory -Path $se_materials_dir -ErrorAction SilentlyContinue
    $null = Copy-Item $sdk_materials_dir -Destination $se_materials_dir -Recurse -force
    
    Write-Output "Getting Model Files"
    $se_materials_dir = $resource_dir.FullName + "\Content\Models\"
    $sdk_materials_dir = $sdk_dir.FullName + "\OriginalContent\Models\*"
    $null = New-Item -ItemType Directory -Path $se_materials_dir -ErrorAction SilentlyContinue
    $null = Copy-Item $sdk_materials_dir -Destination $se_materials_dir -Recurse -force

    Write-Output "Converting Texture Files"
    foreach ($item in Get-ChildItem -Path $game_dir.FullName -Recurse){
        Write-Output "Converting $item"
		$rel_path = $item.FullName.Replace($game_dir.FullName, "")
		$dst_path = $resource_dir.FullName + $rel_path
		if($item -is [System.IO.DirectoryInfo]){
			if($rel_path -like "\Content\Textures\*"){
				"Processing " + $dst_path
				$null = New-Item -Path $dst_path -ItemType Directory -ErrorAction SilentlyContinue
			}
			elseif($rel_path -like "\Content"){
				"Processing " + $dst_path
				$null = New-Item -Path $dst_path -ItemType Directory -ErrorAction SilentlyContinue
			}
		}else{
			if($rel_path -like "\Content\Textures\*"){
				if($item -like "*.dds"){
					$rel_dir = $item.Directory.FullName.Replace($game_dir.FullName, "")
					$dst_dir = $resource_dir.FullName + $rel_dir
					#"Loc: "+ $item.FullName +", Rel: " + $rel_dir + ", " + $dst_dir

					$null = & $texconv -y -f BC3_UNORM -ft dds -o $dst_dir $item.FullName
					if($lastExitCode){
						Write-Output "Somethign went wrong with the last convert"
						exit 1
					}
					$name = $dst_dir + "\" + $item.BaseName
					$uc_name = $name +".DDS"
					$lc_name = $item.BaseName +".dds"
					Rename-Item -Path $uc_name -NewName $lc_name -Force
				}
			}
		}
    }
}
Catch
{
    $ErrorMessage = $_.Exception.Message
    $wshell.Popup("Convert Failed: $ErrorMessage", 0, $title, 0x0)
    exit 1
}
