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

```
AWS_PROFILE=profile pin set kt-accp crm@1.0.0
```

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

