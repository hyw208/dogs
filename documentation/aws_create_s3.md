 Log into AWS Console

1. Go to https://console.aws.amazon.com/
Sign in with your AWS account
2. Navigate to IAM (Identity and Access Management)

Search for "IAM" in the top search bar
Click on "IAM"
3. Create a new IAM user (recommended for CI/CD)

Click "Users" in the left sidebar
Click "Create user"
User name: github-actions-deployer (or similar)
Click "Next"
4. Set permissions

Select "Attach policies directly"
Search and select:
AmazonS3FullAccess (for S3 uploads)
CloudFrontFullAccess (if using CloudFront)
Click "Next" → "Create user"
5. Create access keys

Click on the newly created user
Go to "Security credentials" tab
Scroll to "Access keys"
Click "Create access key"
Select "Application running outside AWS"
Click "Next" → "Create access key"
6. Save credentials (IMPORTANT - only shown once!)

Copy Access key ID
Copy Secret access key
Click "Download .csv file" as backup
7. Add to GitHub Secrets

Go to your GitHub repo
Settings → Secrets and variables → Actions
Click "New repository secret"
Add three secrets:
Name: AWS_ACCESS_KEY_ID, Value: [your access key ID]
Name: AWS_SECRET_ACCESS_KEY, Value: [your secret access key]
Name: S3_BUCKET_NAME, Value: [your bucket name]
Name: CLOUDFRONT_DISTRIBUTION_ID, Value: [your CloudFront ID]
⚠️ Security best practice:
Create a user with minimal permissions (only S3 and CloudFront for your specific bucket).

---
AWS Console (quickest)

Open S3 → “Create bucket”.
Bucket name: a unique DNS-safe name (e.g., your-frontend-bucket).
Region: pick closest to users/CDN origin (e.g., us-east-1 if using CloudFront default).
Object Ownership: “ACLs disabled” (recommended).
Block Public Access: keep ON if you’ll front with CloudFront; OFF only if you must serve directly from S3 website.
Versioning: optional (helpful for rollback).
Create bucket.

---
# Set a variable
BUCKET=your-frontend-bucket
REGION=us-east-1

# Create bucket (note: some regions require LocationConstraint)
aws s3api create-bucket \
  --bucket "$BUCKET" \
  --region "$REGION" \
  --create-bucket-configuration LocationConstraint="$REGION"

# (Optional) Enable versioning
aws s3api put-bucket-versioning \
  --bucket "$BUCKET" \
  --versioning-configuration Status=Enabled