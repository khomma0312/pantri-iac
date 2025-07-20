# Pantri Infrastructure as Code - Requirements

## 機能別レイヤー構成による実装タスク

### Phase 1: 基盤レイヤー (foundation/)

#### A. VPCモジュール (`modules/foundation/vpc/`)
- [ ] VPC作成とCIDR設定
- [ ] マルチAZサブネット（パブリック・プライベート）
- [ ] Internet Gateway、NAT Gateway
- [ ] ルートテーブル設定
- [ ] VPCエンドポイント（S3、ECR、CloudWatch Logs）
- [ ] VPCフローログ

#### B. セキュリティグループモジュール (`modules/foundation/security-groups/`)
- [ ] ALB用セキュリティグループ
- [ ] ECS用セキュリティグループ
- [ ] RDS用セキュリティグループ
- [ ] VPCエンドポイント用セキュリティグループ

### Phase 2: セキュリティレイヤー (security/)

#### C. WAFモジュール (`modules/security/waf/`)
- [ ] WAF WebACL作成
- [ ] 基本ルールセット（OWASP Top 10）
- [ ] レート制限設定
- [ ] IP制限・地理的ブロック
- [ ] CloudFront連携設定

#### D. ACMモジュール (`modules/security/acm/`)
- [ ] SSL/TLS証明書発行
- [ ] DNS検証設定
- [ ] 証明書の自動更新
- [ ] マルチドメイン対応

#### E. Secrets Managerモジュール (`modules/security/secrets-manager/`)
- [ ] データベース認証情報管理
- [ ] Datadog API キー管理
- [ ] アプリケーション設定値管理
- [ ] 自動ローテーション設定

### Phase 3: データレイヤー (data/)

#### F. RDSモジュール (`modules/data/rds/`)
- [ ] RDS PostgreSQL/MySQL
- [ ] サブネットグループ
- [ ] パラメータグループ
- [ ] 自動バックアップ設定
- [ ] Secrets Manager連携

#### G. S3モジュール (`modules/data/s3/`)
- [ ] 静的ファイル用バケット
- [ ] ログ保存用バケット
- [ ] バケットポリシー設定
- [ ] ライフサイクル管理
- [ ] バージョニング設定

### Phase 4: 認証・認可レイヤー (auth/)

#### H. IAMモジュール (`modules/auth/iam/`)
- [ ] ECS実行ロール
- [ ] ECSタスクロール
- [ ] ALBサービスロール
- [ ] CloudWatchロール
- [ ] カスタムポリシー定義

#### I. Cognitoモジュール (`modules/auth/cognito/`)
- [ ] User Pool作成
- [ ] User Pool Client設定
- [ ] Identity Pool設定
- [ ] カスタムドメイン設定

### Phase 5: アプリケーション実行レイヤー (compute/)

#### J. ALBモジュール (`modules/compute/alb/`)
- [ ] Application Load Balancer
- [ ] ターゲットグループ
- [ ] リスナー設定（HTTP/HTTPS）
- [ ] ヘルスチェック設定
- [ ] SSL終端設定

#### K. ECSモジュール (`modules/compute/ecs/`)
- [ ] ECSクラスター（Fargate）
- [ ] ECSサービス
- [ ] タスク定義（Next.js + Datadog Agent）
- [ ] オートスケーリング設定
- [ ] CloudWatchロググループ

### Phase 6: コンテンツ配信レイヤー (delivery/)

#### L. Route53モジュール (`modules/delivery/route53/`)
- [ ] ホストゾーン設定
- [ ] DNSレコード（A、CNAME、MX）
- [ ] ヘルスチェック設定
- [ ] フェイルオーバー設定

#### M. CloudFrontモジュール (`modules/delivery/cloudfront/`)
- [ ] CloudFrontディストリビューション
- [ ] オリジン設定（ALB、S3）
- [ ] キャッシュ動作設定
- [ ] Origin Access Control (OAC)
- [ ] WAF統合

### Phase 7: 監視・運用レイヤー (observability/)

#### N. CloudWatchモジュール (`modules/observability/cloudwatch/`)
- [ ] ロググループ設定
- [ ] カスタムメトリクス
- [ ] アラーム設定
- [ ] ダッシュボード作成

#### O. Datadogモジュール (`modules/observability/datadog/`)
- [ ] AWS統合設定
- [ ] APM設定
- [ ] Synthetic監視
- [ ] カスタムダッシュボード
- [ ] アラート設定

### Phase 8: CI/CDと運用自動化

#### P. GitHub Actionsワークフロー (`.github/workflows/`)
- [ ] terraform-plan.yml（PR時の自動plan）
- [ ] terraform-apply-dev.yml（開発環境デプロイ）
- [ ] terraform-apply-prd.yml（本番環境デプロイ）
- [ ] security-scan.yml（セキュリティスキャン）
- [ ] OIDC認証設定

#### Q. 環境別設定の完成
- [ ] dev環境の設定ファイル更新
- [ ] prd環境の設定ファイル更新
- [ ] 環境固有変数の整理

## レイヤー依存関係の実装順序

```
Phase 1: foundation (vpc, security-groups)
    ↓
Phase 2: security (waf, acm, secrets-manager)
    ↓
Phase 3: data (rds, s3) + Phase 4: auth (iam, cognito)
    ↓
Phase 5: compute (alb, ecs)
    ↓
Phase 6: delivery (route53, cloudfront)
    ↓
Phase 7: observability (cloudwatch, datadog)
    ↓
Phase 8: CI/CD automation
```

## 移行に関する注意事項

### 既存VPCモジュールからの移行
現在の`modules/network/vpc/`は既にセキュリティグループを含んでいるため、以下の対応が必要：

1. **セキュリティグループの分離**: 
   - `modules/network/vpc/security-group.tf` → `modules/foundation/security-groups/`
   - 出力値の調整（`aws_security_group.alb`、`aws_security_group.ecs`、`aws_security_group.rds`）

2. **モジュール参照の更新**:
   - `environments/dev/main.tf`、`environments/prd/main.tf`の参照パス変更
   - `modules/network/vpc` → `modules/foundation/vpc`

3. **段階的移行**:
   - まずVPCモジュールを`foundation/vpc/`に移動
   - セキュリティグループを`foundation/security-groups/`に分離
   - 他のモジュールを順次実装

## 完了の定義

各モジュールは以下を含む必要があります:
- [ ] `main.tf` - リソース定義
- [ ] `variables.tf` - 変数定義
- [ ] `outputs.tf` - 出力値定義
- [ ] 適切なタグ設定
- [ ] セキュリティベストプラクティスの適用

## 検証項目

各実装完了後:
- [ ] `terraform validate` の成功
- [ ] `terraform plan` の成功
- [ ] セキュリティレビューの完了
- [ ] ドキュメントの更新