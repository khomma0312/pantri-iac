# Pantri Infrastructure as Code

## プロジェクト概要
このプロジェクトは、AWS ECS上でホストされるNext.jsアプリケーションのインフラをTerraformで構築します。以下のアーキテクチャを採用しています：

## プロジェクト構成
```
pantri-iac/
├── environments/
│   ├── dev/
│   │   ├── backend.tf        # Terraformバックエンド設定
│   │   ├── data.tf           # データソース定義
│   │   ├── locals.tf         # ローカル値定義
│   │   ├── main.tf           # 開発環境のメイン設定
│   │   ├── outputs.tf        # 開発環境の出力値
│   │   ├── providers.tf      # プロバイダー設定
│   │   ├── terraform.tfvars  # 開発環境の変数値
│   │   ├── variables.tf      # 開発環境の変数定義
│   │   └── versions.tf       # バージョン制約
│   └── prd/
│       ├── backend.tf        # Terraformバックエンド設定
│       ├── data.tf           # データソース定義
│       ├── locals.tf         # ローカル値定義
│       ├── main.tf           # 本番環境のメイン設定
│       ├── outputs.tf        # 本番環境の出力値
│       ├── providers.tf      # プロバイダー設定
│       ├── terraform.tfvars  # 本番環境の変数値
│       ├── variables.tf      # 本番環境の変数定義
│       └── versions.tf       # バージョン制約
├── modules/                   # 機能別レイヤー構成
│   ├── foundation/            # 基盤レイヤー
│   │   ├── vpc/               # VPC、サブネット、ルーティング
│   │   └── security-groups/   # セキュリティグループ定義
│   ├── security/              # セキュリティレイヤー
│   │   ├── waf/               # Web Application Firewall
│   │   ├── acm/               # SSL/TLS証明書
│   │   └── secrets-manager/   # 機密情報管理
│   ├── compute/               # アプリケーション実行レイヤー
│   │   ├── ecs/               # ECSクラスター、サービス、タスク
│   │   └── alb/               # Application Load Balancer
│   ├── data/                  # データレイヤー
│   │   ├── rds/               # RDS PostgreSQL
│   │   └── s3/                # S3バケット
│   ├── auth/                  # 認証・認可レイヤー
│   │   ├── cognito/           # Cognito User Pool
│   │   └── iam/               # IAMロール、ポリシー
│   ├── delivery/              # コンテンツ配信レイヤー
│   │   ├── cloudfront/        # CloudFront CDN
│   │   └── route53/           # DNS管理
│   └── observability/         # 監視・運用レイヤー
│       ├── cloudwatch/        # CloudWatch監視
│       └── datadog/           # Datadog統合
├── .github/
│   └── workflows/             # CI/CDパイプライン
│       ├── terraform-plan.yml # プルリクエスト時のplan
│       ├── terraform-apply-dev.yml # 開発環境デプロイ
│       ├── terraform-apply-prd.yml # 本番環境デプロイ
│       └── security-scan.yml  # セキュリティスキャン
├── docs/
│   ├── requirements.md        # 要件定義
│   ├── architecture.md        # アーキテクチャ図
│   ├── security.md           # セキュリティガイドライン
│   └── deployment.md         # デプロイメント手順
├── CLAUDE.md                 # プロジェクトコンテキストとコマンド
└── README.md                 # プロジェクト概要とセットアップ手順
```

- **アプリケーション**: ECS上で動作するNext.jsアプリ
- **ロードバランサー**: ECS前段に配置されたApplication Load Balancer (ALB)
- **CDN**: コンテンツ配信用のCloudFront
- **認証**: ユーザー認証のためのCognito User Pool
- **静的ファイル**: 画像などの静的ファイル格納用のS3バケット

## アーキテクチャコンポーネント

### 基盤レイヤー (foundation/)
- **VPC**: カスタムVPC、マルチAZサブネット、ルーティング、NAT Gateway、Internet Gateway
- **Security Groups**: ALB、ECS、RDS、VPCエンドポイント用のセキュリティグループ

