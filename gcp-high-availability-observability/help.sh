#!/bin/bash

 gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.networkAdmin"

  gcloud projects add-iam-policy-binding able-veld-462218-h4 \
  --member="serviceAccount:493895453157-compute@developer.gserviceaccount.com" \
  --role="roles/compute.admin"

