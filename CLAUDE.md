# Pantri Infrastructure as Code

## プロジェクト概要
このプロジェクトは、AWS ECS上でホストされるNext.jsアプリケーションのインフラをTerraformで構築します。以下のアーキテクチャを採用しています：

- **アプリケーション**: ECS上で動作するNext.jsアプリ
- **ロードバランサー**: ECS前段に配置されたApplication Load Balancer (ALB)
- **CDN**: コンテンツ配信用のCloudFront
- **認証**: ユーザー認証のためのCognito User Pool
- **静的ファイル**: 画像などの静的ファイル格納用のS3バケット

## アーキテクチャコンポーネント
- Fargateタスクを使用したECSクラスター
- 負荷分散用のALB
- CloudFrontディストリビューション
- Cognito User PoolとUser Pool Client
- 静的ファイル格納用のS3バケット
- パブリック/プライベートサブネットを持つVPC
- セキュリティグループとIAMロール

## ネットワーク構成
- **VPC**: カスタムVPCを作成し、アプリケーション専用のネットワーク環境を構築
- **プライベートサブネット**: マルチAZ（複数のAvailability Zone）で構成し、Fargateタスクを配置
- **パブリックサブネット**: マルチAZで構成し、ALBを配置して冗長化を実現
- **NAT Gateway**: プライベートサブネットからのアウトバウンド通信用（各AZに配置）
- **Internet Gateway**: パブリックサブネットのインターネットアクセス用
- **Route Tables**: 各サブネットの適切なルーティング設定

## IAMアクセス制御
- **IAMロールベースのアクセス制御**: 基本的なアクセス権限管理にIAMロールを使用
- **ECSタスクロール**: Fargateタスクが他のAWSサービスにアクセスするための権限
- **ECS実行ロール**: ECSがタスクを実行するために必要な権限（ログ出力、イメージプルなど）
- **ALBサービスロール**: ALBがターゲットヘルスチェックを行うための権限
- **CloudWatchロール**: メトリクス収集とログ出力のための権限
- **最小権限の原則**: 各コンポーネントに必要最小限の権限のみを付与

## オートスケーリング設定
- **CloudWatchメトリクスベースのスケーリング**: CPU使用率やメモリ使用率を基準に自動スケーリング
- **ターゲット追跡スケーリング**: CPU使用率を50%に維持するよう自動調整
- **スケールアウト/スケールイン**: 負荷に応じてタスク数を自動増減
- **CloudWatchアラーム**: 設定したしきい値に基づいてスケーリングアクションを実行
- **スケーリングポリシー**: 段階的なスケーリング設定で急激な変化を防止

## Datadog監視設定
- **Datadogエージェント**: ECSタスクにDatadogエージェントをサイドカーとして配置
- **APM（Application Performance Monitoring）**: Next.jsアプリケーションのパフォーマンス監視
- **インフラストラクチャ監視**: ECS、ALB、CloudFront、S3のメトリクス収集
- **ログ集約**: アプリケーションログとインフラログの一元管理
- **カスタムメトリクス**: ビジネスメトリクスの監視と可視化
- **アラート設定**: 異常検知時の通知設定
- **ダッシュボード**: システム全体の監視ダッシュボード

## よく使用するコマンド

### Terraformコマンド
```bash
# Terraformの初期化
terraform init

# インフラ変更の計画
terraform plan

# インフラ変更の適用
terraform apply

# インフラの削除
terraform destroy

# Terraformファイルのフォーマット
terraform fmt

# Terraform設定の検証
terraform validate
```

### AWS CLIコマンド
```bash
# AWSクレデンシャルの設定
aws configure

# ECSクラスターの一覧表示
aws ecs list-clusters

# ALBターゲットグループの一覧表示
aws elbv2 describe-target-groups

# CloudFrontディストリビューションの一覧表示
aws cloudfront list-distributions

# Cognitoユーザープールの一覧表示
aws cognito-idp list-user-pools --max-results 10

# S3バケットの一覧表示
aws s3 ls
```

### 開発ワークフロー
1. Terraformファイルの変更
2. `terraform plan`で変更内容を確認
3. `terraform apply`で変更をデプロイ
4. アプリケーションエンドポイントのテスト
5. Datadogダッシュボードで問題がないかモニタリング
6. CloudWatchログとDatadogログで詳細な確認

## 環境変数
Terraform実行前に以下の環境変数を設定してください：
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `DATADOG_API_KEY` - Datadog API キー
- `DATADOG_APP_KEY` - Datadog Application キー（任意）

## トラブルシューティングコマンド
```bash
# ECSサービスの状態確認
aws ecs describe-services --cluster <cluster-name> --services <service-name>

# ALBヘルスチェックの確認
aws elbv2 describe-target-health --target-group-arn <target-group-arn>

# CloudWatchログの確認
aws logs describe-log-groups
aws logs tail <log-group-name>

# Datadogエージェントの状態確認
aws ecs describe-tasks --cluster <cluster-name> --tasks <task-arn>

# ECSタスクでDatadogエージェントのログ確認
aws logs filter-log-events --log-group-name /ecs/datadog-agent
```

### Datadog監視確認
- Datadogダッシュボードでシステム全体の監視状況を確認
- APMでアプリケーションパフォーマンスを監視
- インフラストラクチャマップでサービス間の依存関係を確認
- アラート履歴で過去の問題発生状況を確認