### セキュリティレイヤー (security/)
- **WAF**: Webアプリケーションファイアウォール、レート制限、IPブロック
- **ACM**: SSL/TLS証明書管理、自動更新
- **Secrets Manager**: データベース認証情報、API キー、アプリケーション設定の安全な管理

### アプリケーション実行レイヤー (compute/)
- **ECS**: Fargateタスクによるコンテナオーケストレーション、オートスケーリング
- **ALB**: Application Load Balancer、ターゲットグループ、ヘルスチェック

### データレイヤー (data/)
- **RDS**: PostgreSQL/MySQLによるリレーショナルDB、バックアップ設定
- **S3**: 静的ファイル、ログ、バックアップの保存、ライフサイクル管理

### 認証・認可レイヤー (auth/)
- **Cognito**: ユーザー認証・認可、User Pool、Identity Pool
- **IAM**: ロールベースアクセス制御、ECS実行ロール、タスクロール

### コンテンツ配信レイヤー (delivery/)
- **CloudFront**: グローバルCDN、キャッシュ設定、Origin Access Control
- **Route53**: DNS管理、ヘルスチェック、レコード管理

### 監視・運用レイヤー (observability/)
- **CloudWatch**: ログ、メトリクス、アラーム、ダッシュボード
- **Datadog**: APM、インフラ監視、Synthetic監視、カスタムダッシュボード

## ネットワーク構成
- **VPC**: カスタムVPCを作成し、アプリケーション専用のネットワーク環境を構築
- **プライベートサブネット**: マルチAZ（複数のAvailability Zone）で構成し、Fargateタスクを配置
- **パブリックサブネット**: マルチAZで構成し、ALBを配置して冗長化を実現
- **NAT Gateway**: プライベートサブネットからのアウトバウンド通信用（各AZに配置）
- **Internet Gateway**: パブリックサブネットのインターネットアクセス用
- **Route Tables**: 各サブネットの適切なルーティング設定

## サブネット設計方針

### サブネット分離戦略
このプロジェクトでは、セキュリティと運用性の向上のため、機能・責務別にサブネットを分離しています。

### サブネット種別と用途

#### 1. パブリックサブネット (public)
- **用途**: インターネットからの直接アクセスが必要なリソース
- **配置リソース**: Application Load Balancer (ALB)、NAT Gateway
- **CIDR**: 10.0.10.0/24, 10.0.20.0/24 (a, c AZ)
- **インターネットアクセス**: 有り (Internet Gateway経由)
- **ルートテーブル**: 共有 (全AZ共通)

#### 2. プライベートサブネット (private)
- **用途**: アプリケーション実行環境
- **配置リソース**: ECS Fargateタスク
- **CIDR**: 10.0.30.0/24, 10.0.40.0/24 (a, c AZ)
- **インターネットアクセス**: なし (NAT Gateway経由でアウトバウンドのみ)
- **ルートテーブル**: 専用 (AZ毎に独立)

#### 3. データベースサブネット (database)
- **用途**: データストレージ専用
- **配置リソース**: RDS PostgreSQL/MySQL
- **CIDR**: 10.0.50.0/24, 10.0.60.0/24 (a, c AZ)
- **インターネットアクセス**: なし (完全に分離)
- **ルートテーブル**: 専用 (AZ毎に独立、外部通信ルートなし)

#### 4. 管理・運用サブネット (management)
- **用途**: 管理・運用ツール、監視システム
- **配置リソース**: VPCエンドポイント、Bastion Host、運用ツール
- **CIDR**: 10.0.70.0/24, 10.0.80.0/24 (a, c AZ)
- **インターネットアクセス**: なし (NAT Gateway経由でアウトバウンドのみ)
- **ルートテーブル**: 専用 (AZ毎に独立、プライベートサブネットと同じNAT Gateway使用)

### サブネット設定方法

VPCモジュールはシンプルで直感的な設定を採用しており、以下の形式で設定可能です：

