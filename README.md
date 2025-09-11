# ecs-terraform-handson

## Architecture
![Architecture](./img/architecture.png)

## How to use

`iac_learning`というプロファイルで`aws configure`を実行する。Regionは`ap-northeast-1`にする。

```shell
aws configure --profile
```

Terraformを実行する。

```shell
terraform init
terraform plan
terraform apply -auto-approve
```

## Clean up

```shell
terraform destroy -auto-approve
```
