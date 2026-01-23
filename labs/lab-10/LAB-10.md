# ⚙️ Lab-10 - Terraform Testing

Basic Terraform project for AWS testing with infrastructure validation.

## Resources Created
- 1 AWS EC2 instance (t2.micro)
- 3 IAM users (test-user-1, test-user-2, test-user-3)

## Files
- `main.tf` - Main infrastructure configuration
- `variables.tf` - Input variables
- `outputs.tf` - Output values
- `tests/*.tftest.hcl` - Validation tests (3 files)
- `TESTING.md` - Detailed test documentation

## Usage

### Initialize
```bash
terraform init
```

### Test (Validation)
```bash
terraform test
```
Validates configuration (no resources created).

### Plan & Apply
```bash
terraform plan
terraform apply
```

### Validate Deployed Infrastructure
```bash
terraform plan -refresh-only
```

### Destroy
```bash
terraform destroy
```

See `TESTING.md` for detailed testing documentation.

## Directory Structure
```
terraform-catch-all/
├── main.tf
├── variables.tf
├── outputs.tf
├── tests/
│   ├── unit_basic.tftest.hcl
│   ├── iam_validation.tftest.hcl
│   └── custom_variables.tftest.hcl
└── docs...
```
