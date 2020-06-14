######################################################################
# 証明書の設定
######################################################################

# 証明書を構築
resource "aws_acm_certificate" "cert" {

  # 証明書を構築するドメイン
  # Route53のドメインを直接指定
  # ※任意の値に書き換えてください
  domain_name       = "hoge.net"

  # ドメインの認証方式
  # Email認証も選択できるがここではDNSを設定
  validation_method = "DNS"

  # タグを設定
  tags = {
    Name = "sslcertification"
  }
}

######################################################################
# 証明書の検証設定
######################################################################

# Route53レコード検証成否を確認
resource "aws_acm_certificate_validation" "cert" {

  # 証明書のAmazon Rsource Nameを設定
  certificate_arn         = aws_acm_certificate.cert.arn

  # Route 53に記述した検証レコードのFully Qualified Domain Nameを設定
  validation_record_fqdns = [aws_route53_record.cert_validation.fqdn]
}
