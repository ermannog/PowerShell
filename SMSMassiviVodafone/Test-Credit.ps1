$userKey = "USER KEY"
$accessToken = "ACCESS TOKEN"


# SMS Credits
$url = "https://smsmassivi.vodafone.it/API/v1.0/REST/status?getMoney=true&typeAliases=true"

$headers = @{
    "Content-Type"  = "application/json"
    "user_key"      = $userKey
    "Access_token"  = $accessToken
}

$response = Invoke-RestMethod -Uri $url -Method Get -Headers $headers


# SMS Credits Respose
Write-Host "Money: $($response.money)"

ForEach ($item in $($response.sms)) {
   Write-Host "SMS $($item.type): $($item.quantity)" 
}