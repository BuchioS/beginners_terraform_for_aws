######################################################################
# Webサーバーが端末のグローバルIPからSSH/SFTPとHTTPを受け入れるSG設定
######################################################################

# WebサーバーがSSHとHTTPを受け付けるSGの構築
resource "aws_security_group" "pub_a" {

  # セキュリティグループ名を設定
  name   = "sg_pub_a"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "sg-pub-a"
  }
}

# 出て行く通信の設定
resource "aws_security_group_rule" "egress_pub_a" {

  # このリソースが通信を受け入れる設定であることを定義
  # egressを設定
  type              = "egress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = 0
  to_port           = 0

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 許可するIPの範囲を設定
  # 以下は全てのIPv4トラフィックを許容する設定
  cidr_blocks       = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

# SSH/SFTPを受け入れる設定
resource "aws_security_group_rule" "ingress_pub_a_22" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  from_port         = "22"
  to_port           = "22"

  # プロトコルはtcpを設定
  protocol          = "tcp"

  # 許可するIPの範囲を設定
  # 自身のグローバルIPを記入してください
  cidr_blocks       = ["xxx.xxx.xxx.xxx/32"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

# HTTPを受け入れる設定
resource "aws_security_group_rule" "ingress_pub_a_80" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  from_port         = "80"
  to_port           = "80"

  # プロトコルはtcpを設定
  protocol          = "tcp"

  # 許可するIPの範囲を設定
  # 自身のグローバルIPを記入してください
  cidr_blocks       = ["xxx.xxx.xxx.xxx/32"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.pub_a.id
}

######################################################################
# APサーバーがWebサーバーからVPC内部IPを利用しSSHを受け入れるSG設定
######################################################################

# APサーバーがWebサーバーからSSHを受け付けるSGの構築
resource "aws_security_group" "priv_a" {

  # セキュリティグループ名を設定
  name   = "sg_priv_a"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "sg-priv-a"
  }

}

# 出て行く通信の設定
resource "aws_security_group_rule" "egress_priv_a" {

  # このリソースが通信を受け入れる設定であることを定義
  # egressを設定
  type              = "egress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = 0
  to_port           = 0

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 許可するIPの範囲を設定
  # 以下は全てのIPv4トラフィックを許容する設定
  cidr_blocks       = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.priv_a.id
}

# SSHを受け入れる設定
resource "aws_security_group_rule" "ingress_priv_a_22" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  from_port         = "22"
  to_port           = "22"

  # プロトコルはtcpを設定
  protocol          = "tcp"

  # 許可するIPの範囲を設定
  # Webサーバーを配置しているサブネットのCIDRを設定
  cidr_blocks       = ["10.0.1.0/24"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.priv_a.id
}

######################################################################
# RDSがAPサーバーから3306ポートを利用した通信を受け入れるSG設定
######################################################################

# RDSがAPサーバーから3306ポートを利用した通信を受け付けるSGの構築
resource "aws_security_group" "rds_sg" {

  # セキュリティグループ名を設定
  name   = "rds-sg"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "rds-sg"
  }

}

# 出て行く通信の設定
resource "aws_security_group_rule" "egress_rds_sg" {

  # このリソースが通信の出て行く先を設定することを定義
  # egressを設定
  type              = "egress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = 0
  to_port           = 0

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 許可するIPの範囲を設定
  # 以下は全てのIPv4トラフィックを許容する設定
  cidr_blocks       = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.rds_sg.id
}

# 3306ポートを受け入れる設定
resource "aws_security_group_rule" "ingress_rds_3306" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  # 今回利用するAmazon Aurora MySQLはデフォルトで3306
  # 3306のみ利用するよう、from_portとto_portに記述
  from_port         = "3306"
  to_port           = "3306"

  # プロトコルはtcpを設定
  protocol          = "tcp"

  # 許可するIPの範囲を設定
  # Webサーバーを配置しているサブネットのCIDRを設定
  cidr_blocks       = ["10.0.2.0/24"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.rds_sg.id
}

######################################################################
# ALBが端末のグローバルIPからHTTPSを受け入れるSG設定
######################################################################

# ALBがHTTPSを受け付けるSGの構築
resource "aws_security_group" "alb_web" {

  # セキュリティグループ名を設定
  name   = "alb_web"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "alb-web"
  }
}

# 出て行く通信の設定
resource "aws_security_group_rule" "egress_alb_web" {

  # このリソースが通信を受け入れる設定であることを定義
  # egressを設定
  type              = "egress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = 0
  to_port           = 0

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 許可するIPの範囲を設定
  # 以下は全てのIPv4トラフィックを許容する設定
  cidr_blocks       = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.alb_web.id
}

# HTTPSを受け入れる設定
resource "aws_security_group_rule" "ingress_alb_web_443" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  from_port         = "443"
  to_port           = "443"

  # プロトコルはtcpを設定
  protocol          = "tcp"

  # 許可するIPの範囲を設定
  # 自身のグローバルIPを記入してください
  cidr_blocks       = ["xxx.xxx.xxx.xxx/32"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.alb_web.id
}

######################################################################
# ALB-Webサーバー間の通信を許可する共通利用SG設定
######################################################################

# ALB-Webサーバー間の通信を許可するSGの構築
resource "aws_security_group" "share" {

  # セキュリティグループ名を設定
  name   = "share"

  # セキュリティグループを構築するVPCのIDを設定
  vpc_id = aws_vpc.vpc.id

  # タグを設定
  tags = {
    Name = "share"
  }
}

# 出て行く通信の設定
resource "aws_security_group_rule" "egress_share" {

  # このリソースが通信を受け入れる設定であることを定義
  # egressを設定
  type              = "egress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = 0
  to_port           = 0

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 許可するIPの範囲を設定
  # 以下は全てのIPv4トラフィックを許容する設定
  cidr_blocks       = ["0.0.0.0/0"]

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.share.id
}

# 共通用SGを利用するリソース同士が全ての通信を受け入れる設定
resource "aws_security_group_rule" "ingress_share_self" {

  # このリソースが通信を受け入れる設定であることを定義
  # ingressを設定
  type              = "ingress"

  # ポートの範囲設定
  # 全てのトラフィックを許可する場合いずれも0で設定
  from_port         = "0"
  to_port           = "0"

  # プロトコル設定
  # 以下は全てのIPv4トラフィックを許容する設定
  protocol          = "-1"

  # 受け入れる通信元を設定
  # 自分自身のセキュリティグループのIDを指定
  self              = true

  # このルールを付与するセキュリティグループを設定
  security_group_id = aws_security_group.share.id
}
