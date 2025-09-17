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
cd infra
terraform init
terraform plan
terraform apply -auto-approve
```

イメージをERCにプッシュする。

```shell
# cd to root dir
cd ..
sh push_image.sh
```

## Clean up

```shell
terraform destroy -auto-approve
```
