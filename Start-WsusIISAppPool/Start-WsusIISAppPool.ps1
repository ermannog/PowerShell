If ((Get-WebAppPoolState WsusPool).Value -ne 'Started')
{
  Start-WebAppPool WsusPool
}
