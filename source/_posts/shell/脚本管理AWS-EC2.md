---
title: 脚本管理AWS EC2
date: 2023-12-25 21:52:40
tags:
---

这里使用python SDK `boto3`，文档：

<https://aws.amazon.com/sdk-for-python/>

<https://boto3.amazonaws.com/v1/documentation/api/latest/guide/quickstart.html>

## 安装

```shell
pip3 install boto3
```

## 配置

```shell
cd
mkdir .aws
vim ~/.aws/credentials
```

```text
[default]
aws_access_key_id = YOUR_ACCESS_KEY
aws_secret_access_key = YOUR_SECRET_KEY
region=ap-northeast-1
```

然后进入AWS EC2 console，点击右上角的下拉框，点击里面的security credentials，在里面创建access key和对应的secret key，其中secret key只在创建的时候显示，一定要妥善保存，丢失后只能再创建一个新的。

## [EC2 client](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2.html)

官方示例：<https://boto3.amazonaws.com/v1/documentation/api/latest/guide/ec2-example-managing-instances.html>

```py
import boto3
client = boto3.client('ec2')
```

下面介绍一些常用的。

## [describe_instances](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/describe_instances.html)

```py
import json5

response = client.describe_instances(
    InstanceIds=[
        sys.argv[1],
    ],  
)
print(json5.dumps(
    response,
    indent=4,
    # https://stackoverflow.com/a/36142844/13688160
    default=str
))
```

### 打印private IP

```py
response = client.describe_instances(
    InstanceIds=[
        sys.argv[1],
    ],  
)
response = response['Reservations']
assert len(response) == 1
response = response[0]
instances = response['Instances']
assert len(instances) == 1
instance = instances[0]
print(instance['PrivateIpAddress'])
```

### 打印instance个数

```py
response = client.describe_instances(
    Filters=[
        {
            'Name': 'instance-state-name',
            'Values': [
                'pending',
                'running',
                'shutting-down',
                'stopping',
                'stopped',
            ]
        },
    ],  
)
reservations = response['Reservations']
print(len(reservations))
for reservation in reservations:
    assert len(reservation['Instances']) == 1
```

## [run_instances](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/run_instances.html)

创建实例。

```py
response = client.run_instances(
    BlockDeviceMappings=[
        {
            'DeviceName': '/dev/nvme0n1',
            'Ebs': {
                'DeleteOnTermination': True,
                'Iops': 16000,
                'VolumeSize': 512, # GiBs
                'VolumeType': 'gp3',
                'Throughput': 600, # MiB/s
                'Encrypted': False
            },
        },
    ],
    ImageId='ami-08c2888d01ed84209', # Debian 12
    InstanceType='i4i.2xlarge',
    KeyName='string',
    MinCount=1,
    MaxCount=1,
    SecurityGroupIds=[
        'string',
    ],
    EbsOptimized=True,
)
assert len(response['Instances']) == 1
instance = response['Instances'][0]
print(instance['InstanceId'])
```

但是不能设置hostname。

在使用前先用下面介绍的`wait_until_exists`等待instance成功创建，不然会报instance不存在的错误。

## [Instance](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/instance/index.html)

```py
import boto3
ec2 = boto3.resource('ec2')
instance = ec2.Instance('id')
```

### [wait_until_exists](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/instance/wait_until_exists.html)

```py
instance.wait_until_exists()
```

### [wait_until_running](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/instance/wait_until_running.html)

来源：<https://stackoverflow.com/questions/19054081/ec2-waiting-until-a-new-instance-is-in-running-state>

## [terminate_instances](https://boto3.amazonaws.com/v1/documentation/api/latest/reference/services/ec2/client/terminate_instances.html)

```py
client.terminate_instances(
    InstanceIds=[
        'string',
    ],
)
```
