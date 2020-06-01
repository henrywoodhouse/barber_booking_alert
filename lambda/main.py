import boto3
import csv
import os
from urllib3 import PoolManager
from twilio.rest import Client

http = PoolManager()
secretsManagerClient = boto3.client(
    'secretsmanager',
    region_name=os.environ['REGION']
)
twilioClient = Client(
    secretsManagerClient.get_secret_value(
        SecretId='TWILIO_ACCOUNT_SID'
    )['SecretString'],
    secretsManagerClient.get_secret_value(
        SecretId='TWILIO_AUTH_TOKEN'
    )['SecretString']
)


def isStoreOpen(url, checkString):
    response = http.request('GET', url)
    if response.data.decode('utf-8').find(checkString) == -1:
        return True
    return False


def importStoreList():
    with open('stores.csv', newline='') as file:
        reader = csv.reader(file)
        return list(reader)


def raiseAlert(url):
    contact_numbers = secretsManagerClient.get_secret_value(
        SecretId='USER_PHONE_NUMBERS'
    )['SecretString'].split(',')

    for contact_number in contact_numbers:
        print("Attempting to send notification to {}".format(contact_number))
        twilioClient.messages.create(
            body="You can book an appointment at {}".format(url),
            from_=secretsManagerClient.get_secret_value(
                SecretId='TWILIO_PHONE_NUMBER'
            )['SecretString'],
            to=contact_number
        )
        print("""A notification that bookings can be made
             at {} has been sent to {}""".format(url, contact_number))


def handler(event, context):
    storeList = importStoreList()
    for dataSet in storeList:
        if isStoreOpen(dataSet[0], dataSet[1]) is True:
            print("Booking is possible at {}".format(dataSet[0]))
            raiseAlert(dataSet[0])
        else:
            print("No booking available at {}".format(dataSet[0]))
