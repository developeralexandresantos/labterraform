# resource "aws_s3_bucket" "example" {
#   bucket_prefix = "meu-bucket-"
#   force_destroy = true

#   tags = {
#     Name = "bucket-local"
#   }
# }

resource "null_resource" "create_bucket" {
  provisioner "local-exec" {
    command = "awslocal s3 mb s3://meu-bucket-local"
  }
}