######################################################################
# Webサーバー設定
######################################################################

# 同ディレクトリ内のweb.sh.tplをTerraformで扱えるようdata化
data "template_file" "web_sehll" {
  template = file("${path.module}/web.sh.tpl")
}

# Webサーバーの構築
resource "aws_instance" "web" {

  # [ami.tf]のamiを参照
  ami           = data.aws_ami.amzn2.id

  # インスタンスタイプを設定
  instance_type = "t2.micro"

  # [keypair.tf]の鍵を参照
  key_name      = aws_key_pair.auth.id

  # [iam.tf]のプロファイルを参照
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # [vpc_subnet.tf]を参照
  subnet_id = aws_subnet.public_a.id

  # [vpc_sg.tf]を参照
  vpc_security_group_ids = [
                             aws_security_group.pub_a.id,
                             aws_security_group.share.id
                           ]

  # EBSのパラメーターを設定
  root_block_device {

    # ボリュームの種類を指定
    # 今回はgp2を選択。以下が選択可能な値
    # "standard", "gp2", "io1", "sc1", "st1"
    volume_type           = "gp2"

    # ボリュームの容量を設定
    # 単位はGiB
    volume_size           = 8

    # インスタンス削除時にボリューム併せて削除する設定
    delete_on_termination = true
  }

  # タグを設定
  tags = {
    Name = "web-instance"
  }

  # 初めにdata化したweb.sh.tplを参照
  # 設定をbase64にencodeして格納
  user_data = base64encode(data.template_file.web_sehll.rendered)
}

######################################################################
# APサーバー設定
######################################################################

# 同ディレクトリ内のap.sh.tplをTerraformで扱えるようdata化
data "template_file" "ap_sehll" {
  template = file("${path.module}/ap.sh.tpl")
}

# APサーバーの構築
resource "aws_instance" "ap" {

  # [ami.tf]のamiを参照
  ami           = data.aws_ami.amzn2.id

  # インスタンスタイプを設定
  instance_type = "t2.micro"

  # [keypair.tf]の鍵を参照
  key_name      = aws_key_pair.auth_priv.id

  # [iam.tf]のプロファイルを参照
  iam_instance_profile = aws_iam_instance_profile.ec2_profile.name

  # [vpc_subnet.tf]を参照
  subnet_id = aws_subnet.private_a.id

  # [vpc_sg.tf]を参照
  vpc_security_group_ids = [aws_security_group.priv_a.id]

  # EBSのパラメーターを設定
  root_block_device {

    # ボリュームの種類を指定
    # 今回はgp2を選択。以下が選択可能な値
    # "standard", "gp2", "io1", "sc1", "st1"
    volume_type           = "gp2"

    # ボリュームの容量を設定
    # 単位はGiB
    volume_size           = 8

    # インスタンス削除時にボリューム併せて削除する設定
    delete_on_termination = true
  }

  # タグを設定
  tags = {
    Name = "ap-instance"
  }

  # 初めにdata化したap.sh.tplを参照
  # 設定をbase64にencodeして格納
  user_data = base64encode(data.template_file.ap_sehll.rendered)
}
