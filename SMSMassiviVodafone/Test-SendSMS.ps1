$userKey = "USER KEY"
$accessToken = "ACCESS TOKEN"
$recipient = "Numero del destinatario (in formato internazionale)"
$sender = "Mittente (può essere il nome o un numero breve)"
$message = "Messaggio di prova inviato tramite API SMS Massivi Vodafone."


# Send an SMS message
$url = "https://smsmassivi.vodafone.it/API/v1.0/REST/sms"

$headers = @{
    "Content-Type"  = "application/json"
    "user_key"      = $userKey
    "Access_token"  = $accessToken
}


$body = @{
    message_type = "L"                                   # SMS senza notifica
    message = $message                                   # Messaggio da inviare
    recipient = @($recipient)                            # Lista dei destinatari
    sender = $sender                                     # Mittente
    returnCredits = $true                                # Restituisce i crediti rimanenti
} | ConvertTo-Json


$response = Invoke-RestMethod -Uri $url -Method Post -Headers $headers -Body $body

Write-Host "Result: $($response.result)"
Write-Host "Used credit: $($response.used_credits)"
Write-Host "Total sent: $($response.total_sent)"
Write-Host "Order id: $($response.order_id)"
Write-Host "Internal order id: $($response. internal_order_id)"
