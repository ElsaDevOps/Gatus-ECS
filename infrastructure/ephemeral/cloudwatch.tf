resource "aws_cloudwatch_metric_alarm" "ecs_cpu" {
  alarm_name          = "gatus-ecs-cpu-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "ECS CPU above 50%"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }
}


resource "aws_cloudwatch_metric_alarm" "ecs_memory" {
  alarm_name          = "gatus-ecs-memory-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "MemoryUtilization"
  namespace           = "AWS/ECS"
  period              = 300
  statistic           = "Average"
  threshold           = 50
  alarm_description   = "ECS Memory above 50%"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }
}

# ECS Running Tasks
resource "aws_cloudwatch_metric_alarm" "ecs_running_tasks" {
  alarm_name          = "gatus-ecs-no-running-tasks"
  comparison_operator = "LessThanThreshold"
  evaluation_periods  = 1
  metric_name         = "RunningTaskCount"
  namespace           = "ECS/ContainerInsights"
  period              = 60
  statistic           = "Average"
  threshold           = 1
  alarm_description   = "No running ECS tasks"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    ClusterName = module.ecs.cluster_name
    ServiceName = module.ecs.service_name
  }
}


resource "aws_cloudwatch_metric_alarm" "alb_5xx" {
  alarm_name          = "gatus-alb-5xx-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "HTTPCode_ELB_5XX_Count"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  statistic           = "Sum"
  threshold           = 5
  alarm_description   = "ALB 5xx errors above 5"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    LoadBalancer = module.loadbalancer.alb_arn_suffix
  }
}

# ALB Response Time (p99)
resource "aws_cloudwatch_metric_alarm" "alb_latency" {
  alarm_name          = "gatus-alb-latency-high"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "TargetResponseTime"
  namespace           = "AWS/ApplicationELB"
  period              = 300
  extended_statistic  = "p99"
  threshold           = 1
  alarm_description   = "ALB p99 response time above 1 second"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    LoadBalancer = module.loadbalancer.alb_arn_suffix
  }
}

# ALB Unhealthy Hosts
resource "aws_cloudwatch_metric_alarm" "alb_unhealthy" {
  alarm_name          = "gatus-alb-unhealthy-hosts"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 1
  metric_name         = "UnHealthyHostCount"
  namespace           = "AWS/ApplicationELB"
  period              = 60
  statistic           = "Average"
  threshold           = 0
  alarm_description   = "Unhealthy targets detected"
  alarm_actions       = [data.terraform_remote_state.persistent.outputs.sns_topic_arn]

  dimensions = {
    LoadBalancer = module.loadbalancer.alb_arn_suffix
    TargetGroup  = module.loadbalancer.target_group_arn_suffix
  }
}
