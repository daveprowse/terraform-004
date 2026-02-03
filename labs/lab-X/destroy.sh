#!/bin/bash
set -e

echo "🗑️  Lab-X Destroy Script"
echo "================================"
echo ""
echo "⚠️  WARNING: This will destroy all infrastructure!"
echo ""

# Ask for confirmation
read -p "Are you sure you want to destroy everything? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Destroy cancelled."
    exit 0
fi

echo ""
echo "🔥 Destroying infrastructure..."
terraform destroy

echo ""
echo "✅ Infrastructure destroyed!"
echo ""
echo "Cleanup complete. Check for remaining local files:"
echo "  - lab-x-key.pem (SSH key)"
echo "  - terraform.tfvars (your configuration)"
echo "  - .terraform/ (Provider Plugins)"
echo "  - terraform.tfstate"
echo ""
echo "To remove all local files:"
echo "  rm -f lab-x-key.pem terraform.tfvars"
echo "  rm -rf .terraform terraform.tfstate*"
echo ""
