# Pantri Infrastructure

このリポジトリは、AWSでスケーラブルなNext.jsアプリケーションインフラをデプロイするためのTerraform設定ファイルを含んでいます。

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
├── modules/                   # 共通モジュール
│   ├── network/               # ネットワーク関連
│   │   ├── vpc/               # VPC、サブネット、ルーティング、セキュリティグループ
│   │   └── load-balancer/     # ALB、NLB
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

### 環境分離
- **environments/dev/**: 開発環境用の設定（小さなリソース、低コスト）
- **environments/prd/**: 本番環境用の設定（高可用性、パフォーマンス重視）

### モジュール構成
- **modules/vpc/**: ネットワーク基盤（VPC、サブネット、ルーティング）
- **modules/ecs/**: コンテナオーケストレーション（ECSクラスター、サービス、タスク）
- **modules/alb/**: 負荷分散（Application Load Balancer、ターゲットグループ）
- **modules/cloudfront/**: CDN（CloudFrontディストリビューション）
- **modules/s3/**: ストレージ（S3バケット、静的ファイル）
- **modules/cognito/**: 認証（Cognito User Pool、クライアント）
- **modules/rds/**: データベース（RDS、セキュリティグループ）

## アーキテクチャ概要

インフラには以下が含まれます：

- **ECS Fargate** - Next.jsアプリケーションのコンテナホスティング
- **Application Load Balancer (ALB)** - 負荷分散とSSL終端
- **CloudFront** - グローバル配信用のコンテンツ配信ネットワーク
- **Amazon Cognito** - ユーザー認証と認可
- **S3** - 静的ファイル（画像、ファイル）の保存
- **VPC** - パブリック/プライベートサブネットを持つセキュアなネットワーク
- **Datadog** - アプリケーションとインフラストラクチャの包括的監視

## ネットワーク構成詳細

### 高可用性マルチAZ構成
このインフラは高可用性を実現するため、複数のAvailability Zone（AZ）にまたがる冗長化された構成を採用しています：

- **プライベートサブネット（マルチAZ）**: 
  - 複数のAZに分散してFargateタスクを配置
  - アプリケーションサーバーは外部からの直接アクセスを受けない安全な環境
  - 各AZに独立したサブネットを作成し、単一障害点を排除

- **パブリックサブネット（マルチAZ）**:
  - 複数のAZに分散してALBを配置
  - インターネットからのトラフィックを受信
  - 1つのAZで障害が発生しても、他のAZで継続的にサービス提供

- **冗長化による可用性向上**:
  - ALBが複数のAZに分散されたFargateタスクに負荷分散
  - 1つのAZが停止しても、他のAZで処理を継続
  - データベースやその他のサービスもマルチAZ構成で冗長化

## 前提条件

- 適切なクレデンシャルで設定されたAWS CLI
- Terraform >= 1.0
- Docker（ローカル開発用）

## クイックスタート

1. **リポジトリのクローン**
   ```bash
   git clone <repository-url>
   cd pantri-iac
   ```

2. **AWSクレデンシャルの設定**
   ```bash
   aws configure
   ```

3. **環境の選択**
   ```bash
   # 開発環境の場合
   cd environments/dev
   
   # 本番環境の場合
   cd environments/prd
   ```

4. **Terraformの初期化**
   ```bash
   terraform init
   ```

5. **インフラの確認と適用**
   ```bash
   terraform plan
   terraform apply
   ```

## 設定

### 環境変数

以下の環境変数を設定してください：

```bash
export AWS_ACCESS_KEY_ID="your-access-key"
export AWS_SECRET_ACCESS_KEY="your-secret-key"
export AWS_DEFAULT_REGION="us-east-1"
export DATADOG_API_KEY="your-datadog-api-key"
export DATADOG_APP_KEY="your-datadog-app-key"
```

### Terraform変数

特定の設定で`terraform.tfvars`ファイルを作成してください：

```hcl
environment = "production"
app_name = "pantri"
domain_name = "example.com"
```

## デプロイメント

### 開発環境
```bash
cd environments/dev
terraform init
terraform plan
terraform apply
```

### 本番環境
```bash
cd environments/prd
terraform init
terraform plan
terraform apply
```

## コンポーネント

### ECSサービス
- コンテナ化されたNext.jsアプリケーションの実行
- **CloudWatchメトリクスベースのオートスケーリング**:
  - CPU使用率やメモリ使用率を監視してタスク数を自動調整
  - ターゲット追跡スケーリングポリシーによる効率的なリソース利用
  - 負荷の増減に応じて自動的にスケールアウト/スケールイン
- ヘルスチェックとサービスディスカバリー

### Application Load Balancer
- ECSタスクへのトラフィック配分
- SSL/TLS終端
- ターゲットのヘルスチェック

### CloudFrontディストリビューション
- グローバルコンテンツ配信
- 静的ファイルのキャッシュ
- カスタムドメインサポート

### Cognito User Pool
- ユーザー登録と認証
- JWTトークン管理
- パスワードポリシーとMFAサポート

### S3バケット
- 静的ファイルの保存
- Web配信に最適化
- バージョニングとライフサイクルポリシー

### Datadog監視
- **Datadogエージェント**: ECSタスクにサイドカーとして配置
- **統合監視**: AWS各サービスとの自動統合
- **APM**: Next.jsアプリケーションのトレーシング
- **インフラストラクチャマップ**: サービス間依存関係の可視化
- **アラート**: 閾値ベースおよび異常検知アラート

## モニタリング

### Datadog監視
- **APM（Application Performance Monitoring）**: Next.jsアプリケーションのパフォーマンス監視
- **インフラストラクチャ監視**: ECS、ALB、CloudFront、S3のメトリクス収集
- **ログ集約**: アプリケーションログとインフラログの一元管理
- **カスタムメトリクス**: ビジネスメトリクスの監視と可視化
- **リアルタイムアラート**: 異常検知時の即座の通知
- **統合ダッシュボード**: システム全体の監視ダッシュボード

### 補完的監視
- アプリケーションとインフラのCloudWatchログ
- ALBアクセスログ
- CloudFrontメトリクスとログ
- ECSコンテナインサイト

## セキュリティ

- **ネットワークセキュリティ**:
  - ECSタスク用プライベートサブネットを持つVPC
  - マルチAZ構成による単一障害点の排除
  - NAT Gatewayを通じたプライベートサブネットからの安全なアウトバウンド通信
- **アクセス制御**:
  - 最小限の必要アクセス権のセキュリティグループ
  - **IAMロールベースのアクセス制御**:
    - ECSタスクロール: Fargateタスクが他のAWSサービス（S3、Cognito等）にアクセスするための権限
    - ECS実行ロール: ECSがタスクを実行するために必要な権限（ECRからのイメージプル、CloudWatchログ出力等）
    - 最小権限の原則に基づく権限設定
  - セキュアアクセス用のS3バケットポリシー

## メンテナンス

### スケーリング
**CloudWatchメトリクスベースのオートスケーリング**が設定されています：
- CPU使用率やメモリ使用率を監視して自動的にタスク数を調整
- ターゲット追跡スケーリングポリシーによる効率的なリソース管理
- 手動でのスケーリング調整もTerraform設定で可能

### バックアップ
静的ファイルのS3バージョニングが有効化されています。データベースのバックアップは別途設定してください。

## トラブルシューティング

### よくある問題

1. **ECSタスクが起動しない**: コンテナエラーについてCloudWatchログを確認
2. **ALBヘルスチェックの失敗**: アプリケーションのヘルスエンドポイントを確認
3. **CloudFrontキャッシュの問題**: キャッシュ無効化を使用するかTTL設定を調整
4. **Cognito認証エラー**: ユーザープール設定を確認
5. **Datadogエージェントが起動しない**: Datadog API キーの設定とECSタスクロールの権限を確認
6. **Datadogメトリクスが表示されない**: Datadogエージェントの統合設定とネットワーク接続を確認

### 便利なコマンド

```bash
# ECSサービスの状態確認
aws ecs describe-services --cluster pantri --services pantri-service

# ALBターゲットヘルスの確認
aws elbv2 describe-target-health --target-group-arn <arn>

# アプリケーションログの確認
aws logs tail /aws/ecs/pantri

# Datadogエージェントの状態確認
aws ecs describe-tasks --cluster pantri --tasks <task-arn>

# Datadogエージェントログの確認
aws logs filter-log-events --log-group-name /ecs/datadog-agent
```

### Datadog監視の確認方法
- **ダッシュボード**: システム全体の監視状況をリアルタイムで確認
- **APM**: アプリケーションのパフォーマンス、エラー率、レイテンシを監視
- **インフラストラクチャ**: ECS、ALB、CloudFrontの稼働状況を監視
- **ログ**: アプリケーションログとインフラログを統合検索
- **アラート**: 設定した閾値に基づく自動アラート

## コスト最適化

- 非クリティカルなワークロードにはFargate Spotを使用
- S3ライフサイクルポリシーの設定
- 適切なCloudFrontキャッシュTTLの設定
- ECSタスクサイズの監視と調整

## コントリビュート

1. 機能ブランチを作成
2. 適切な環境ディレクトリで変更をローカルでテスト
3. `terraform plan`で変更内容を確認
4. プルリクエストを提出
