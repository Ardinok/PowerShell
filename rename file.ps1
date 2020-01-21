Function RenameFile ($location, $filename)
{
    $d = Get-Date -uFormat "%Y%m%d"

    $old = $location + $filename
    $new = $filename + "_" + "bak" + "_" + $d

    Rename-Item $old $new
}
RenameFile -location "C:\" -filename "MichelleM"