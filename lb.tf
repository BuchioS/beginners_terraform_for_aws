######################################################################
# ALB 本体の設定
######################################################################

# ALBの構築
resource "aws_lb" "web" {

  # ALBの名称を設定
  name               = "web"

  # ロードバランサーの種類を選択可能
  # networkかapplicationが選択可能
  # applicationを設定: ALBを構築
  load_balancer_type = "application"

  # ALBの種類
  # trueとfalseが選択可能
  # trueを設定: AWS環境内部の通信を扱うInternal ALB
  # falseを設定: インターネットからの通信を扱うALB
  internal           = false

  # 利用するセキュリティグループを設定
  security_groups    = [
                         aws_security_group.alb_web.id,
                         aws_security_group.share.id
                       ]

  # 利用するサブネットを設定
  subnets            = [
                         aws_subnet.public_a.id,
                         aws_subnet.public_c.id
                       ]

  # 削除保護の設定
  # trueとfalseが選択可能
  # trueの設定: ALBの削除が不可
  # falseの設定: ALBの削除が可能
  enable_deletion_protection = false

  # accesslogの設定
  access_logs {

    # アクセスログの取得を有効化
    enabled = true

    # S3への配置設定
    # 本章で構築したS3を指定
    bucket  = aws_s3_bucket.alb_access_log.bucket

    # ログをS3に配置する際のプレフィックス設定
    prefix  = "web-alb"

  }

  # タグを設定
  tags = {
    Name = "web-alb"
  }
}

######################################################################
# Listenerの設定
######################################################################

# リスナーの構築
resource "aws_lb_listener" "web" {

  # Listener設定対象LBを指定
  # 上で構築したALBをAmazon Resource Name(ARN)で設定
  load_balancer_arn = aws_lb.web.arn

  # インターネットからの通信を待ち受けるポートを設定
  port              = "443"

  # インターネットからの通信に利用するプロトコルを設定
  protocol          = "HTTPS"

  # 7章で構築したSSL証明書を通信に利用
  certificate_arn   = aws_acm_certificate.cert.arn

  # デフォルトとして行う動作を設定
  default_action {

    # ルーティングアクションタイプの設定
    # forwardはターゲットグループにリクエストを転送する
    type             = "forward"

    # リクエストを転送するターゲットグループを指定
    # この後構築するターゲットグループをARNで設定
    target_group_arn = aws_lb_target_group.web.arn
  }
}

######################################################################
# Target Groupの設定
######################################################################

# ターゲットグループの構築
resource "aws_lb_target_group" "web" {

  # ターゲットグループ名を設定
  name     = "web"

  # ターゲットが所属するVPCのIDを指定
  vpc_id   = aws_vpc.vpc.id

  # ターゲットへの接続に利用するポートを設定
  port     = 80

  # ターゲットへの接続に利用するプロトコルを設定
  protocol = "HTTP"
}

# WebサーバーをALBのターゲットに登録
resource "aws_lb_target_group_attachment" "web" {

  # 登録するターゲットグループをARNで設定
  target_group_arn = aws_lb_target_group.web.arn

  # 登録するターゲットを指定
  # 3章で構築したWebサーバーを設定
  target_id        = aws_instance.web.id

  # インスタンスがトラフィックを受け付けるポートを設定
  port             = 80
}
