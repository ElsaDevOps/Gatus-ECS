
# Persistent Layer Recovery

If the persistent layer is destroyed, follow these steps to rebuild.

## Prerequisites

- AWS CLI configured
- Terraform installed
- Access to Route 53 registrar (for nameserver updates if zone is recreated)

## Recovery Order

Resources must be created in this order due to dependencies:

### 1. Route 53 Hosted Zone

terraform apply -target=aws_route53_zone.main

**Manual step:** If zone is recreated, update nameservers at your domain registrar. New zone gets new nameservers.

### 2. ACM Certificate

terraform apply -target=aws_acm_certificate.main
terraform apply -target=aws_acm_certificate_validation.main

**Manual step:** Wait for DNS validation to complete (usually 5-30 minutes).

### 3. OIDC Provider

terraform apply -target=aws_iam_openid_connect_provider.github

### 4. IAM Role

terraform apply -target=aws_iam_role.github_actions
terraform apply -target=aws_iam_role_policy_attachment.github_actions


### 5. ECR Repository

terraform apply -target=aws_ecr_repository.gatus

**Note:** Images will need to be rebuilt and pushed. Trigger CI pipeline after recovery.

### 6. SNS Topic

terraform apply -target=aws_sns_topic.alerts
terraform apply -target=aws_sns_topic_subscription.email

**Manual step:** Confirm email subscription when you receive the confirmation email.

## Full Recovery

Or apply everything at once:

terraform apply


Then complete manual steps:

1. Update nameservers at registrar (if zone recreated)
2. Wait for ACM validation
3. Confirm SNS email subscription
4. Trigger CI pipeline to rebuild and push image

## Verification

- [ ] Route 53 zone has correct records
- [ ] ACM certificate shows "Issued"
- [ ] GitHub Actions pipeline can authenticate
- [ ] ECR repository exists
- [ ] SNS subscription confirmed
- [ ] Ephemeral layer deploys successfully
