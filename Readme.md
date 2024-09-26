# Terraform Project

To set up and initialize the Terraform project, follow these steps:

1. Create the infrastructure directory:

```bash
mkdir infra
cd infra
```

2. Initialize the Terraform project:

```bash
terraform init
```

This will initialize an empty project in the `./infra` directory.

3. Create a new workspace named 'dev':

```bash
terraform workspace new dev
```

This sets up a 'dev' environment for your Terraform configurations.

## Note

Ensure that you run all Terraform commands from within the `./infra` directory.
