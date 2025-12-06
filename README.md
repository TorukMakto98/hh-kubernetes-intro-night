# hh-kubernetes-intro-night

This repository contains a basic manifest for the Kubernetes Intro Night.

## Prerequisites

- macOS with Homebrew (recommended) or ability to run installers
- An AWS account and an IAM user with permissions to access EKS (or an access key)

## Install AWS CLI (macOS)

Recommended: Homebrew

```bash
brew update
brew install awscli
```

Alternative: official macOS installer

```bash
curl "https://awscli.amazonaws.com/AWSCLIV2.pkg" -o "AWSCLIV2.pkg"
sudo installer -pkg AWSCLIV2.pkg -target /
```

After install, verify:

```bash
aws --version
```

Configure credentials (interactive):

```bash
aws configure
# enter AWS Access Key ID, Secret Access Key, region and output format
```

Or set environment variables:

```bash
export AWS_ACCESS_KEY_ID=YOUR_KEY
export AWS_SECRET_ACCESS_KEY=YOUR_SECRET
export AWS_DEFAULT_REGION=eu-west-1
```

## Install kubectl

Recommended: Homebrew

```bash
brew install kubectl
```

Alternative: download the stable release

```bash
curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/darwin/amd64/kubectl"
chmod +x kubectl
sudo mv kubectl /usr/local/bin/
```

Verify:

```bash
kubectl version --client --short
```

## Add an EKS cluster to your kubeconfig (bring cluster into your context)

Using the AWS CLI (recommended): replace `<region>` and `<cluster-name>`

```bash
aws eks update-kubeconfig --region <region> --name <cluster-name>
```

This command fetches the cluster info and updates `~/.kube/config` so `kubectl` can talk to the cluster.

Optional: with `eksctl` (convenience tool)

```bash
brew install eksctl
eksctl utils write-kubeconfig --cluster=<cluster-name> --region=<region>
```

## Verify access

```bash
kubectl get nodes
kubectl get svc -A
```

If these commands succeed, your local context is pointing to the EKS cluster.

## Notes & troubleshooting

- Ensure your IAM user/role has `eks:DescribeCluster` permission at minimum.
- If you have multiple kubeconfig contexts, switch using `kubectl config use-context <context>`.
- If you run into permission errors, double-check `aws configure` credentials and region.

---
Enjoy the intro night! If you want, I can also add example `kubectl` commands or an `eksctl` quickstart.
