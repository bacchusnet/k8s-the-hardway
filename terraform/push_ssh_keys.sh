# Get the instance names
INSTANCES=$(gcloud compute instances list --format="value(name)" --filter="name~'^(controller|worker)-'")

MY_KEY="ubuntu:$(cat $HOME/.ssh/id_rsa.pub)"

echo "🔄 Updating Controller 0..."

# Controller 0
gcloud compute instances add-metadata controller-0 \
  --zone=us-central1-a \
  --metadata ssh-keys="$MY_KEY" \
  --project=k8s-learning-lab-489400

echo "🔄 Updating Controller 1..."

# Controller 1
gcloud compute instances add-metadata controller-1 \
  --zone=us-central1-b \
  --metadata ssh-keys="$MY_KEY" \
  --project=k8s-learning-lab-489400

echo "🔄 Updating Worker 0..."

# Worker 0
gcloud compute instances add-metadata worker-0 \
  --zone=us-central1-a \
  --metadata ssh-keys="$MY_KEY" \
  --project=k8s-learning-lab-489400

echo "🔄 Updating Worker 1..."

# Worker 1
gcloud compute instances add-metadata worker-1 \
  --zone=us-central1-b \
  --metadata ssh-keys="$MY_KEY" \
  --project=k8s-learning-lab-489400

echo "✅ Done! Try SSHing now."
