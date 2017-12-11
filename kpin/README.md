# kpin

## Usage

```
usage: pin [-h] {set,show,list-versions} ...

optional arguments:
  -h, --help            show this help message and exit

Commands:
  {set,show,list-versions}
    set                 Set pins
    show                Show pins
    list-versions       List available versions
```

### Setting a pin on a project

An aws profile with the correct access is required. Please refer to http://docs.aws.amazon.com/cli/latest/userguide/cli-config-files.html.

Below is a config file example (~/.aws/config)

```
[profile admin-mgmt-ecr]
region=us-east-1
role_arn = arn:aws:iam::611542441284:role/admin-mgmt-ecr
source_profile = default
``` 

Below is a credentials file example (~/.aws/credentials)

```
[default]
aws_access_key_id=YOUR_ID
aws_secret_access_key=YOU_SECRET_KEY
```

Add kt-accp pin on version 1.0.0 for crm application.
```
AWS_PROFILE=admin-mgmt-ecr pin set kt-accp crm@1.0.0
```
 > crm also include any crm-* images.

## Install

### Linux

```
sudo apt-get install python3-pip python3
pip3 install -r requirements
```

### Mac

```
brew install python3
pip3 install -r requirements
```

