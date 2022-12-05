# GlideinWMS Frontend Helm Chart
This repository contains a Helm chart that can be used to install a Kubernetes cluster with a GWMS frontend and HTCondor central manager.

## Installation
Kubernetes and Helm must be installed and a working Kubernetes cluster initialized as prerequisites.

### Kubernetes
Begin by installing a CRI-compatible container runtime such as [containerd](https://docs.docker.com/engine/install/). Note: containerd may disable the CRI plugin by default, and `kubeadm init` will fail saying it can't find a container runtime. If this happens, remove `"CRI"` from `disabled_plugins` in `/etc/containerd/config.toml`.

Install `kubelet`, `kubectl`, and `kubeadm` following the instructions [here](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/). Then initialize your cluster using [kubeadm init](https://kubernetes.io/docs/reference/setup-tools/kubeadm/kubeadm-init/). Of particular interest are the `--pod-network-cidr` and `--service-cidr` options. To understand what values to pass to these options, you should read the sections on CNI plugins and (if applicable) IPv6 support before performing this step. See also [here](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/) for more detailed information.

If you are using a single-node cluster, you will need to remove the [taints](https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/) on the node for pods to run on it. To do so, run `kubectl taint nodes --all node-role.kubernetes.io/master-` and `kubectl taint nodes --all node-role.kubernetes.io/control-plane-`.

### CNI Plugin
At this point, `kubectl get pods -A` should show that you have a cluster initialized, but some pods will not be running because the CNI plugin is not initialized, which is required for inter-pod networking to function. A list of options can be found [here](https://kubernetes.io/docs/concepts/cluster-administration/networking/). For the examples in this document, we use Calico, and you can follow the instructions [here](https://projectcalico.docs.tigera.io/getting-started/kubernetes/self-managed-onprem/onpremises). Make sure that the pod network cidr specified by the CNI plugin matches the one passed to `kubeadm init` -- for Calico, this value lies in `.spec.calicoNetwork.ipPools` of `custom-resources.yaml`, and you can either change `custom-resources.yaml` to match what you passed to `kubeadm init`, or simply pass the default value in `custom-resources.yaml` to `kubeadm init`.

### Helm
Follow the instructions [here](https://helm.sh/docs/intro/install/) to install the Helm cli.

### Frontend Helm Chart
By this point, you should have Helm installed and `kubectl get pods -A` should show all pods in the `Running` state. If not, see the `kubectl` [docs](https://kubernetes.io/docs/reference/kubectl/) for further debugging.

Before installing the chart, you must customize its configuration. Customization of the chart itself is done through `values.yaml`, which contains values that are passed to the templates to build static Kubernetes manifests. Read the documentation in `values.yaml` to see what configuration options are available. Fields with values written represent defaults, and you might be able to leave them unchanged depending on your setup. Fields left blank will change from deployment to deployment and must be given a custom value. To customize the values, you can modify `values.yaml` directly, create a new yaml file and pass it to `helm install -f`, or write individual values with `helm install --set` (see the `helm install` [documentation](https://helm.sh/docs/helm/helm_install/)).

Next, configure the GlideinWMS frontend and HTCondor central manager. Templates have been provided in `config/frontend` and `config/condor`, and Helm will look there for configuration files by default. These files must be edited manually and cannot be controlled by `values.yaml`, as Helm only supports yaml templates, not arbitrary files.

Finally, install the chart with [helm install](https://helm.sh/docs/helm/helm_install/). If the installation is successful, pods for the frontend and central manager will appear in the `Running` state in `kubectl get pods` (it may take a minute or two for the pods to switch from `Pending` to `Running`).

## Credentials Management
Much of the credentials management is handled automatically by the containers. The frontend and condor CM use idtokens to authenticate with themselves and each other; upon installation, they each generate a random password, and the condor CM creates tokens for both containers. Using shared PersistentMounts, the frontend token is given to the frontend container and the frontend password is shared with the CM (necessary for authentication of glideins with the CM). If credentials are already present, this setup is skipped to avoid destroying credentials still in use.

Two steps must be completed manually:
* An idtoken from the GlideinWMS Factory must be placed in the frontend's `tokens.d` persistent mount (by default in `persistentmount/frontend/tokens.d`) so that the frontend can authenticate with the factory.
* A first-time scitoken setup must be done for glideins to authenticate with the compute element. There is a cron job in the frontend container to automatically renew scitokens from vault tokens, but the first request (and any requests when the vault token has expired) must be made interactively. When the scitoken cannot be automatically renewed, a warning is written to a log file mounted from the host machine for convenient access (by default in `/persistentmount/frontend/scitoken-complaint`) with instructions on how to interactively request the scitoken. Alternatively, you can always get the name of the frontend pod with `kubectl get pods`, then perform the scitoken setup with `kubectl exec -it <frontend pod name> -c vo-frontend -- sh -c /usr/libexec/gwms_renew_scitoken.sh`.

## IPv6 Support
By default, HTCondor (and by extension GWMS) will auto-detect and use both IPv4 and IPv6 interfaces, so no extra HTCondor or GWMS configuration should be required. However, you do need to make sure that your Kubernetes pods and services receive the proper interfaces. To avoid networking issues, you should match the protocols of your services and pods exactly to those of your host machine; that is, on a dual-stack host, you should have dual-stack services and pods, etc.

To set up an IPv6 cluster, simply pass IPv6 CIDRs to `--pod-network-cidr` and `--service-cidr` of `kubeadm init` (for a dual-stack cluster, pass both IPv4 and IPv6 CIDRs comma-delimited). Then, set up your CNI plugin with the same pod network CIDR(s). For Calico, this is configured in `.spec.calicoNetwork.ipPools` (add another entry for a dual-stack setup); consult your CNI plugin's documentation if using something else. Finally, list your host machine's IP address(es) in `hostIPv4` and `hostIPv6` of `values.yaml`, leaving one blank if you have a single-stack host. The Helm chart will automatically configure the service's IP policies based on which addresses are specified in `values.yaml`.

You can read more about IPv6 considerations in Kubernetes [here](https://kubernetes.io/docs/concepts/services-networking/dual-stack/).

## Limitations
* The implementation of this Helm chart assumes a single-node cluster. For multi-node clusters, significant modification of the manifest templates may be required to properly support networking and PersistentVolumes (including their use in sharing credentials).
* The only authentication scheme that has been tested is idtokens + scitokens for glidein submission. Other authentication methods may work with only modifications to the condor and frontend configs, but they may require modification of the manifests as well.
* Similarly, the only way of submitting jobs that has been tested is by `kubectl exec`ing into the condor cm container and creating a test user to submit from within the container. Again, it's possible other methods may work, but they also might not without modifying the manifest templates.
