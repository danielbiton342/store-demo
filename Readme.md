# **Secure and Scalable Microservices Deployment on Azure AKS**

## **Table of Contents**
- [**Secure and Scalable Microservices Deployment on Azure AKS**](#secure-and-scalable-microservices-deployment-on-azure-aks)
  - [**Table of Contents**](#table-of-contents)
  - [**Project Overview**](#project-overview)
  - [**Application Architecture**](#application-architecture)
  - [**Infrastructure Benefits**](#infrastructure-benefits)
  - [**Setting Up the Infrastructure**](#setting-up-the-infrastructure)
    - [**Terraform Configuration**](#terraform-configuration)
    - [terraform.tfvars](#terraformtfvars)
    - [Setting up the application](#setting-up-the-application)
  - [Horizontal Pod Autoscaling](#horizontal-pod-autoscaling)
- [Clean up](#clean-up)

---

## **Project Overview**
This project demonstrates the deployment of a secure and scalable microservices architecture on **Azure Kubernetes Service (AKS)**. It leverages best practices such as infrastructure-as-code (Terraform), container orchestration (AKS), and secure secret management with Azure Key Vault.

---

## **Application Architecture**
The application architecture is illustrated in the following diagram:  
![Application Diagram](./photos/pic1.png)

---

## **Infrastructure Benefits**
- **Scalability**: Leverages Kubernetes' Horizontal Pod Autoscaler to handle dynamic traffic.
- **Security**: Secure integration with Azure Key Vault for managing sensitive application secrets.
- **Automation**: Terraform automates infrastructure provisioning and ensures consistency.
- **Cost Efficiency**: Resources scale automatically based on demand, reducing over-provisioning.

---

## **Setting Up the Infrastructure**

### **Terraform Configuration**
1. **Blob Storage for Terraform State**  
   Create a Blob Storage resource to manage Terraform state:  
   ```bash
   ./tf-state-setup.sh
   ```

### terraform.tfvars
create terraform.tfvars on terraform dir.
Generate an ssh key RSA, or use an existing one and store it as "ssh_key".
Retrieve the object ID of your user AAD
```bash
az ad user list --display-name "Your Name"
```
Then store it as "object_id" in terraform.tfvars


change the relevant values on versions.tf
```bash
terraform init
```

apply the configuration 
```bash
terraform apply
```
login into the ACR and pushing the first version of the application images into ACR
```bash
./acr-init.sh
```

### Setting up the application
Establishing connection between aks to key vault with Service Connector, insert the relevant values
```bash
az aks connection create keyvault \
  --enable-csi \
  --resource-group <resource-group> \
  --name <cluster-nme> \
  --target-resource-group <key vault resource-group> \
  --vault <name of keyvault>
```

connect to aks CLI 
```bash
az aks get-credentials --resource-group <resource-group-name> --name <aks-cluster-name>
```

install the helm of secret store csi driver: https://secrets-store-csi-driver.sigs.k8s.io/getting-started/installation.html
```bash
helm repo add secrets-store-csi-driver https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts
helm install csi-secrets-store secrets-store-csi-driver/secrets-store-csi-driver --namespace kube-system
```

apply provider azure installer
```bash
kubectl apply -f provider-azure-installer.yaml
```
Make sure the pods are running
```bash
kubectl get pods -l app=csi-secrets-store-provider-azure
```
![provider](./photos/pic3.png)


Retrieve your tenant ID and keep it for next step:
```bash
az account tenant list
```

figure out what is the userAssignedIdentityID, first see which resource group has the identity
```bash
az identity list --query "[?name=='azurekeyvaultsecretsprovider-myakscluster'].{Name:name, ResourceGroup:resourceGroup}" -o table
```

then run the command to list the identity details and keep the Client ID
```bash
az identity show --name azurekeyvaultsecretsprovider-myakscluster --resource-group <CORRECT_RESOURCE_GROUP>
```

Now replace the "clientId" and "Tenantid" in secret_provider_class.yaml
![secret_provider](./photos/pic2.png)

Apply the secret provider class file to your cluster:
```bash
kubectl apply -f secret_provider_class.yaml
```

apply the application file
```bash
kubectl apply -f aks-store.yaml
```
![get_pods](./photos/pic4.png)

## Horizontal Pod Autoscaling
In case there is high traffic that a single pod cannot handle, we can use a powerful kubernetes feature called "HorizontalPodAutoscaler", it will allow the kubernetes to know when it should increase the numbers of pods according to our configuration and conditions.
```bash
kubectl apply -f aks-store-hpa.yaml
```
![hpa](./photos/pic5.png)


# Clean up
In order to clean up our resources we can run terraform destroy command:
```bash
terraform destroy
```

Then remove the tfstate resource group
```bash
az group delete --name tfstate --yes --no-wait
```