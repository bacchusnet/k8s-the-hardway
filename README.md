# k8s-the-hardway

- CD to `/terraform` directory
- Build infra with `terraform apply`
- Generate keys at` ~/.ssh/id_rsa.pub` via `ssh-keygen -t rsa -b 4096 -C "your-email@example.com"`
- Run `bash push_ssh_keys.sh` to push SSH key to compute instances
- Run `terraform output` to get external IPs (public IPs)
- SSH to a controller or worker node by running `ssh ubuntu@<CONTROLLER_0_EXTERNAL_IP>`