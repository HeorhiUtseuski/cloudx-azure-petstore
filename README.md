# Module 6

### Prerequisites 

* Install az-cli
    - login 
        `az login`

  - Run bicep script by
  ```
    az deployment <SCOPE> create \
        --name <NAME_OF_DEPLOYMENT> \
        --resource-group <RESOURCE_GROUP_NAME> \
        --template-file <PATH_TO_SCRIPT> \
        --parameters <LIST_OF_PARAMENTERS>
  ```
  Where:
* **SCOPE** - ['sub', 'group'], step1 run used *'sub'*, other steps *'group'*
* **RESOURCE_GROUP_NAME** - skipped for step1
* **PATH_TO_SCRIPT** - relative path to bicep file
* **LIST_OF_PARAMENTERS** - list of <key>=<value> parameters separated with space


## Install steps:
1. Run script *_./bicep/step1.bicep_*
    ```
   az deployment sub create --name InitDeploy --location westeurope --template-file ./bicep/step1.bicep --parameters resourceGroupName=petStoreModule6
   ```
2. Run script *_./bicep/step2.bicep_*
    ```
    az deployment group create --name ResourcesDeploy --resource-group petStoreModule6 --template-file ./bicep/step2.bicep
    ```
3. Create secrets on GitHub:
- ACR_LOGIN_SERVER - Azure Container Registry Login server
- ACR_USERNAME - Azure Container Registry Admin Login
- ACR_PASSWORD - Azure Container Registry Admin Password
Make any change in code and push for triggered action