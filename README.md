
# AWS Data Processing Pipeline

This project is an AWS-based data processing pipeline designed to extract, process, and analyze data in batch. The pipeline uses several AWS services, including Lambda, Glue, Athena, and QuickSight.

## Pipeline Architecture
![AWS pipeline diagram](Image/aws_pipeline.png)

1. **EventBridge**: Triggers the process daily at 10 AM UTC+1 (cron schedule).
2. **Lambda (Extract Data)**: Extracts data from an external source via API Gateway.
3. **S3**: Stores raw and processed data.
4. **Lambda (Process Data)**: Processes the raw data and stores it.
5. **Glue Crawler**: Analyzes the processed data and updates the data catalog.
6. **Athena**: Allows querying the processed data.

## AWS Services Used

- **EventBridge**: For task scheduling.
- **Lambda**: For data extraction and processing.
- **API Gateway**: For interaction with the external API.
- **S3**: For storing raw and processed data.
- **Glue**: For data discovery and cataloging.
- **Athena**: For data analysis.

## APIs Used

### Batch API: JSONPlaceholder
JSONPlaceholder is a fake REST API used to simulate batch data in this project. It provides simple endpoints to fetch test data such as users, posts, and comments. This API is used to extract data via API Gateway and process it in the AWS pipeline.

**Link**: [JSONPlaceholder](https://jsonplaceholder.typicode.com)

## Project Structure

- **terraform/**: Folder containing Terraform configuration files.
- **terraform/modules**: the modules used to create the AWS infrastructure, each module represents an AWS service.

## Instructions to Deploy the Pipeline

Follow these steps to deploy the data pipeline using Terraform:

### 1. Install Terraform
Ensure that Terraform is installed on your local machine. Follow the official documentation for installation:
[Terraform Installation Guide](https://learn.hashicorp.com/tutorials/terraform/install-cli)

### 2. Clone the Repository
Clone this repository to your local machine:
```bash
git clone <repository_url>
cd <repository_folder>
```

### 3. Configure AWS CLI
Ensure your AWS CLI is configured with the appropriate access credentials.
If you haven't configured it yet, you can do so by running:
```bash
aws configure
```

### 4. Initialize Terraform
Navigate to the Terraform folder and initialize the working directory.
```bash
cd terraform
terraform init
```

### 5. Create a Terraform Plan
Run the following command to create an execution plan:
```bash
terraform plan
```

### 6. Apply the Plan
Apply the Terraform plan to create the resources on AWS.
```bash
terraform apply
```

### 7. Monitor the Process
Once the pipeline is deployed, monitor the logs and data flow. Use the AWS Console for insights into the following:
- Lambda function logs
- Glue crawler job status
- Athena query results

### 8. Cleanup
To remove the resources, you can use the following Terraform command:
```bash
terraform destroy
```

Enjoy this AWS-based data processing pipeline!

