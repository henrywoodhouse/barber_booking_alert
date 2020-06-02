# COVID-19 Booking Tool

You will need to create a [Twilio account](https://www.twilio.com), an [AWS account](https://aws.amazon.com/) with an S3 bucket to store the terraform state file and AWS access keys in a role with the following permissions:

* events:CreateEventBus
* events:PutTargets
* iam:CreatePolicy
* iam:CreateRole
* lambda:AddPermission
* lambda:CreateFunction

The following secrets need to be created in the repositories GitHub Secrets section for the AWS terraform deployment to run as part of the actions workflow:

* AWS_ACCESS_KEY_ID - The AWS access key being used, don't use root credentials
* AWS_ACCOUNT_ID - The AWS account the deployment is being completed in
* AWS_REGION - The AWS region the deployment is being completed in
* AWS_SECRET_ACCESS_KEY - The AWS secret access key being used, don't use root credentials
* BACKEND_TF - The terraform backend [configuration](https://www.terraform.io/docs/backends/types/s3.html) for the S3 bucket, remember to escape quotes
* TWILIO_ACCOUNT_SID - The SID of the Twilio account being used
* TWILIO_AUTH_TOKEN - The Twilio auth token being used
* TWILIO_PHONE_NUMBER - The Twilio phone number being used (+1XXXXXXXXXX)
* USER_PHONE_NUMBERS - A comma seperated list of phone numbers (+1XXXXXXXXXX) for alerts to be sent to

When code is pushed to the master branch the lambda function and CloudWatch trigger are deployed into the AWS account.