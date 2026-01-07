#!/bin/bash

function print_usage() {
    echo "Usage: $0 PROXMOX_HOST [OPTIONS]"
    echo "  PROXMOX_HOST    : Hostname/IP of your Proxmox server"
    echo ""
    echo "Options:"
    echo "  --vm-id ID      : VM/LXC ID to cleanup (default: 800)"
    echo "  --dry-run       : Show what would be done without making changes"
    echo "  --tf-path PATH  : Path to Terraform files (default: current directory)"
    echo ""
    echo "Examples:"
    echo "  $0 proxmox.local --vm-id 900"
    echo "  $0 192.168.1.100 --vm-id 850 --dry-run"
    echo "  $0 proxmox.local --vm-id 700 --tf-path /path/to/terraform"
    echo ""
    echo "Note: Script automatically detects whether ID is a VM or LXC container"
    exit 1
}

# Check if host argument is provided
if [ $# -lt 1 ]; then
    print_usage
fi

PROXMOX_HOST="$1"
shift  # Remove first argument, leaving any remaining flags

# Initialize variables
DRY_RUN=0
TF_PATH="."
VM_ID=800

# Parse remaining arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --vm-id)
            if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
                echo "Error: --vm-id requires a VM ID argument"
                print_usage
            fi
            # Validate that VM_ID is a number
            if ! [[ "$2" =~ ^[0-9]+$ ]]; then
                echo "Error: VM ID must be a number"
                exit 1
            fi
            VM_ID="$2"
            shift 2
            ;;
        --dry-run)
            DRY_RUN=1
            echo "Running in DRY RUN mode - no changes will be made"
            shift
            ;;
        --tf-path)
            if [[ -z "$2" ]] || [[ "$2" == --* ]]; then
                echo "Error: --tf-path requires a path argument"
                print_usage
            fi
            TF_PATH="$2"
            shift 2
            ;;
        *)
            echo "Error: Unknown option $1"
            print_usage
            ;;
    esac
done

echo "Starting cleanup process..."
echo "VM/LXC ID: ${VM_ID}"
echo "Proxmox Host: ${PROXMOX_HOST}"
echo "Terraform Path: ${TF_PATH}"
echo ""

# SSH into Proxmox and stop/delete VMs or LXC containers
echo "Connecting to ${PROXMOX_HOST}..."
if [ $DRY_RUN -eq 1 ]; then
    echo "[DRY RUN] Would SSH into ${PROXMOX_HOST} and execute:"
    echo "  - Detect if ${VM_ID} is a VM or LXC container"
    echo "  - Check and stop ${VM_ID} if running"
    echo "  - Delete ${VM_ID}"
else
    # Pass VM_ID as argument to the heredoc
    if ! ssh root@${PROXMOX_HOST} "bash -s ${VM_ID}" << 'EOFINNER'
    VM_ID=$1
    
    # Detect if this is a VM or LXC container
    if qm status ${VM_ID} &> /dev/null; then
        GUEST_TYPE="vm"
        COMMAND_PREFIX="qm"
        echo "Detected VM with ID ${VM_ID}"
    elif pct status ${VM_ID} &> /dev/null; then
        GUEST_TYPE="lxc"
        COMMAND_PREFIX="pct"
        echo "Detected LXC container with ID ${VM_ID}"
    else
        echo "Error: ID ${VM_ID} not found as either VM or LXC container"
        exit 1
    fi
    
    # Stop if running
    echo "Checking status of ${GUEST_TYPE} ${VM_ID}..."
    if ${COMMAND_PREFIX} status ${VM_ID} | grep -q "status: running"; then
        echo "Stopping ${GUEST_TYPE} ${VM_ID}..."
        ${COMMAND_PREFIX} stop ${VM_ID}
        
        # Wait for it to stop
        while ${COMMAND_PREFIX} status ${VM_ID} | grep -q "status: running"; do
            sleep 2
        done
        echo "${GUEST_TYPE} ${VM_ID} stopped successfully"
    else
        echo "${GUEST_TYPE} ${VM_ID} is not running"
    fi
    
    # Destroy the VM or container
    echo "Deleting ${GUEST_TYPE} ${VM_ID}..."
    ${COMMAND_PREFIX} destroy ${VM_ID}
    
    if [ $? -eq 0 ]; then
        echo "${GUEST_TYPE} ${VM_ID} deleted successfully"
    else
        echo "Error: Failed to delete ${GUEST_TYPE} ${VM_ID}"
        exit 1
    fi
EOFINNER
    then
        echo "Error: Failed to execute commands on Proxmox host"
        exit 1
    fi
fi

# Remove Terraform-related files
echo ""
echo "Cleaning up Terraform files in: ${TF_PATH}"
if [ $DRY_RUN -eq 1 ]; then
    echo "[DRY RUN] Would remove:"
    echo "  - ${TF_PATH}/terraform.lock.hcl file"
    echo "  - ${TF_PATH}/terraform.tfstate* files"
else
    # Check if the path exists
    if [ ! -d "$TF_PATH" ]; then
        echo "Warning: Terraform path '$TF_PATH' does not exist"
    else
        rm -f "${TF_PATH}/terraform.lock.hcl"
        rm -f "${TF_PATH}"/terraform.tfstate*
        echo "Terraform files cleaned up successfully"
    fi
fi

echo ""
echo "Cleanup completed successfully!"