```hcl
# environments/{env}/locals.tf での設定例
public_subnets = {
  a = "10.0.10.0/24"
  c = "10.0.20.0/24"
}

private_subnets = {
  a = "10.0.30.0/24"
  c = "10.0.40.0/24"
}

database_subnets = {
  a = "10.0.50.0/24"
  c = "10.0.60.0/24"
}

management_subnets = {
  a = "10.0.70.0/24"
  c = "10.0.80.0/24"
}
```

### ルートテーブル設計

各サブネット種別は以下のルートテーブル構成を持ちます：

- **パブリックサブネット**: 全AZで共有する単一ルートテーブル (`public-rt`)
- **プライベートサブネット**: AZ毎の専用ルートテーブル (`private-rt-{az}`)
- **データベースサブネット**: AZ毎の専用ルートテーブル (`database-rt-{az}`)
- **管理サブネット**: AZ毎の専用ルートテーブル (`management-rt-{az}`)

### 新しいサブネット種別の追加

将来的にサブネット種別を追加する場合は、以下の手順で対応可能です：

1. **VPCモジュール**の`variables.tf`に新しいサブネット変数を追加
2. **VPCモジュール**の`subnets.tf`に新しいサブネットリソースを追加
3. **VPCモジュール**の`routing.tf`に適切なルーティング設定を追加
4. **環境設定ファイル** (`environments/{env}/locals.tf`) で新しいサブネットのCIDRを定義
5. **環境設定ファイル** (`environments/{env}/main.tf`) でモジュール呼び出しに新しい変数を追加

### セキュリティ上の考慮事項

- **データベースサブネット**: 外部通信ルートなしで完全に分離
- **管理サブネット**: 運用に必要な最小限のアクセスのみ許可（プライベートサブネットと同じNAT Gateway経由）
- **ネットワークACL**: 必要に応じてサブネットレベルでの追加制御を実装
- **セキュリティグループ**: サブネット間の通信制御はセキュリティグループで実施

### NAT Gateway設定

- **単一NAT Gateway**: コスト削減のため、`single_nat_gateway = true`で1つのNAT Gatewayを全プライベートサブネットで共有可能
- **AZ毎NAT Gateway**: 高可用性のため、デフォルトでは各AZに独立したNAT Gatewayを配置
- **管理サブネット**: プライベートサブネットと同じNAT Gatewayを使用してコストを最適化

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
1. 対象環境のディレクトリに移動（`cd environments/dev` または `cd environments/prd`）
2. Terraformファイルの変更
3. `terraform plan`で変更内容を確認
4. `terraform apply`で変更をデプロイ
5. アプリケーションエンドポイントのテスト
6. Datadogダッシュボードで問題がないかモニタリング
7. CloudWatchログとDatadogログで詳細な確認

#### CI/CD ワークフロー
1. 機能ブランチでTerraformファイルを変更
2. プルリクエスト作成時に自動でterraform planを実行
3. セキュリティスキャン（terraform security scan）の自動実行
4. コードレビューと承認
5. メインブランチへのマージで開発環境への自動デプロイ
6. 本番環境デプロイ時は手動承認後に実行
7. デプロイ後の自動テストとモニタリング確認

#### レイヤー別デプロイメント順序
1. **foundation**: VPC、セキュリティグループ
2. **security**: WAF、ACM、Secrets Manager
3. **data**: RDS、S3
4. **auth**: IAM、Cognito
5. **compute**: ALB、ECS
6. **delivery**: Route53、CloudFront
7. **observability**: CloudWatch、Datadog

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

## 開発ルール
- コミットメッセージは日本語で書く。また、以下のコミットタイトルをコミットメッセージの前に付ける。
  - fix：修正
  - add：機能追加
  - change：仕様変更（removeする場合もchange）
  - clean：整理（リファクタリング等）
  - upgrade：バージョンアップ
  - revert：変更取り消し
    - 例: `add: brandモデルに◯◯メソッドを追加`
  - docs: ドキュメントの変更