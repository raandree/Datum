class FileProvider : DatumProvider
{
    hidden [string]$Path
    hidden [hashtable] $Store
    hidden [hashtable] $DatumHierarchyDefinition
    hidden [hashtable] $StoreOptions
    hidden [hashtable] $DatumHandlers
    hidden [string] $Encoding

    FileProvider ($Path, $Store, $DatumHierarchyDefinition, $Encoding)
    {
        $this.Store = $Store
        $this.DatumHierarchyDefinition = $DatumHierarchyDefinition
        $this.StoreOptions = $Store.StoreOptions
        $this.Path = Get-Item $Path -ErrorAction SilentlyContinue
        $this.DatumHandlers = $DatumHierarchyDefinition.DatumHandlers
        $this.Encoding = $Encoding

        $result = Get-ChildItem -Path $path | ForEach-Object {
            if ($_.PSIsContainer)
            {
                $val = [scriptblock]::Create("New-DatumFileProvider -Path `"$($_.FullName)`" -Store `$this.DataOptions -DatumHierarchyDefinition `$this.DatumHierarchyDefinition -Encoding `$this.Encoding")
                $this | Add-Member -MemberType ScriptProperty -Name $_.BaseName -Value $val
            }
            else
            {
                $val = [scriptblock]::Create("Get-FileProviderData -Path `"$($_.FullName)`" -DatumHandlers `$this.DatumHandlers -Encoding `$this.Encoding")
                $this | Add-Member -MemberType ScriptProperty -Name $_.BaseName -Value $val
            }
        }
    }
}
