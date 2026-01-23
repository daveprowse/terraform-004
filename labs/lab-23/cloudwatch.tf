# CloudWatch Alarm for high CPU usage
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  alarm_name          = "${var.environment}-web-server-high-cpu"
  alarm_description   = "Alert when CPU exceeds 80%"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = 2
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = 300
  statistic           = "Average"
  threshold           = 80
  
  dimensions = {
    InstanceId = aws_instance.web_server.id
  }
  
  alarm_actions = []  # Add SNS topic ARN here for notifications
  
  tags = {
    Name        = "${var.environment}-high-cpu-alarm"
    Environment = var.environment
  }
  
  # Only create alarm if monitoring is enabled
  count = var.enable_monitoring ? 1 : 0
}
