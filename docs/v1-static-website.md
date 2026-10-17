# V1 – Static Website on Amazon S3

**Business reason:** Build a static website for a small business (the Café).

## Architecture

```
Browser ──HTTP──► S3 Static Website Endpoint ──► Bucket (index.html, css/, images/)
```

- Amazon S3 bucket with static website hosting enabled
- Public read access through a bucket policy (`s3:GetObject`)
- Block Public Access turned off for this bucket only
- Site content: `app/static-site/`

## Infrastructure as Code

The Terraform module is in [`terraform/modules/s3-static-site`](../terraform/modules/s3-static-site) and is used by both environments:

- `terraform/environments/dev`
- `terraform/environments/prod`

It creates the bucket, the website configuration, the public access block, the public-read policy, and uploads the site files with the correct content types.

## Deployment note

The Terraform module could **not** be applied in the AWS Academy sandbox. The sandbox attaches an explicit deny on `s3:GetBucketObjectLockConfiguration`, and the AWS provider calls it while reading the bucket after creation:

```
api error AccessDenied: ... is not authorized to perform:
s3:GetBucketObjectLockConfiguration ... with an explicit deny in an identity-based policy
```

The bucket is created, but Terraform marks the resource as failed, so dependent resources (website config, policy, objects) are never applied. This was reproduced on AWS provider v5 and v6.

**Workaround:** V1 was deployed manually through the S3 console using the same configuration as the module. The module is kept as the reference implementation and is expected to work in an unrestricted AWS account. From V2 onward, everything is deployed with Terraform.

## Manual deployment steps (what was done in the sandbox)

1. Create a general purpose bucket in `us-east-1` (ACLs disabled, Object Lock disabled).
2. Turn off *Block all public access* for this bucket.
3. Upload the contents of `app/static-site/`.
4. Enable static website hosting with `index.html` as the index document.
5. Attach the public-read bucket policy.

## Result

| | |
|---|---|
| Website | ![Website](image/V1/v1-website.png) |
| Bucket objects | ![Objects](image/V1/v1-bucket-objects.png) |
| Static hosting | ![Hosting](image/V1/v1-static-hosting.png) |
| Bucket policy | ![Policy](image/V1/v1-bucket-policy.png) |

## Limitations and next steps

- The website endpoint serves HTTP only. CloudFront with Origin Access Control would add HTTPS and keep the bucket private.
- No custom domain (Route 53 domain registration is not available in the sandbox).