# values for your subscription and resource group
subscription_id=YOUR_SUBSCRIPTION_ID
resource_group=YOUR_RESOURCE_GROUP
location=YOUR_LOCATION_NAME

subscription_id=a2173e44-bdd4-4f0e-97ca-adb44fb5e107
resource_group=tmp-0210
location=japanwest

# Get random numbers to create unique resource names
unique_id=$RANDOM$RANDOM
STORAGE_ACCT_NAME=ai102form${unique_id}

echo Creating storage...
az storage account create --name $STORAGE_ACCT_NAME --subscription $subscription_id --resource-group $resource_group --location $location --sku Standard_LRS --encryption-services blob --default-action Allow --output none

echo Uploading files...
# Hack to get storage key
key_json=$(az storage account keys list --subscription ${subscription_id} --resource-group ${resource_group} --account-name $STORAGE_ACCT_NAME --query "[?keyName=='key1']")
AZURE_STORAGE_KEY=$(echo $key_json | jq '.[].value')

az storage container create --account-name $STORAGE_ACCT_NAME --name margies --public-access blob --auth-mode key --account-key $AZURE_STORAGE_KEY --output none
az storage blob upload-batch -d margies -s data --account-name $STORAGE_ACCT_NAME --auth-mode key --account-key $AZURE_STORAGE_KEY  --output none

echo Creating cognitive services account...
az cognitiveservices account create --kind CognitiveServices --location $location --name ai102cog${unique_id} --sku S0 --subscription $subscription_id --resource-group $resource_group --yes --output none

echo Creating search service...
echo "(If this gets stuck at '- Running ..' for more than a minute, press CTRL+C then select N)"
az search service create --name ai102srch${unique_id} --subscription $subscription_id --resource-group $resource_group --location $location --sku basic --output none

echo -------------------------------------
echo Storage account: $STORAGE_ACCT_NAME
az storage account show-connection-string --subscription $subscription_id --resource-group $resource_group --name $STORAGE_ACCT_NAME
echo ----
echo Cognitive Services account: ai102cog${unique_id}
az cognitiveservices account keys list --subscription $subscription_id --resource-group $resource_group --name ai102cog${unique_id}
echo ----
echo Search Service: ai102srch${unique_id}
echo  Url: https://ai102srch${unique_id}.search.windows.net
echo  Admin Keys:
az search admin-key show --subscription $subscription_id --resource-group $resource_group --service-name ai102srch${unique_id}
echo  Query Keys:
az search query-key list --subscription $subscription_id --resource-group $resource_group --service-name ai102srch${unique_id}

