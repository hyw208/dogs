**Purpose**
- Deploy the frontend built in `packages/frontend/dist` to AWS S3 (optionally fronted by CloudFront) with correct caching and CI integration.

**Architecture**
- **S3 static site**: Hosts `index.html` and `assets/*`.
- **CloudFront (optional)**: CDN + HTTPS + custom domain.
- **Backend**: FastAPI stays behind `docker-compose`/Render/EC2; UI calls `/api/*` over CORS.

**Prerequisites**
- AWS account with access to create IAM users and S3 buckets.
- AWS CLI installed and configured locally: `aws configure`.
- GitHub repo secrets (if deploying via CI).

**Setup: IAM User (least privilege)**
- Create an IAM user, e.g., `github-actions-deployer`.
- Attach a minimal inline policy for your bucket (replace `YOUR_BUCKET`):

```json
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Effect": "Allow",
			"Action": [
				"s3:PutObject",
				"s3:PutObjectAcl",
				"s3:DeleteObject",
				"s3:ListBucket",
				"s3:GetObject"
			],
			"Resource": [
				"arn:aws:s3:::YOUR_BUCKET",
				"arn:aws:s3:::YOUR_BUCKET/*"
			]
		}
	]
}
```

- If using CloudFront invalidations, also allow:

```json
{
	"Effect": "Allow",
	"Action": ["cloudfront:CreateInvalidation"],
	"Resource": "*"
}
```

- Create access keys under the user's “Security credentials”. Store them securely.

**Bucket Configuration (S3 Static Hosting)**
- Create an S3 bucket (recommended: `your-domain.com`).
- Enable static website hosting; set:
- **Index document**: `index.html`
- **Error document**: `index.html` (enables client-side routing fallback).
- Set bucket policy to allow public read if using S3 website endpoint directly, or keep private when fronted by CloudFront.

**Build and Upload (Manual)**
- Build the UI:

```bash
./packages/frontend/frontend.sh build
```

- Upload with proper cache headers:

```bash
# Sync assets (immutable, long cache)
aws s3 sync packages/frontend/dist/ s3://YOUR_BUCKET/ \
	--delete \
	--cache-control "public,max-age=31536000,immutable" \
	--exclude "index.html"

# Upload index.html (no cache, revalidate)
aws s3 cp packages/frontend/dist/index.html s3://YOUR_BUCKET/ \
	--cache-control "public,max-age=0,must-revalidate"
```

**CloudFront (Optional)**
- Create a distribution pointing to the S3 origin.
- Serve over HTTPS and set your custom domain via Route 53.
- After deploys, invalidate cache:

```bash
aws cloudfront create-invalidation \
	--distribution-id YOUR_DISTRIBUTION_ID \
	--paths "/*"
```

**CI Integration (GitHub Actions)**
- Add repo secrets:
- `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`
- `S3_BUCKET_NAME`, `CLOUDFRONT_DISTRIBUTION_ID` (if applicable)
- Use the workflow at `.github/workflows/ui-deploy.yml` which:
- Installs Node, runs tests, builds, and deploys to S3
- Applies correct cache headers and optionally invalidates CloudFront

**CORS on Backend**
- If UI is served from `https://your-domain.com` and backend is different origin, enable CORS in FastAPI:

```python
from fastapi.middleware.cors import CORSMiddleware
app.add_middleware(
		CORSMiddleware,
		allow_origins=["https://your-domain.com"],
		allow_methods=["*"],
		allow_headers=["*"],
)
```

**Troubleshooting**
- 403 AccessDenied: Check bucket policy and object ACLs.
- 404 on client routes: Ensure S3 “Error document” is `index.html`.
- Stale assets: Verify cache headers; invalidate CloudFront after deploy.
- Mixed content: Use HTTPS everywhere (CloudFront + S3).

**Security Notes**
- Prefer least-privilege IAM policies scoped to your bucket.
- Keep S3 bucket private when using CloudFront; expose via CDN only.
- Rotate access keys and store them only in GitHub Secrets.