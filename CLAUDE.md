# Pantri Infrastructure as Code

## プロジェクト概要
このプロジェクトは、AWS ECS上でホストされるNext.jsアプリケーションのインフラをTerraformで構築します。以下のアーキテクチャを採用しています：

## プロジェクト構成
```
pantri-iac/
├── environments/
│   ├── dev/
│   │   ├── main.tf           # 開発環境のメイン設定
│   │   ├── variables.tf      # 開発環境の変数定義
│   │   ├── outputs.tf        # 開発環境の出力値
│   │   └── terraform.tfvars  # 開発環境の変数値
│   └── prod/
│       ├── main.tf           # 本番環境のメイン設定
│       ├── variables.tf      # 本番環境の変数定義
│       ├── outputs.tf        # 本番環境の出力値
│       └── terraform.tfvars  # 本番環境の変数値
├── modules/                   # 共通モジュール
│   ├── network/               # ネットワーク関連
│   │   ├── vpc/               # VPC、サブネット、ルーティング
│   │   ├── load-balancer/     # ALB、NLB
│   │   └── security-groups/   # セキュリティグループ
│   ├── compute/               # 計算リソース関連
│   │   ├── ecs/               # ECSクラスター、サービス、タスク
│   │   ├── lambda/            # Lambda関数
│   │   └── auto-scaling/      # オートスケーリンググループ
│   ├── database/              # データベース関連
│   │   └── rds/               # RDS PostgreSQL/MySQL
│   ├── storage/               # ストレージ関連
│   │   ├── s3/                # S3バケット、ポリシー
│   │   ├── efs/               # EFS ファイルシステム
│   │   └── backup/            # AWS Backup
│   ├── security/              # セキュリティ関連
│   │   ├── iam/               # IAMロール、ポリシー
│   │   ├── cognito/           # Cognito User Pool
│   │   ├── acm/               # SSL/TLS証明書
│   │   └── secrets-manager/   # Secrets Manager
│   ├── observability/         # 監視・観測関連
│   │   ├── cloudwatch/        # CloudWatch Logs、メトリクス
│   │   ├── datadog/           # Datadog統合
│   │   └── xray/              # AWS X-Ray
│   └── content-delivery/      # コンテンツ配信関連
│       ├── cloudfront/        # CloudFront
│       ├── route53/           # DNS、ヘルスチェック
│       └── waf/               # Web Application Firewall
├── CLAUDE.md                 # プロジェクトコンテキストとコマンド
└── README.md                 # プロジェクト概要とセットアップ手順
```

- **アプリケーション**: ECS上で動作するNext.jsアプリ
- **ロードバランサー**: ECS前段に配置されたApplication Load Balancer (ALB)
- **CDN**: コンテンツ配信用のCloudFront
- **認証**: ユーザー認証のためのCognito User Pool
- **静的ファイル**: 画像などの静的ファイル格納用のS3バケット

## アーキテクチャコンポーネント

### ネットワーク層 (network/)
- **VPC**: カスタムVPC、マルチAZサブネット、ルーティング
- **Load Balancer**: ALB/NLBによる負荷分散
- **Security Groups**: きめ細かいネットワークアクセス制御

### 計算リソース層 (compute/)
- **ECS**: Fargateタスクによるコンテナオーケストレーション
- **Lambda**: サーバーレス関数実行
- **Auto Scaling**: 需要に応じた自動スケーリング

### データベース層 (database/)
- **RDS**: PostgreSQL/MySQLによるリレーショナルDB

### ストレージ層 (storage/)
- **S3**: 静的ファイル、ログ、バックアップの保存
- **EFS**: 共有ファイルシステム
- **AWS Backup**: 統合バックアップサービス

### セキュリティ層 (security/)
- **IAM**: ロールベースアクセス制御
- **Cognito**: ユーザー認証・認可
- **ACM**: SSL/TLS証明書管理
- **Secrets Manager**: 機密情報の安全な管理

### 監視・観測層 (observability/)
- **CloudWatch**: ログ、メトリクス、アラーム
- **Datadog**: APM、インフラ監視、ダッシュボード
- **X-Ray**: 分散トレーシング

### コンテンツ配信層 (content-delivery/)
- **CloudFront**: グローバルCDN
- **Route53**: DNS管理、ヘルスチェック
- **WAF**: Webアプリケーションファイアウォール

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

## CI/CD パイプライン
- **GitHub Actions**: Terraformのデプロイメント自動化
- **OIDC認証**: GitHub ActionsからAWS環境へのセキュアなアクセス
- **マルチ環境デプロイ**: 開発環境と本番環境への自動デプロイ
- **プルリクエスト連携**: PRでのterraform planの自動実行
- **セキュリティ**: 長期間のAWSクレデンシャル不要の安全な認証方式
- **承認フロー**: 本番環境デプロイ時の手動承認プロセス
- **ロールバック**: デプロイ失敗時の自動ロールバック機能

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

#### ローカル開発
1. 対象環境のディレクトリに移動（`cd environments/dev` または `cd environments/prod`）
2. Terraformファイルの変更
3. `terraform plan`で変更内容を確認
4. `terraform apply`で変更をデプロイ
5. アプリケーションエンドポイントのテスト
6. Datadogダッシュボードで問題がないかモニタリング
7. CloudWatchログとDatadogログで詳細な確認

#### CI/CD ワークフロー
1. 機能ブランチでTerraformファイルを変更
2. プルリクエスト作成時に自動でterraform planを実行
3. コードレビューと承認
4. メインブランチへのマージで開発環境への自動デプロイ
5. 本番環境デプロイ時は手動承認後に実行
6. デプロイ後の自動テストとモニタリング確認

## 環境変数

### ローカル開発用
Terraform実行前に以下の環境変数を設定してください：
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `AWS_DEFAULT_REGION`
- `DATADOG_API_KEY` - Datadog API キー
- `DATADOG_APP_KEY` - Datadog Application キー（任意）

### GitHub Actions用
GitHub Actions ワークフローでは以下を設定：
- GitHub SecretsでDatadog API キーを管理
- AWS OIDC認証により、長期間のクレデンシャル不要
- 環境固有の変数はGitHub Environments機能で管理

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

### GitHub Actions関連コマンド
```bash
# GitHub Actions ワークフローの実行状況確認
gh run list

# 特定のワークフロー実行ログを確認
gh run view <run-id>

# GitHub OIDC プロバイダーの設定確認
aws iam list-open-id-connect-providers

# GitHub Actions用IAMロールの確認
aws iam get-role --role-name GitHubActionsRole
```