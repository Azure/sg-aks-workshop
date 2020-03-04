# az storage creation for app.
STORAGE_ACCOUNT=${PREFIX}storage 

# create storage account
az storage account create -g $RG -n $STORAGE_ACCOUNT

# get the key
az storage account keys list -g $RG -n $STORAGE_ACCOUNT --query "[0].value"                                                                    ✔  10625  10:13:27

# create a secret
kubectl create secret generic fruit-secret \                                                                                                         ✔  10628  10:14:13
  --from-literal=azurestorageaccountname=$STORAGE_ACCOUNT \     
  --from-literal=azurestorageaccountkey=$STORAGE_KEY \         
  -n dev
