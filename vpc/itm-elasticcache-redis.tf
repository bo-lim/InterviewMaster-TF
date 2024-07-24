resource "aws_elasticache_serverless_cache" "example" {
  engine = "redis"
  name   = "itm-redis"
  description              = "itm-elasticache-redis"
  major_engine_version     = "7"
  security_group_ids       = [aws_security_group.redis_sg.id]
  subnet_ids               = [aws_subnet.itm-vpc-red-2a.id, aws_subnet.itm-vpc-red-2c.id]
}