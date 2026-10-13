#!/bin/bash

# Script to automate the setup of GlideinWMS ITB environment using podman

# Step 1: Set up working directory
WORKDIR="/myworkdir"
mkdir -p "$WORKDIR/ws-test"
cd "$WORKDIR/ws-test" || exit 1
TEST_DIR=$(pwd)
# Step 2: Clone the GlideinWMS containers repository (check if repo already exists)
if [ ! -d "containers" ]; then
    git clone https://github.com/glideinWMS/containers.git
fi
cd containers/workspaces || exit 1

CONTAINER_NAMES=("ce-workspace.glideinwms.org" "factory-workspace.glideinwms.org" "frontend-workspace.glideinwms.org")

# Loop through each container name and remove if it exists
for CONTAINER_NAME in "${CONTAINER_NAMES[@]}"; do
    if podman ps -a --format "{{.Names}}" | grep -q "$CONTAINER_NAME"; then
        echo "Removing existing container with name $CONTAINER_NAME..."
        podman rm -f "$CONTAINER_NAME"
    fi
done
# Step 3: Pull the GlideinWMS images (optional namespace for different repo)
export IMAGE_NAMESPACE=${IMAGE_NAMESPACE:-"docker.io/glideinwms"} 
podman-compose pull


# Step 4: Set up a directory for GWMS if not provided
#GWMS_PATH="${GWMS_PATH:-$TEST_DIR/gwms}" # don't worry about this step (for now)
#mkdir -p "$GWMS_PATH"

# Step 5: Start the containers
podman-compose up -d

htgettoken -a htvaultprod.fnal.gov -i hypot -r production --credkey=hypotpro/managedtokens/fifeutilgpvm03.fnal.gov -o /tmp/frontend.scitoken

podman cp /tmp/frontend.scitoken frontend-workspace.glideinwms.org:/var/lib/gwms-frontend/.condor/tokens.d/frontend-workspace.glideinwms.org.scitoken
#
# execute commands to run tests inside the containers
#
#podman exec -it frontend-workspace.glideinwms.org /root/scripts/run-test.sh

# Step 7: Bring down the containers on script exit
#cleanup() {
#    echo "Bringing down the containers..." # comment this step for future use
#    podman-compose down
#}
#trap cleanup EXIT

# Step 8: Optional: Using SL7 images and containers (change IMAGE_LABEL as needed)
#read -p "Do you want to use SL7 images? (y/n) " USE_SL7
#if [[ $USE_SL7 == "y" ]]; then
#    IMAGE_LABEL="sl7_latest-20240717-0328" # this can be implemented later, but should be called before step 3
#    podman-compose pull
#    podman-compose up -d
#fi

# Step 9: Provide useful commands
echo "Useful commands:"
echo "List containers: podman ps -a"
echo "List images: podman images"
echo "Start container scripts:"
echo "podman exec -it ce-workspace.glideinwms.org /root/scripts/startup.sh"
echo "podman exec -it factory-workspace.glideinwms.org /root/scripts/startup.sh"
echo "podman exec -it frontend-workspace.glideinwms.org /root/scripts/startup.sh"
echo "Run tests:"
echo "podman exec -it frontend-workspace.glideinwms.org /root/scripts/run-test.sh"
echo "Shell access:"
echo "podman exec -it ce-workspace.glideinwms.org /bin/bash"
echo "podman exec -it factory-workspace.glideinwms.org /bin/bash"
echo "podman exec -it frontend-workspace.glideinwms.org /bin/bash"


