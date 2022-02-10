subscription_id=YOUR_SUBSCRIPTION_ID
resource_group=YOUR_RESOURCE_GROUP
location=YOUR_LOCATION_NAME
expiry_date=2030-01-01T00:00:00Z

unique_id=$RANDOM$RANDOM
STORAGE_ACCT_NAME=ai102form${unique_id}

echo Creating storage...
az storage account create --name $STORAGE_ACCT_NAME --subscription ${subscription_id} --resource-group ${resource_group} --location ${location} --sku Standard_LRS --encryption-services blob --default-action Allow --output none

echo Uploading files...
key_json=$(az storage account keys list --subscription ${subscription_id} --resource-group ${resource_group} --account-name $STORAGE_ACCT_NAME --query "[?keyName=='key1']")
AZURE_STORAGE_KEY=$(echo $key_json | jq '.[].value')

az storage container create --account-name $STORAGE_ACCT_NAME --name sampleforms --public-access blob --auth-mode key --account-key $AZURE_STORAGE_KEY --output none
az storage blob upload-batch -d sampleforms -s ./sample-forms --account-name $STORAGE_ACCT_NAME --auth-mode key --account-key $AZURE_STORAGE_KEY  --output none

SAS_TOKEN=$(az storage container generate-sas --account-name $STORAGE_ACCT_NAME --name sampleforms --expiry $expiry_date --permissions rwl | sed 's/"//g')

URI=https://${STORAGE_ACCT_NAME}.blob.core.windows.net/sampleforms?${SAS_TOKEN}

echo -------------------------------------
echo SAS URI: ${URI}
