# Template Variables for Lambda@Edge demo

This example is designed to go hand-in-hand with my [blog article on environment variables in Lambda@Edge](https://m1ke.me/)

Deploy this to an AWS environment:

```
terraform apply
```

## Test events

Visit the [Lambda console](https://eu-west-1.console.aws.amazon.com/lambda/home) (you may need to change region) and configure a test event, e.g:

```
{
  "Records": [
    {
      "cf": {
        "request": {
          "headers": {
            "authorization": [
              {
                "value": "p@ssword"
              }
            ]
          }
        }
      }
    }
  ]
}
```

Save this as `correctPassword`; run it and the response should be:

```
{
  "headers": {
    "authorization": [
      {
        "value": "p@ssword"
      }
    ]
  }
}
```

Now duplicate this but change the password (or remove it) and your response should be similar to:

```
{
  "status": "401",
  "statusDescription": "Unauthorized",
  "body": "You got the password wrong",
  "headers": {
    "www-authenticate": [
      {
        "key": "WWW-Authenticate",
        "value": "Basic"
      }
    ]
  }
}
```

Try modifying the password in the script and redeploying; you'll see the result of your test events change, and also that the `publish` key in the `aws_lambda_function` resource causes a new "version" qualifier to be generated each time you make a change.

## Attaching to Cloudfront

This doesn't cover creating a Cloudfront distribution as that's quite involved, but to use this simple password auth in your distribution add:

```
lambda_function_association {
 	event_type = "viewer-request"
 	lambda_arn = aws_lambda_function.my-lambda.qualified_arn
}
```

Into the `default_cache_behaviour` block of your `aws_cloudfront_distribution` resource.
