#### Parameters

$keyvaultname = "aksdemocluster-kv08"
$location = "west us"
$keyvaultrg = "aksdemo-rg"
$sshkeysecret = "tahapubkey"
$spnclientid = "68c66e43-1eba-4376-949e-c5f119f5310f"
$clientidkvsecretname = "spn-id"
$spnclientsecret = "97643130-67da-4727-89eb-33215d7d417a"
$spnkvsecretname = "spn-secret"
$spobjectID = "2fb535ac-8863-450a-b7ef-4d40afe9082f"
$userobjectid = "100b6f6d-36d1-4a37-8a23-6e43cfda6278"


#### Create Key Vault

New-AzResourceGroup -Name $keyvaultrg -Location $location

New-AzKeyVault -Name $keyvaultname -ResourceGroupName $keyvaultrg -Location $location

Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -UserPrincipalName $userobjectid -PermissionsToSecrets get,set,delete,list

#### create an ssh key for setting up password-less login between agent nodes.

ssh-keygen  -f ~/.ssh/id_rsa_terraform


#### Add SSH Key in Azure Key vault secret

$pubkey = cat ~/.ssh/id_rsa_terraform.pub

$Secret = ConvertTo-SecureString -String $pubkey -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $sshkeysecret -SecretValue $Secret


#### Store service principal Client id in Azure KeyVault

$Secret = ConvertTo-SecureString -String $spnclientid -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $clientidkvsecretname -SecretValue $Secret


#### Store service principal Secret in Azure KeyVault

$Secret = ConvertTo-SecureString -String $spnclientsecret -AsPlainText -Force

Set-AzKeyVaultSecret -VaultName $keyvaultname -Name $spnkvsecretname -SecretValue $Secret


#### Provide Keyvault secret access to SPN using Keyvault access policy

Set-AzKeyVaultAccessPolicy -VaultName $keyvaultname -ServicePrincipalName $spobjectID -PermissionsToSecrets Get,Set