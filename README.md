# aws-lambda-xvfb

builds Xvfb binary to run on AWS lambda

## Getting started

Build the image and run it locally. Then verify xvfb & fluxbox work correctly by connecting with a vnc client

```
$(aws ecr get-login)
docker build -t aws-lambda-xvfb .
docker run -p 5900:5900 --detach aws-lambda-xvfb
```

Connect to localhost:5900 with a vnc client such as https://chrome.google.com/webstore/detail/vnc®-viewer-for-google-ch/iabmpiboiopbgfabjmgeedhcmjenhbla?hl=en

## Running in AWS

See the `example/` folder for a demonstration application that can run in AWS. Edit the `example/serverless.yml` with the appropriate iam role under `role: <role-arn-here>`.

Ensure this role has access to write files to s3

```
cd example
sls deploy
```

Make a request to the deployed url printed out by sls deploy. This should return a path to a file on S3. Download that file and verify that it shows a video of the recorded screen setup via `Xvfb` in AWS lambda

```
curl https://api-gateway-url.amazonaws.com/dev/demo
```

