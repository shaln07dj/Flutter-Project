import 'package:flutter/material.dart';
import 'dart:convert';

class Record {
  final String? email;
  final String? file;
  final String? name;
  final String? skyflowId;

  Record({this.email, this.file, this.name, this.skyflowId});

  factory Record.fromJson(Map<String, dynamic> json) {
    return Record(
      email: json['email'],
      file: json['file'],
      name: json['name'],
      skyflowId: json['skyflow_id'],
    );
  }
}

class FileDetails extends StatelessWidget {
  const FileDetails({super.key, this.screenWidth});
  final screenWidth;

  @override
  Widget build(BuildContext context) {
    var data = ''' {
      
      "records": [
        {
          "fields": {"skyflow_id": "16d5d54c-0dc0-42dc-a8a8-3b3e3f6f028b"}
        },
        {
          "fields": {
            "email": "mihir@gmail.com",
            "file":
                "https://try-sb1-uw2-ebfc9bee4242.s3.us-west-2.amazonaws.com/o19b211691e14cc68ad2161218eba16a/record_file/a833746b03874c6783f06d2f160355c0/q69098808fd5411d84d3f083c15420c6/1cbe0829-a445-40b3-a985-797e363abcb8/971c419dd609331343dee105fffd0f4608dc0bf2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYJ4BODYRMYK3LH4W%2F20231030%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20231030T071105Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&response-content-disposition=attachment&X-Amz-Signature=caaa62cd6d865ddf172d8c7c84a1b65841b37ab8999c9c9b50549111c2add693",
            "name": "Mihir",
            "skyflow_id": "1cbe0829-a445-40b3-a985-797e363abcb8"
          }
        },
        {
          "fields": {"skyflow_id": "2cf2a64f-b6cd-4abd-81b6-37470e9bc207"}
        },
        {
          "fields": {
            "email": "flashhy@gmail.com",
            "name": "Flash Thompson",
            "skyflow_id": "32b45d25-063b-4192-899e-030f42e759aa"
          }
        },
        {
          "fields": {
            "email": "itsbarrrrry@gmail.com",
            "name": "Bary Allen",
            "skyflow_id": "51e06f5e-4783-473f-8261-62e186b6d4d2"
          }
        },
        {
          "fields": {"skyflow_id": "5317c128-c2c1-4260-9e99-590ffab855c3"}
        },
        {
          "fields": {
            "email": "shubhman@gmail.com",
            "file":
                "https://try-sb1-uw2-ebfc9bee4242.s3.us-west-2.amazonaws.com/o19b211691e14cc68ad2161218eba16a/record_file/a833746b03874c6783f06d2f160355c0/q69098808fd5411d84d3f083c15420c6/56635370-f97a-479f-b798-c105174c1dd4/971c419dd609331343dee105fffd0f4608dc0bf2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYJ4BODYRMYK3LH4W%2F20231030%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20231030T071105Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&response-content-disposition=attachment&X-Amz-Signature=7377dffb43827198e2bc184db61fb63a95be82341732dbb87ee62fcdf9a6bc1a",
            "name": "Shubhman",
            "skyflow_id": "56635370-f97a-479f-b798-c105174c1dd4"
          }
        },
        {
          "fields": {
            "email": "shubhman@gmail.com",
            "name": "Shubhman",
            "skyflow_id": "5b298aa3-589a-4fbf-880a-526aa069dfde"
          }
        },
        {
          "fields": {
            "email": "rohit@gmail.com",
            "name": "Rohit",
            "skyflow_id": "67e1b42a-a2c1-4095-9b8d-5c89ee4e9b0e"
          }
        },
        {
          "fields": {
            "email": "pankaj@nestfuel.com",
            "file":
                "https://try-sb1-uw2-ebfc9bee4242.s3.us-west-2.amazonaws.com/o19b211691e14cc68ad2161218eba16a/record_file/a833746b03874c6783f06d2f160355c0/q69098808fd5411d84d3f083c15420c6/6b4ec0b8-9814-4651-bf71-cf1295ade3ed/971c419dd609331343dee105fffd0f4608dc0bf2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYJ4BODYRMYK3LH4W%2F20231030%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20231030T071105Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&response-content-disposition=attachment&X-Amz-Signature=abc54b4b5a0b340c62e7147920a3f6de7a593ac6dda5cb3c72dee5c5fb951a3c",
            "name": "Pankaj",
            "skyflow_id": "6b4ec0b8-9814-4651-bf71-cf1295ade3ed"
          }
        },
        {
          "fields": {
            "email": "shubhman@gmail.com",
            "name": "Shubhman",
            "skyflow_id": "7ad3110b-6775-467c-adce-9942406c5685"
          }
        },
        {
          "fields": {
            "email": "shubhman@gmail.com",
            "file":
                "https://try-sb1-uw2-ebfc9bee4242.s3.us-west-2.amazonaws.com/o19b211691e14cc68ad2161218eba16a/record_file/a833746b03874c6783f06d2f160355c0/q69098808fd5411d84d3f083c15420c6/7b0286b9-a7fa-4f04-bfff-3a2106252b57/971c419dd609331343dee105fffd0f4608dc0bf2?X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=AKIAYJ4BODYRMYK3LH4W%2F20231030%2Fus-west-2%2Fs3%2Faws4_request&X-Amz-Date=20231030T071105Z&X-Amz-Expires=900&X-Amz-SignedHeaders=host&response-content-disposition=attachment&X-Amz-Signature=b0540915c29c6f4babac3faa60211832c27cf123bcc68d848291e917ea80611e",
            "name": "Shubhman",
            "skyflow_id": "7b0286b9-a7fa-4f04-bfff-3a2106252b57"
          }
        },
        {
          "fields": {"skyflow_id": "7caa9d96-8ed0-48c1-9e67-35e4730db826"}
        },
        {
          "fields": {"skyflow_id": "835121ea-9411-4d4d-b9ec-be736345c6e4"}
        },
        {
          "fields": {"skyflow_id": "9047f6d7-77f7-41f8-9dd1-16301bb08e57"}
        },
        {
          "fields": {
            "email": "stokes@gmail.com",
            "name": "Stokes",
            "skyflow_id": "9300ac3a-5d4b-42f4-97e2-bf6866b1e5e4"
          }
        },
        {
          "fields": {"skyflow_id": "966cdb01-d656-40fe-96e1-3eb9cd9b3f70"}
        },
        {
          "fields": {"skyflow_id": "9901155b-4665-49dd-9fda-b8114415dc10"}
        },
        {
          "fields": {"skyflow_id": "99aac256-f358-4a21-8a39-2b75e9555f20"}
        },
        {
          "fields": {
            "email": "kane@gmail.com",
            "name": "Kane",
            "skyflow_id": "cd39c3d2-189f-4f7b-8cd1-79c7291012f9"
          }
        },
        {
          "fields": {
            "email": "shubhman@gmail.com",
            "name": "Shubhman",
            "skyflow_id": "d1418242-94be-46f3-87bf-027cd16736b2"
          }
        },
        {
          "fields": {
            "email": "ishowspeed@gmail.com",
            "name": "Ishowspeed",
            "skyflow_id": "d7486180-93a8-409f-b3a1-717c77329194"
          }
        },
        {
          "fields": {"skyflow_id": "d9f44922-03ff-4672-b7db-9e831f2b1d31"}
        },
        {
          "fields": {
            "email": "virat@gmail.com",
            "name": "Virat",
            "skyflow_id": "dde49da0-e6e9-4bc9-87ee-97357eeb26cc"
          }
        },
        {
          "fields": {"skyflow_id": "e112ce95-20f5-4664-9f22-79a2895d2ec1"}
        }
      ]
    }''';
    var records = json.decode(data)['records'];
    return Center(
      child: SizedBox(
        width: screenWidth,
        child: ListView.builder(
          itemCount: records.length,
          itemBuilder: (BuildContext context, int index) {
            Record record = Record.fromJson(records[index]['fields']);
            return Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5.0),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Email: ${record.email ?? ''}'),
                    Text('Name: ${record.name ?? ''}'),
                    record.file != null
                        ? Image.network(record.file!)
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
