######################################################################
# Webサーバー用 公開鍵設定
######################################################################

# template_fileとして読み込み、レンダリング可能な状態に設定
data "template_file" "ssh_key" {

  # ローカルに存在するWebサーバー用の公開鍵を読み込み
  template = file("~/.ssh/id_rsa.pub")
}

# EC2キーペアリソースを設定
# EC2インスタンスへのログインアクセスを制御するために使用
resource "aws_key_pair" "auth" {

  # Webサーバー用のキーペア名を定義
  key_name   = "id_rsa.pub"

  # template_fileのWebサーバー用の公開鍵を設定
  public_key = data.template_file.ssh_key.rendered
}

######################################################################
# APサーバー用 公開鍵設定
######################################################################

# template_fileとして読み込み、レンダリング可能な状態に設定
data "template_file" "ssh_key_priv" {

  # ローカルに存在するAPサーバー用の公開鍵を読み込み
  template = file("~/.ssh/id_rsa_priv.pub")
}

# EC2キーペアリソースを設定
# EC2インスタンスへのログインアクセスを制御するために使用
resource "aws_key_pair" "auth_priv" {

  # APサーバー用のキーペア名を定義
  key_name   = "id_rsa_priv.pub"

  # template_fileのAPサーバー用の公開鍵を設定
  public_key = data.template_file.ssh_key_priv.rendered
}
