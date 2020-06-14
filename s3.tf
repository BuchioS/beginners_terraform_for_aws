######################################################################
# Public(公開設定) のバケット
######################################################################

# S3バケットのリソースを"public_bucket"という名称で作成
resource "aws_s3_bucket" "public_bucket" {

  # バケット名称を任意の名前で定義
  # ※ここの値は変更してください。バケット名は全世界で一意である必要があります
  bucket        = "instance-coffee-bucket"

  # S3のACL(アクセスコントロールリスト)を設定
  # パブリック読み取り専用アクセスのみ許可
  acl           = "public-read"

  # このリソースをterraform destroyで削除可能に設定
  force_destroy = true

  # クロスオリジンリソースシェアリングのルール設定
  # 特定のオリジン（URL）に対しアクセスを許可する設定
  cors_rule {

    # アクセス元のオリジンを制限。ここで設定している["*"]は制限無し
    # 特定のオリジンで制限するなら以下設定
    # allowed_origins = ["https://hoge.com"]
    allowed_origins = ["*"]

    # 許容するHTTPメソッドのリクエストを制限
    # 読み取り専用のコンテンツのみであれば、セキュリティ上["GET"]のみとすべき
    # 複数のメソッドを定義可能。以下が対応
    # ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    allowed_methods = ["GET"]

    # 許容するHTTPヘッダーを制限。特定のヘッダー情報で制限
    # 特に条件がなければ["*"]で問題ない
    allowed_headers = ["*"]

    # ブラウザのキャッシュ時間。秒単位で定義可能
    # 特に条件がないため、公式の例に則り3000を設定
    max_age_seconds = 3000
  }
}

######################################################################
# Private（非公開設定） のバケット
######################################################################

# S3バケットのリソースを"private_bucket"という名称で作成
resource "aws_s3_bucket" "private_bucket" {

  # バケット名称を任意の名前で定義
  # ※ここの値は変更してください。バケット名は全世界で一意である必要があります
  bucket        = "instance-coffee-app-bucket"

  # S3のACL(アクセスコントロールリスト)を設定
  # AWS環境上からのアクセスのみ許可
  acl    = "private"

  # このリソースをterraform destroyで削除可能に設定
  force_destroy = true

  # タグを設定
  tags = {
    Name = "instance-coffee-app-bucket"
  }

  # バージョニングを有効に設定。オブジェクトの変更情報をバージョン管理可能
  versioning {
    enabled = true
  }

  # 暗号化を有効に設定
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

######################################################################
# ALBアクセスログ配置用S3バケットの設定
######################################################################

# ログ配置用S3バケットを構築
resource "aws_s3_bucket" "alb_access_log" {

  # バケット名称を任意の名前で定義
  # ※ここの値は変更してください。バケット名は全世界で一意である必要があります
  bucket = "instance-coffee-log-bucket"

  # S3のACL(アクセスコントロールリスト)を設定
  # AWS環境上からのアクセスのみ許可
  acl    = "private"

  # このリソースをterraform destroyで削除可能に設定
  force_destroy = true

  # タグを設定
  tags = {
    Name = "instance-coffee-log-bucket"
  }

  # データの保存期間を設定
  lifecycle_rule {

    # ライフサイクルルールを有効化
    enabled = true

    # ライフサイクルルールのidを設定
    id      = "alb-access-log-web"

    # 保存するオブジェクト(データ)の有効期限を設定
    expiration {

      # オブジェクトが保存されてから1日経過後ルールを適用
      days = 1
    }

  }

  # ALBからアクセスログの記載を許可
  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {

        "AWS": "arn:aws:iam::582318560864:root"
      },
      "Action": "s3:PutObject",

      "Resource": "arn:aws:s3:::instance-coffee-log-bucket/*"
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:PutObject",

      "Resource": "arn:aws:s3:::instance-coffee-log-bucket/*",
      "Condition": {
        "StringEquals": {
          "s3:x-amz-acl": "bucket-owner-full-control"
        }
      }
    },
    {
      "Effect": "Allow",
      "Principal": {
        "Service": "delivery.logs.amazonaws.com"
      },
      "Action": "s3:GetBucketAcl",

      "Resource": "arn:aws:s3:::instance-coffee-log-bucket"
    }
  ]
}
POLICY

}
