# Creates a Glue catalog database
resource "aws_glue_catalog_database" "db" {
  name = var.database_name
}

# Creates a Glue crawler that will crawl the specified S3 path and store the metadata in the Glue catalog database
resource "aws_glue_crawler" "crawl_users" {
  name          = "crawl_${var.database_name}"
  database_name = aws_glue_catalog_database.db.name
  role          = var.glue_role_arn
  schedule      = var.schedule  # Defines the schedule for the crawler to run, e.g., daily at 11 AM UTC+1

  s3_target {
    path = "s3://${var.bucket_name}/processed/users/"
  }
}
