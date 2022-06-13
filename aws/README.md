- The DNS zone needs to be one that you control. The CF template will make a new zone, but you'll need to find the primary
    nameservers for it and paste them into the parent zone as NS records for this new zone.
- The Cloaked Search configuration file is embedded as an environment variable in `CSTask`, but it references `CSKey1` which
    creates a secret in AWS Secret Manager. If you just want to edit the key, edit the secret. If you want to make bigger changes
    to the configuration, you can either edit directly in the template, or you can store a file in EFS and load it via a `Volume`
    in the task definition.
- Elasticsearch isn't configured for persistence. If it restarts, it will lose all its data. In a production deployment, you'd use
    an EFS volume mounted at `/usr/share/elasticsearch/data`.
