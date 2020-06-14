######################################################################
# DB Subnet Group設定
######################################################################

# DB用のサブネットグループを構築
resource "aws_db_subnet_group" "db_subgrp" {

  # サブネットグループ名を設定
  name       = "db-subgrp"

  # サブネットのIDを設定
  # [vpc.tf]で定義したDB用のサブネットを参照する設定
  subnet_ids = [aws_subnet.dbsub_a.id, aws_subnet.dbsub_c.id]

  # タグを設定
  tags = {
    Name = "db-subnet-group"
  }
}

######################################################################
# RDS Parameter Group設定
######################################################################

# RDSクラスター用のパラメーターグループを構築
resource "aws_rds_cluster_parameter_group" "db_clstr_pmtgrp" {

  # パラメーターグループ名を設定
  name        = "db-clstr-pmtgrp"

  # クラスターのパラメーターグループは、DBの種類に応じて設定可能
  # DBエンジンの種類とバージョンに応じて設定
  # 今回構築するaurora-mysql5.7を設定
  family      = "aurora-mysql5.7"

  # このパラメーターグループについての説明文を設定
  description = "RDS Cluster Parameter Group"


  # nameに指定したパラメーターの設定値を決定
  # character_set_serverをutf8に設定
  parameter {
    name  = "character_set_server"
    value = "utf8"
  }

  # nameに指定したパラメーターの設定値を決定
  # character_set_clientをutf8に設定
  parameter {
    name  = "character_set_client"
    value = "utf8"
  }

  # nameに指定したパラメーターの設定値を決定
  # time_zoneをAsia/Tokyoに設定
  parameter {
    name         = "time_zone"
    value        = "Asia/Tokyo"

    # 直ぐに変更できるパラメーターは以下の記述で即時適用が可能
    apply_method = "immediate"
  }
}

# DBインスタンス用のパラメーターグループを構築
resource "aws_db_parameter_group" "db_pmtgrp" {

  # パラメーターグループ名を設定
  name   = "db-pmtgrp"

  # RDSインスタンスのパラメーターグループは、DBの種類に応じて設定可能
  # DBエンジンの種類とバージョンに応じて設定
  # 今回構築するaurora-mysql5.7を設定
  family = "aurora-mysql5.7"

  # このパラメーターグループについての説明文を設定
  description = "RDS Instance Parameter Group"
}

######################################################################
# RDS Cluster 設定
######################################################################

# RDSクラスターを構築
resource "aws_rds_cluster" "aurora_clstr" {

  # クラスターの識別子を設定
  cluster_identifier  = "aurora-cluster"

  # クラスター作成時に自動作成されるデータベース名を設定
  database_name       = "mydb"

  # マスターDBのユーザー名を設定
  master_username     = "admin"

  # マスターDBのパスワードを設定
  master_password     = "1234Admin5678"

  # DBが接続を受け入れるポートを設定
  # 今回作成するaurora-mysqlに合わせて3306を設定
  port                = 3306


  # データベースの変更をすぐに適用するか、次のメンテナンス期間中に適用するかを指定
  # デフォルトはfalse
  apply_immediately   = false

  # クラスター削除時に最終スナップショットの作成有無を設定
  # trueはskipが有効になるため、スナップショットを作成しない設定
  skip_final_snapshot = true

  # このクラスターで利用するデータベースのエンジンを設定
  engine              = "aurora-mysql"

  # aurora-mysqlのバージョンを設定
  engine_version      = "5.7.mysql_aurora.2.07.2"

  # 利用するセキュリティグループのIDを設定
  # [vpc_sg.tf]で定義したリソースを設定
  vpc_security_group_ids          = [aws_security_group.rds_sg.id]

  # 利用するDBサブネットの名称を設定
  # aws_db_subnet_groupで定義したサブネットグループをクラスターに設定
  db_subnet_group_name            = aws_db_subnet_group.db_subgrp.name

  # aws_db_parameter_groupで定義したパラメーターグループをクラスターに設定
  db_cluster_parameter_group_name = aws_rds_cluster_parameter_group.db_clstr_pmtgrp.name

  # タグを設定
  tags = {
    Name = "aurora-cluster"
  }
}

######################################################################
# RDS Instance 設定
######################################################################

# RDSインスタンスを構築
resource "aws_rds_cluster_instance" "aurora_instance" {

  # 構築するインスタンスの台数を設定
  count              = 2

  # RDSインスタンスの識別子を設定
  # count.indexでインスタンスに対応する個別のインデックス番号を付与
  # インスタンス1台目は0、インスタンス2台目は1とcountに応じて増減
  identifier         = "aurora-cluster-${count.index}"

  # RDSインスタンスを起動するクラスターのidを指定
  cluster_identifier = aws_rds_cluster.aurora_clstr.id

  # インスタンスのクラスを設定
  instance_class     = "db.t2.small"

  # データベースの変更をすぐに適用するか、次のメンテナンス期間中に適用するかを指定
  # デフォルトはfalse
  apply_immediately  = false


  # RDS インスタンスで利用するデータベースのエンジンを設定
  engine             = "aurora-mysql"

  # aurora-mysqlのバージョンを設定
  engine_version     = "5.7.mysql_aurora.2.07.2"

  # 利用するDBサブネットの名称を設定
  # aws_db_subnet_groupで定義したサブネットグループをインスタンスに設定
  db_subnet_group_name    = aws_db_subnet_group.db_subgrp.name

  # aws_db_parameter_groupで定義したパラメーターグループをインスタンスに設定
  db_parameter_group_name = aws_db_parameter_group.db_pmtgrp.name

  # タグを設定
  tags = {
    Name = "aurora-instance"
  }
}

/*
# RDSクラスターの書き込み用エンドポイントを出力
output "rds-entpoint" {
  value = aws_rds_cluster.aurora_clstr.endpoint
}

# RDSクラスターの読み込み用エンドポイントを出力
output "rds-entpoint-ro" {
  value = aws_rds_cluster.aurora_clstr.reader_endpoint
}
*/
