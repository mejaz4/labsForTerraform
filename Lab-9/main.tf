provider "aws" {
  region = "ca-central-1"
}

resource "aws_db_instance" "prod" {

  identifier           = "prod-mysql-rds"
  allocated_storage    = 20
  storage_type         = "gp2"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t2.micro"
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true

  //not nice to hard code the password
  //we can automatically generate password
  username = "administrator"
  password = data.aws_ssm_parameter.rds_password.value
}

//Generate a random password
resource "random_password" "main" {
  length           = 20
  special          = true
  override_special = "!()"
}

//store password in systems manager parameter store

resource "aws_ssm_parameter" "rds_password" {
  name        = "/prod/prod-mysql-rds/password"
  description = "Master password for RDS DB"

  type  = "SecureString"
  value = random_password.main.result
}


//retrive password
data "aws_ssm_parameter" "rds_password" {
  name       = "/prod/prod-mysql-rds/password"
  depends_on = [aws_ssm_parameter.rds_password]
}

output "rds_address" {
  sensitive = true
  value     = aws_db_instance.prod.address
}

output "rds_port" {
  sensitive = true
  value     = aws_db_instance.prod.port
}

output "rds_username" {
  sensitive = true
  value     = aws_db_instance.prod.username
}

output "rds_password" {
  sensitive = true
  value     = data.aws_ssm_parameter.rds_password.value
}
