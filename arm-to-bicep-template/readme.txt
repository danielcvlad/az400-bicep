The main goal of the exercise is to deploy a VM in Azure Portal and then export the ARM JSON template from the Export Template function.

Once the template has been exported, we are required to modify it to a bicep template as mentioned in the Intermediate Bicep Training from Microsoft Learn.

Once we have the bicep template converted, we then proceed to rebuild the bicep template by modifying it based on best practices.

Finally, we deploy the Bicep file against our environment in Azure by using both Incremental and Complete Mode with the -WhatIf switch to confirm that the script once deployed does not break our existing environment.

Resources: 
https://learn.microsoft.com/en-us/training/modules/migrate-azure-resources-bicep/