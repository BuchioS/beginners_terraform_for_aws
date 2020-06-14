######################################################################
# VPC 設定
######################################################################

# AWS上にVPCを構築
resource "aws_vpc" "vpc" {

  # ネットワークの範囲を設定
  cidr_block = "10.0.0.0/16"

  # DNSサポートを有効化
  enable_dns_support = "true"

  # DNSホスト名を有効化
  enable_dns_hostnames = "true"

  # タグを設定
  tags = {
    Name = "dev-vpc"
  }
}
