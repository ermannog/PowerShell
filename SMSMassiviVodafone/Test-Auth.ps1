$registrationEmail = "registration email address"
$apiPassword ="API Password" 

# Authenticate using a user token
$url = "https://smsmassivi.vodafone.it/API/v1.0/REST/token"

$authHeader = [Convert]::ToBase64String([Text.Encoding]::ASCII.GetBytes("${registrationEmail}:$apiPassword"))

$headers = @{
    "Content-Type" = "application/json"
    "Authorization" = "Basic $authHeader"
}


$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers

# Authenticate Response
$userKey = ($response -split ';')[0]
$accessToken = ($response -split ';')[1]

Write-Host "USER_KEY: $userKey"
Write-Host "ACCESS_TOKEN: $accessToken"