#!/bin/bash
set -euo pipefail
cd "$(dirname "$0")/.."
export MSYS_NO_PATHCONV=1

AWS="${AWS:-aws}"
command -v "$AWS" >/dev/null 2>&1 || AWS="/c/Program Files/Amazon/AWSCLIV2/aws.exe"
STACK="${STACK:-biocode}"

output() {
  "$AWS" cloudformation describe-stacks --stack-name "$STACK" \
    --query "Stacks[0].Outputs[?OutputKey=='$1'].OutputValue" --output text | tr -d '\r'
}

SITE_BUCKET="$(output SiteBucketName)"
DISTRIBUTION_ID="$(output DistributionId)"

"$AWS" s3 sync . "s3://$SITE_BUCKET" --delete --only-show-errors \
  --exclude "*" --include "index.html" --include "styles.css" --include "assets/*" \
  --cache-control "public,max-age=300"

"$AWS" cloudfront create-invalidation --distribution-id "$DISTRIBUTION_ID" --paths "/*" \
  --query Invalidation.Id --output text >/dev/null
echo "Site publicado em $(output SiteUrl)"
