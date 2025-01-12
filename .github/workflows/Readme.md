# Continuous Integration (CI) with GitHub Actions

## What is Continuous Integration (CI)?
Continuous Integration (CI) is a practice that automates the process of integrating code changes from multiple contributors into a shared repository. By running automated builds and tests, CI helps detect and fix issues early in the development lifecycle, improving software quality and speeding up delivery.

---

## Purpose of This CI Workflow
This GitHub Actions workflow streamlines the application lifecycle by:
1. **Building a Docker Image**: Automatically creates a new Docker image based on the application's latest code and is triggered by specific commit message key for each microservice.
2. **Testing the Image**: Ensures the application works as expected by running unit tests (if defined).
3. **Pushing to Azure Container Registry (ACR)**: Logs in to ACR using credentials stored in GitHub Secrets and pushes the Docker image to the ACR repository for future deployments.

---

## Key Benefits
- **Automated Builds and Tests**: Reduces manual intervention and ensures consistent quality.
- **Faster Deployments**: Prepares the application for deployment by pushing tested Docker images to ACR.
- **Improved Collaboration**: Integrates and validates code changes seamlessly in a shared repository.


