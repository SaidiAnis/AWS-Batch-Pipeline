# AWS Data Processing Pipeline (the project is still ongoing)

This project is an AWS-based data processing pipeline designed to extract, process, and analyze data in batch and near real-time . The pipeline uses several AWS services, including Lambda, Kinesis, Glue, Athena, and QuickSight.

## Pipeline Architecture
![AWS pipeline diagram](Image/aws_pipeline.png)

1. **EventBridge**: Triggers the process daily at 10 AM.
2. **Lambda (Extract Data)**: Extracts data from an external source via API Gateway.
3. **Kinesis Data Streams**: Receives the extracted data and forwards it to Kinesis Data Firehose.
4. **Kinesis Data Firehose**: Sends raw data to an S3 bucket.
5. **Lambda (Process Data)**: Processes the raw data and stores it in another S3 bucket.
6. **Glue Crawler**: Analyzes the processed data and updates the data catalog.
7. **Athena**: Allows querying the processed data.
8. **QuickSight**: Used for data visualization and dashboard creation.

## AWS Services Used

- **EventBridge**: For task scheduling.
- **Lambda**: For data extraction and processing.
- **API Gateway**: For interaction with the external API.
- **Kinesis Data Streams**: For real-time data transmission.
- **Kinesis Data Firehose**: For sending data to S3.
- **S3**: For storing raw and processed data.
- **Glue**: For data discovery and cataloging.
- **Athena**: For data analysis.
- **QuickSight**: For data visualization.

## APIs Used

### Batch API: JSONPlaceholder
JSONPlaceholder is a fake REST API used to simulate batch data in this project. It provides simple endpoints to fetch test data such as users, posts, and comments. This API is used to extract data via API Gateway and process it in the AWS pipeline.

**Link**: [JSONPlaceholder](https://jsonplaceholder.typicode.com)

### API Under Development
A second API is will be used for this project for near-real-time processing. Specific details about this API, including its endpoints and usage, will be documented once the development is complete.

## Project Structure

- **Athena/**: File with the result of a select all command.
- **IAM/**: IAM roles JSON files.
- **lambda/**: Lambda functions used for the project.
- **S3/**: samples of data files on the S3.
- **terraform/**: Folder containing Terraform configuration files.


