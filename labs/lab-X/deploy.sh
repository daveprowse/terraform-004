#!/bin/bash
set -e

echo "🏰 Lab-X Deployment Script 🏰"
echo "================================"
echo ""

# Check if terraform.tfvars exists
if [ ! -f terraform.tfvars ]; then
    echo "❌ Error: terraform.tfvars not found!"
    echo ""
    echo "Please create it first:"
    echo "  cp terraform.tfvars.example terraform.tfvars"
    echo "  # Edit terraform.tfvars with your info"
    exit 1
fi

# Run terraform init
echo "📦 Initializing Terraform..."
terraform init

# Run terraform plan
echo ""
echo "📋 Planning deployment..."
terraform plan -out=tfplan

# Ask for confirmation
echo ""
read -p "Deploy infrastructure? (yes/no): " confirm
if [ "$confirm" != "yes" ]; then
    echo "Deployment cancelled."
    rm -f tfplan
    exit 0
fi

# Apply terraform
echo ""
echo "🚀 Deploying infrastructure..."
terraform apply tfplan
rm -f tfplan

# Get outputs
echo ""
echo "📊 Getting deployment information..."
ZORK_IP=$(terraform output -raw zork_public_ip)
DOCS_IP=$(terraform output -raw docs_public_ip)
ZORK_URL=$(terraform output -raw zork_url)
DOCS_URL=$(terraform output -raw docs_url)

echo ""
echo "✅ Infrastructure deployed!"
echo ""
echo "Instances created:"
echo "  ZORK Server: $ZORK_IP"
echo "  Docs Server: $DOCS_IP"
echo ""
echo "⏳ Waiting for user-data scripts to complete..."
echo "   This takes 2-4 minutes (installing packages, downloading ZORK)"
echo ""

# Function to check if server is ready
check_server() {
    local ip=$1
    local name=$2
    local max_attempts=60  # 5 minutes (60 * 5 seconds)
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        attempt=$((attempt + 1))
        
        # Try to curl the server
        if curl -s -f -m 5 "http://$ip" > /dev/null 2>&1; then
            # Check if setup is complete (marker file exists)
            if ssh -o StrictHostKeyChecking=no -o ConnectTimeout=5 -i lab-x-key.pem ubuntu@$ip "test -f /var/www/html/.setup-complete" 2>/dev/null; then
                echo "   ✅ $name ready! ($attempt attempts, ~$((attempt * 5)) seconds)"
                return 0
            fi
        fi
        
        # Show progress every 6 attempts (30 seconds)
        if [ $((attempt % 6)) -eq 0 ]; then
            echo "   ⏳ Still waiting for $name... ($((attempt * 5))s elapsed)"
        fi
        
        sleep 5
    done
    
    echo "   ❌ $name did not become ready in time (5 minutes)"
    return 1
}

# Wait for both servers
ZORK_READY=0
DOCS_READY=0

check_server "$ZORK_IP" "ZORK Server" && ZORK_READY=1 || ZORK_READY=0
check_server "$DOCS_IP" "Docs Server" && DOCS_READY=1 || DOCS_READY=0

echo ""
echo "================================"
echo ""

if [ $ZORK_READY -eq 1 ] && [ $DOCS_READY -eq 1 ]; then
    echo "🎉 SUCCESS! Lab-X is ready!"
    echo ""
    echo "🎮 ZORK Game:"
    echo "   $ZORK_URL"
    echo ""
    echo "📚 Documentation:"
    echo "   $DOCS_URL"
    echo ""
    echo "🔑 SSH Access:"
    echo "   ZORK: ssh -i lab-x-key.pem ubuntu@$ZORK_IP"
    echo "   Docs: ssh -i lab-x-key.pem ubuntu@$DOCS_IP"
    echo ""
    echo "🏰 Have fun exploring the Great Underground Empire!"
elif [ $ZORK_READY -eq 0 ] && [ $DOCS_READY -eq 0 ]; then
    echo "⚠️  WARNING: Both servers failed to complete setup"
    echo ""
    echo "Troubleshooting steps:"
    echo "1. SSH to check logs:"
    echo "   ssh -i lab-x-key.pem ubuntu@$ZORK_IP"
    echo "   sudo tail -f /var/log/cloud-init-output.log"
    echo ""
    echo "2. Wait a bit longer and try accessing:"
    echo "   ZORK: $ZORK_URL"
    echo "   Docs: $DOCS_URL"
    echo ""
    echo "3. If still broken, destroy and retry:"
    echo "   ./destroy.sh"
    echo "   ./deploy.sh"
elif [ $ZORK_READY -eq 0 ]; then
    echo "⚠️  WARNING: ZORK server failed to complete setup"
    echo ""
    echo "Working:"
    echo "  ✅ Docs: $DOCS_URL"
    echo ""
    echo "Not working:"
    echo "  ❌ ZORK: $ZORK_URL"
    echo ""
    echo "Check ZORK server logs:"
    echo "  ssh -i lab-x-key.pem ubuntu@$ZORK_IP"
    echo "  sudo tail -f /var/log/cloud-init-output.log"
else
    echo "⚠️  WARNING: Docs server failed to complete setup"
    echo ""
    echo "Working:"
    echo "  ✅ ZORK: $ZORK_URL"
    echo ""
    echo "Not working:"
    echo "  ❌ Docs: $DOCS_URL"
    echo ""
    echo "Check docs server logs:"
    echo "  ssh -i lab-x-key.pem ubuntu@$DOCS_IP"
    echo "  sudo tail -f /var/log/cloud-init-output.log"
fi

echo ""
echo "🗑️  Remember to destroy when done:"
echo "   ./destroy.sh"
echo ""
