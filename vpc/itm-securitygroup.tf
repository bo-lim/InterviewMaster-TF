# ALB SECURITY GROUP
resource "aws_security_group" "alb_sg" {
  name        = "itm-alb-sg"
  description = "Security Group for ALB"
  vpc_id      = aws_vpc.itm-vpc.id
  tags = {
    Name = "itm-alb-sg"
  }
}

resource "aws_security_group_rule" "alb_sg_allow_https" {
    type              = "ingress"
    security_group_id = aws_security_group.alb_sg.id
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 443
    protocol          = "TCP"
    to_port           = 443
    lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "alb_sg_allow_http" {
    type              = "ingress"
    security_group_id = aws_security_group.alb_sg.id
    cidr_blocks       = ["0.0.0.0/0"]
    from_port         = 80
    protocol          = "TCP"
    to_port           = 80
    lifecycle { create_before_destroy = true }
}

# GITLAB SECURITY GROUP
resource "aws_security_group" "gitlab_sg" {
  name        = "itm-gitlab-sg"
  description = "Security Group for gitlab"
  vpc_id      = aws_vpc.itm-vpc.id
  tags = {
    Name = "itm-gitlab-sg"
  }
}

resource "aws_security_group_rule" "gitlab_sg_allow_https" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.gitlab_sg.id
    from_port         = 443
    protocol          = "TCP"
    to_port           = 443
    lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "gitlab_sg_allow_http" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.gitlab_sg.id
    from_port         = 80
    protocol          = "TCP"
    to_port           = 80
    lifecycle { create_before_destroy = true }
}

# ARGO SECURITY GROUP
resource "aws_security_group" "argo_sg" {
  name        = "itm-argo-sg"
  description = "Security Group for argo"
  vpc_id      = aws_vpc.itm-vpc.id
  tags = {
    Name = "itm-argo-sg"
  }
}

resource "aws_security_group_rule" "argo_sg_allow_https" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.argo_sg.id
    from_port         = 443
    protocol          = "TCP"
    to_port           = 443
    lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "argo_sg_allow_http" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.argo_sg.id
    from_port         = 80
    protocol          = "TCP"
    to_port           = 80
    lifecycle { create_before_destroy = true }
}

# REDIS SECURITY GROUP
resource "aws_security_group" "redis_sg" {
  name        = "itm-redis-sg"
  description = "Security Group for redis"
  vpc_id      = aws_vpc.itm-vpc.id
  tags = {
    Name = "itm-redis-sg"
  }
}

resource "aws_security_group_rule" "redis_sg_allow_https" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.redis_sg.id
    from_port         = 6379
    protocol          = "TCP"
    to_port           = 6379
    lifecycle { create_before_destroy = true }
}

resource "aws_security_group_rule" "redis_sg_allow_http" {
    type              = "ingress"
    cidr_blocks       = ["0.0.0.0/0"]
    security_group_id = aws_security_group.redis_sg.id
    from_port         = 6380
    protocol          = "TCP"
    to_port           = 6380
    lifecycle { create_before_destroy = true }
}