$dest = "C:\ca-export\windows-root-certs"
if (Test-Path $dest) { Remove-Item -Recurse -Force $dest }
New-Item -ItemType Directory -Path $dest | Out-Null

$stores = @("Cert:\LocalMachine\Root","Cert:\LocalMachine\AuthRoot","Cert:\LocalMachine\CA")  # includes intermediate CA
foreach ($store in $stores) {
  Get-ChildItem -Path $store | ForEach-Object {
    $chain = New-Object System.Security.Cryptography.X509Certificates.X509Chain
    if ($chain.Build($_)) {
      $chain.ChainElements | ForEach-Object {
        $c = $_.Certificate
        $pem = "-----BEGIN CERTIFICATE-----`n" +
               [Convert]::ToBase64String($c.Export([System.Security.Cryptography.X509Certificates.X509ContentType]::Cert), [System.Base64FormattingOptions]::InsertLineBreaks) +
               "`n-----END CERTIFICATE-----`n"
        $fn = Join-Path $dest ("$($c.Thumbprint).pem")
        Add-Content -Path $fn -Value $pem
      }
    }
  }
}
Write-Host "Exported full certificate chains (root + intermediates) from: $($stores -join ', ')"
