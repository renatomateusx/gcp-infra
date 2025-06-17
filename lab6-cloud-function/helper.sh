#!/bin/bash

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.admin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.securityAdmin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.loadBalancerAdmin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/serviceusage.serviceUsageAdmin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/cloudfunctions.admin"

gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:service-493895453157@gcp-sa-cf.iam.gserviceaccount.com" \
  --role="roles/cloudfunctions.invoker"


gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:able-veld-462218-h4@appspot.gserviceaccount.com" \
  --role="roles/cloudfunctions.invoker"

