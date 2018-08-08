import boto3

def role_arn_to_session(**args):
    """
    Usage :
        session = role_arn_to_session(
            RoleArn='arn:aws:iam::012345678901:role/example-role',
            RoleSessionName='ExampleSessionName')
        client = session.client('sqs')
    """
    client = boto3.client('sts',
        aws_access_key_id=os.environ['AWS_ACCESS_KEY_ID'],
        aws_secret_access_key=os.environ['AWS_SECRET_ACCESS_KEY']
    )

    response = client.assume_role(**args)
    aws_access_key_id=response['Credentials']['AccessKeyId']
    aws_secret_access_key=response['Credentials']['SecretAccessKey']
    aws_session_token=response['Credentials']['SessionToken']

    return { "aws_access_key_id" : aws_access_key_id , "aws_secret_access_key" : aws_secret_access_key, "aws_session_token" : aws_session_token }

def validate_inputs():
    """
    Check that the minimum env vars have been set
    """
    valid=True
    for var in ('AWS_ACCESS_KEY_ID','AWS_SECRET_ACCESS_KEY', 'AWS_DEFAULT_REGION', 'AWS_ATHENA_S3_OUTPUT'):
        if os.environ.get(var, '') == '':  # default to empty string
            print ("Environment variable '{0}' is not set".format(var) )
            valid = False
    return valid

def get_DSN():
    aws_kms_key           = os.environ.get('AWS_S3_KMS_KEY',        '')
    aws_access_key_id     = os.environ.get('AWS_ACCESS_KEY_ID',     '')
    aws_secret_access_key = os.environ.get('AWS_SECRET_ACCESS_KEY', '')
    aws_region            = os.environ.get('AWS_DEFAULT_REGION',    '')
    aws_role_arn          = os.environ.get('AWS_ROLE_ARN',          '')
    aws_mfa_serial_number = os.environ.get('AWS_MFA_SERIAL_NUMBER', '')
    aws_athena_s3_output  = os.environ.get('AWS_ATHENA_S3_OUTPUT' , '')
    aws_session_token     = ''

    #Assume an STS role
    if aws_role_arn != '' :
        # Get the MFA token from your device, if needed
        mfa_token_code = '' if aws_mfa_serial_number == '' else input()
        temp_creds = role_arn_to_session(
            RoleArn         = aws_role_arn,
            RoleSessionName = 'AthenaSessionName',
            SerialNumber    = aws_mfa_serial_number,
            TokenCode       = mfa_token_code,
        #    DurationSeconds=28800 # 8 hours
        )
        aws_access_key_id      = temp_creds["aws_access_key_id"]
        aws_secret_access_key  = temp_creds["aws_secret_access_key"]
        aws_session_token      = temp_creds["aws_session_token"]


    DSNTemplate="Driver=Simba Athena ODBC Driver 64-bit;UID={};PWD={};AwsRegion={};S3OutputLocation={};AuthenticationType=IAM Credentials;"
    DSN = DSNTemplate.format(aws_access_key_id,
                             aws_secret_access_key,
                             aws_region,
                             aws_athena_s3_output)

    if aws_kms_key != '' :
        DSN += 'S3OutputEncOption=SSE_KMS;S3OutputEncKMSKey={};'.format(aws_kms_key)
    if aws_session_token != '' :
        DSN += 'SessionToken={};'.format(aws_session_token)
    return DSN
