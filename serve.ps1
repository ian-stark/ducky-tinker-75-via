param([int]$Port = 8766)
$ErrorActionPreference = 'Stop'
$listener = [Net.Sockets.TcpListener]::new([Net.IPAddress]::Loopback, $Port)
$listener.Start()
$root = $PSScriptRoot
Write-Host "Serving Project D configurator at http://localhost:$Port/"
while ($true) {
  $client = $listener.AcceptTcpClient()
  $stream = $client.GetStream()
  $reader = [IO.StreamReader]::new($stream)
  $requestLine = $reader.ReadLine()
  while ($reader.ReadLine() -ne '') { }
  $relative = (($requestLine -split ' ')[1]).TrimStart('/')
  if ([string]::IsNullOrWhiteSpace($relative)) { $relative = 'index.html' }
  $path = Join-Path $root $relative
  if (Test-Path -LiteralPath $path -PathType Leaf) {
    $body = [IO.File]::ReadAllBytes($path)
    $status = '200 OK'
    $type = if ($path.EndsWith('.html')) { 'text/html' } elseif ($path.EndsWith('.json')) { 'application/json' } else { 'text/plain' }
  } else {
    $body = [Text.Encoding]::UTF8.GetBytes('Not found')
    $status = '404 Not Found'
    $type = 'text/plain'
  }
  $header = [Text.Encoding]::ASCII.GetBytes("HTTP/1.1 $status`r`nContent-Type: $type`r`nContent-Length: $($body.Length)`r`nConnection: close`r`n`r`n")
  $stream.Write($header, 0, $header.Length)
  $stream.Write($body, 0, $body.Length)
  $stream.Close()
  $client.Close()
}
