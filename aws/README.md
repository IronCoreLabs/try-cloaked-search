# Demo Cloaked Search in ECS

This directory contains a CloudFormation template that can set up Cloaked Search, along with its required Elasticsearch backend,
in a simple demo mode. You can use this template as a starting point for a production deployment.

# Limitations

- **There's no persistence.** In a production deployment, the Elasticsearch deployment (the `ESTask` task definition) would mount
    an EFS volume at `/usr/share/elasticsearch/data`. Or, in a more likely scenario, you'd have a preexisting Elasticsearch
    cluster. In this demo, Elasticsearch will lose all its data if it's restarted.
- **No redundancy.** Cloaked Search is stateless, so it can easily load balance across multiple replicas; but this template only
    creates a single replica. Similarly, a typical Elasticsearch deployment would be set up as a cluster for redundancy and
    performance. Elasticsearch configuration is beyond the scope of this document.
- **Cloaked Search configuration file.** The configuration file is embedded as an environment variable in `CSTask`, but it
    references `CSKey1` which creates a secret in AWS Secret Manager. If you just want to edit the key, edit the secret. If you
    need to make bigger changes to the Cloaked Search configuration, you can either edit the configuration directly in the
    template, or you can store a file in EFS and load it via a `Volume` in the task definition.
- **DNS setup.** The DNS zone needs to be one that you control. The CF template will make a new zone, but you'll need to find the
    primary nameservers for it and paste them into the parent zone as NS records for this new zone. The template won't be able to
    fully load until this is done, because it depends on a certificate that can't be created until the DNS zone is reachable.

# Deployment or Updates

1. Browse to https://console.aws.amazon.com/cloudformation to open the CloudFormation console.
1. Select a region.
1. Click `Create stack`.
   1. `Template is ready`
   1. `Upload a template file`
   1. `Choose file` and select the template file.
   1. `Next`
1. Fill in parameters.
    1. Choose a name for the stack, like `cloaked-search-demo`.
    1. Fill in a DNS name, like `cloaked-search.example.com`. (You use must use a real domain that you control, not `example.com`.)
    1. `Next`
1. `Next`
1. Acknowledge the IAM changes and then click `Create stack`.
1. While it's creating, set up NS records to make the DNS zone reachable.
    1. Click over to the `Resources` tab and find `CSDNSZone`. Click the link to open that zone in Route 53.
    1. Note the list of 4 hostnames for the `NS` record.
    1. Go to your DNS provider's configuration for the parent zone (`example.com` in this example) and add NS records. For example,
        you might add 4 DNS records like these:
        - `cloaked-search.example.com. IN NS ns-1015.awsdns-62.net.`
        - `cloaked-search.example.com. IN NS ns-1590.awsdns-06.co.uk.`
        - `cloaked-search.example.com. IN NS ns-165.awsdns-20.com.`
        - `cloaked-search.example.com. IN NS ns-1473.awsdns-56.org.`
1. Back in the CloudFormation browser window, click back to the `Events` tab and watch the events (by clicking the circular arrow
    refresh button) until it says it's done. It'll say `CREATE_COMPLETE` for the `cloaked-search-demo` stack. It can take 5
    minutes or so.
1. Make sure everything's working by checking the logs.
   1. Browse to https://console.aws.amazon.com/cloudwatch
   1. Click `Log groups` and then `cloaked-search-demo`.
   1. View the latest log streams for `cloaked-search` and `elasticsearch`. Look for bad things.
