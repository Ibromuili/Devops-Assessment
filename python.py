import argparse
import boto3

# Function to list files in an S3 bucket
def list_s3_files(bucket_name):
    s3 = boto3.client('s3')
    response = s3.list_objects_v2(Bucket=bucket_name)
    if 'Contents' in response:
        for obj in response['Contents']:
            print(f"File: {obj['Key']}")

# Function to list versions of an ECS task definition
def list_task_definition_versions(cluster_name, service_name):
    ecs = boto3.client('ecs')
    response = ecs.list_task_definitions(familyPrefix=service_name, status='ACTIVE')
    for task_def_arn in response['taskDefinitionArns']:
        print(f"Task Definition ARN: {task_def_arn}")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="AWS CLI Tool")
    subparsers = parser.add_subparsers(help="Subcommands")

    # Command to list S3 files
    parser_s3 = subparsers.add_parser("list-s3-files", help="List files in an S3 bucket")
    parser_s3.add_argument("bucket_name", help="Name of the S3 bucket")
    parser_s3.set_defaults(func=list_s3_files)

    # Command to list ECS task definition versions
    parser_ecs = subparsers.add_parser("list-ecs-versions", help="List versions of an ECS task definition")
    parser_ecs.add_argument("cluster_name", help="Name of the ECS cluster")
    parser_ecs.add_argument("service_name", help="Name of the ECS service")
    parser_ecs.set_defaults(func=list_task_definition_versions)

    args = parser.parse_args()
    args.func(**vars(args))
