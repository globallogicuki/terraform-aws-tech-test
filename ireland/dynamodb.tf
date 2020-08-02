#*********************************
# DynamoDB Table Creation 
#*********************************
resource "aws_dynamodb_table" "ec2-status" {
   name           = "ec2-status"
   billing_mode   = "PROVISIONED"
   read_capacity  = "5"
   write_capacity = "5"
   hash_key       = "random"
   range_key      = "timetolive"
   
   attribute {
      name = "random"
      type = "N"
   }

  attribute {
      name = "timetolive"
      type = "N"
   }
  ttl {
      attribute_name = "timetolive"
      enabled        = true
   }


tags = {
    Owner = var.Owner
    Project = var.Project
  }

}
