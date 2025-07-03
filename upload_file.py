import os
import boto3

# Configuration
LOCAL_DIR = '/tmp/localstack/received'
BUCKET_NAME = 'meu-bucket-local'
S3_PREFIX = 'received/'
LOCALSTACK_ENDPOINT = 'http://localhost:4566'

# Initialize S3 client for LocalStack
s3 = boto3.client(
    's3',
    endpoint_url=LOCALSTACK_ENDPOINT,
    aws_access_key_id='test',
    aws_secret_access_key='test',
    region_name='us-east-1'
)

def upload_files(local_dir, bucket, s3_prefix):
    for root, _, files in os.walk(local_dir):
        for filename in files:
            local_path = os.path.join(root, filename)
            relative_path = os.path.relpath(local_path, local_dir)
            s3_key = os.path.join(s3_prefix, relative_path).replace("\\", "/")
            print(f'Uploading {local_path} to s3://{bucket}/{s3_key}')
            s3.upload_file(local_path, bucket, s3_key)

if __name__ == '__main__':
    # Ensure the bucket exists
    try:
        s3.head_bucket(Bucket=BUCKET_NAME)
    except s3.exceptions.NoSuchBucket:
        s3.create_bucket(Bucket=BUCKET_NAME)
    upload_files(LOCAL_DIR, BUCKET_NAME, S3_PREFIX)