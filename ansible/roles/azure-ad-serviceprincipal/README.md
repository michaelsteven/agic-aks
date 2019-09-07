# Role azure-ad-serviceprincipal

## purpose:
- Checks if the service principal exists already by looking in Active Directory
- If it doesn't exist:
-- Creates an AD Service Principal, which will show in "App Registrations" in Azure
-- Creates secrets in the "master_key_vault" for the app-id and password

