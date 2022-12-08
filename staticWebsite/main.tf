# Create a S3 bucket
resource "aws_s3_bucket" "website" {
  bucket = var.bucketname
  acl    = "private"
  policy = file("${path.module}/policy.json")

  website {
    index_document = "index.html"
    error_document = "error.html"
  }
  tags = {
    terraform = "true"
    website_hosting = "true"
  }
}

# upload files to the bucket
resource "aws_s3_bucket_object" "index_object" {
      bucket = var.bucketname
      key = "index.html"
      source = "${path.module}/html/index.html"
      depends_on = [
        aws_s3_bucket.website
      ]
}  

resource "aws_s3_bucket_object" "error_object" {
      bucket = var.bucketname
      key = "error.html"
      source = "${path.module}/html/error.html"
      depends_on = [
        aws_s3_bucket.website
      ]
}


resource "aws_cloudfront_distribution" "s3_distribution" {
  origin {
    domain_name = "${aws_s3_bucket.website.bucket}.s3.amazonaws.com"
    origin_id   = "website"
  }

  enabled             = true
  comment             = "Managed by Terraform"
  default_root_object = "index.html"


  default_cache_behavior {
    allowed_methods  = ["DELETE", "GET", "HEAD", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods   = ["GET", "HEAD"]
    target_origin_id = "website"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "allow-all"
    min_ttl                = 0
    default_ttl            = 3600
    max_ttl                = 86400
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    cloudfront_default_certificate = true
  }
}