


<#
.SYNOPSIS
    Title   : Function Compute-GithubsFileHash - Computes Github SHA1 File Hash
    Author  : Jon Damvi
    Version : 1.0.0
    Date    : 19.05.2025
    License : MIT (LICENSE.txt)

   Release Notes: v1.0.0 (19.05.2025) - initial release.

.DESCRIPTION
    Computes Github SHA1 File Hash that is obtainable via Github API request:
    curl https://api.github.com/repos/<Author>/<RepositoryName>/contents/<FileName>?ref=<branch>,
    where <branch> usually is master.

.PARAMETER FilePath
    Specifies local file path to compute Github's file SHA-1 hash for.
    Mandatory. Expected type: [string]
    Aliases: File

.INPUTS
    None.

.OUTPUTS
    [string] (SHA-1 file hash string).

.EXAMPLE
    > Compute-GithubsFileHash -FilePath "C:\Temp\DownloadedFile.exe"

.LINK


.NOTES
    Compute's GitHub's SHA-1 file hash on local file.

#>
Function Compute-GithubsFileHash {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('File')]
        [string]$FilePath
    )
    # Read file content as bytes
    $fileBytes = [System.IO.File]::ReadAllBytes($FilePath)
    $fileSize = $fileBytes.Length

    # Prepare Git blob header: "blob <filesize>\0"
    $header = [Text.Encoding]::ASCII.GetBytes("blob $fileSize`0")

    # Combine header + file bytes
    $blobBytes = New-Object byte[] ($header.Length + $fileBytes.Length)
    [Array]::Copy($header, 0, $blobBytes, 0, $header.Length)
    [Array]::Copy($fileBytes, 0, $blobBytes, $header.Length, $fileBytes.Length)

    # Compute SHA1 hash
    $sha1 = [System.Security.Cryptography.SHA1]::Create()
    $hashBytes = $sha1.ComputeHash($blobBytes)

    # Convert hash bytes to hex string
    $hashString = [BitConverter]::ToString($hashBytes) -replace "-", ""
    $hashString = $hashString.ToLower()

    return $hashString
}

<#
.SYNOPSIS
    Title   : Validate-GithubsFileHash - Validates Github SHA1 File Hash on local file
    Author  : Jon Damvi
    Version : 1.0.0
    Date    : 19.05.2025
    License : MIT (LICENSE.txt)

   Release Notes: v1.0.0 (19.05.2025) - initial release.

.DESCRIPTION
    Validates local file hash against specified known Github SHA1 file Hash by comparing with computed GitHub's SHA1 file hash.

.PARAMETER FilePath
    Specifies local file path to compute Github's file SHA-1 hash for.
    Mandatory. Expected type: [string]
    Aliases: File

.PARAMETER ExpectedFileHash
    Specifies local file Github's file SHA-1 hash string to check file against.
    Mandatory. Expected type: [string]
    Aliases: FileHash, Hash

.PARAMETER NoTextOutput
    Disables text output of result.
    If specified, function will return $true on success and $false on failure.
    Optional. Expected type: [switch]
    Aliases: Silent, q

.INPUTS
    None.

.OUTPUTS
    [string] (Success/Failure message - default behavior).
    [bool]   ($true/$false - if -NoTextOutput switch enabled).

.EXAMPLE
    # Check file Hash obtained from:
    # https://github.com/microsoft/Microsoft-Win32-Content-Prep-Tool/blob/master/IntuneWinAppUtil.exe
    # GitHub SHA1 File hash obtained by GitHub API request from "sha" output property using following command: 
    # curl https://api.github.com/repos/microsoft/Microsoft-Win32-Content-Prep-Tool/contents/IntuneWinAppUtil.exe?ref=master
    > Validate-GithubsFileHash -FilePath "C:\Temp\IntuneWinAppUtil.exe" -Hash "218e08549a6f3d9ad006ec81d61ce3d224f5539e"

.LINK


.NOTES
    Compute's GitHub's SHA-1 file hash on local file.

#>
Function Validate-GithubsFileHash {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('File')]
        [string]$FilePath,

        [Parameter(Mandatory)]
        [ValidateNotNullOrEmpty()]
        [Alias('FileHash','Hash')]
        [string]$ExpectedFileHash,

        [Alias('Silent','q')]
        [switch]$NoTextOutput
    )
    $CalculatedFileHash = Compute-GithubsFileHash $FilePath
    If ($CalculatedFileHash -ieq $ExpectedFileHash) {
        If (-Not $NoTextOutput) {
            Write-Host "SUCCESS: Hashes match!" -ForegroundColor Green
        }
        If ($NoTextOutput) { return $true }
    } Else {
        If (-Not $NoTextOutput) {
            Write-Host "FAILURE: Hashes do NOT match!" -ForegroundColor Red
        }
    }
    If ($NoTextOutput) { return $false }
}

# Usage Example, uncomment and adjust to test:

# Validate-GithubsFileHash "C:\Temp\ExampleFile.ps1" 'aa8e08549a6f3d9ad006ec81d61ce3d224f5539e'





