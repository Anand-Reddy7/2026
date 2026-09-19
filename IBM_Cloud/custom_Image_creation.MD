## How are you optimizing IBM Cloud custom images?

We export the IBM Cloud custom image to COS in QCOW2 format. A temporary worker VSI downloads that QCOW2 and uses virt-sparsify --compress from libguestfs to create a new sparse, compressed QCOW2. This reduces the physical image artifact by eliminating unnecessary representation of free filesystem blocks and compressing the output, without necessarily changing the guest's logical disk capacity. The optimized QCOW2 is uploaded back to COS and registered as a new IBM Cloud custom image. The temporary VSI, floating IP, SSH key and security-group resources are cleaned up afterward.


# Architecture

```text
                SPECTRUM LSF CUSTOM IMAGE LIFECYCLE

                  IBM Cloud Base OS Image
                           │
                           │ Packer
                           ▼
                  Temporary Build VSI
                           │
                           ├── Provision Spectrum LSF
                           ├── Install dependencies
                           ├── Configure OS / agents
                           └── Validate
                           │
                           ▼
                  Initial Spectrum LSF
                   IBM Custom Image
                           │
                           │ IBM Image Export Job
                           │ --format qcow2
                           ▼
                IBM Cloud Object Storage
                         (COS)
                           │
                           └── spectrum-lsf.qcow2
                                      │
                                      │ Download
                                      ▼
                            Temporary Sparsify VSI
                                      │
                                      │ virt-sparsify
                                      │ --compress
                                      ▼
                           spare_spectrum-lsf.qcow2
                                      │
                                      │ Upload
                                      ▼
                                     COS
                                      │
                                      └── qcow/
                                           │
                                           └── spare_spectrum-lsf.qcow2
                                                        │
                                                        │ image-create
                                                        ▼
                                               Final Optimized
                                               Spectrum LSF
                                               Custom Image
                                                        │
                                                        │
                                      ┌─────────────────┴─────────────────┐
                                      │  Regional Image Distribution      │
                                      │                                   │
                                      ▼                                   ▼
                                  Region 1                            Region 2
                                  us-south                            eu-de
                                      │                                   │
                                      ▼                                   ▼
                              Spectrum LSF Image                  Spectrum LSF Image
                                      │                                   │
                                      └──────────────┬────────────────────┘
                                                     │
                                                     ▼
                                            Additional Regions
                                                     │
                                                     ▼
                                          Validate Regional Copies
                                                     │
                                                     ▼
                                          Make Images Public /
                                          Customer Accessible
                                                     │
                                                     ▼
                                              IBM Cloud Customers
                                                     │
                                    ┌────────────────┼────────────────┐
                                    ▼                ▼                ▼
                               Customer VSI     Customer VSI     Customer VSI
```

# Security Flow

```text
DEV/BUILD IMAGE
      ↓
Automated validation
      ↓
Security scan
      ↓
Compliance checks
      ↓
Functional test
      ↓
Security/Release approval
      ↓
APPROVED IMAGE
      ↓
Regional distribution
      ↓
PUBLIC
```

## How you create and Publish the Images

For our Spectrum LSF images, image creation and customer publication are separate stages. Packer first creates the golden image, and we perform build-level validation to verify the OS, Spectrum LSF packages, dependencies, services, and configuration.

Before promotion, the image goes through vulnerability scanning, OS-hardening and compliance checks. We also verify that no build credentials, temporary SSH keys, tokens, or other sensitive artifacts remain in the image. Build metadata is maintained so that every image can be traced back to its pipeline build, source revision, and security results.

Because our process exports the image to QCOW2 and uses `virt-sparsify --compress`, we don't rely only on the original Packer validation. We register the optimized QCOW2 as a new custom image and launch a test VSI from the final artifact to verify boot, SSH connectivity, filesystem integrity, Spectrum LSF installation, and basic functional behavior.

Once the technical, security, and functional validations are completed, the image goes through the required **OSSC approval process before customer publication**. As part of the OSSC review, we provide an inventory of the software included in the image, including the **software/component name, installed version, and publisher details**. This provides visibility into the software being distributed with the customer image and supports the required open-source, licensing, and compliance review.

Only after the required security, compliance, functional, and OSSC approvals are completed do we promote the image. We then populate the approved image across our supported IBM Cloud regions, verify the regional copies, and finally make the release available for customer consumption.


## Copying Images to Other regions
```shell
#!/bin/bash
API_KEY="xxxxxxxxxxxx"
IMAGE_NAME="anand-gklm-sep12"
OS_VERSION=8

PRIMARY_REGION="us-south"
BUCKET_NAME="custom-image-management"

ibmcloud login --apikey $API_KEY -r $PRIMARY_REGION

# Import image to COS bucket
import_image() {

  ibmcloud is image-create $IMAGE_NAME --file cos://us-south/custom-image-management/anand-gklm-sep12-anand-gklm-sep12.qcow2 --os-name red-$OS_VERSION-amd64
  echo "Image imported to IBM Cloud: $IMAGE_NAME"
}

REGIONS='br-sao ca-tor eu-es eu-gb jp-osa jp-tok us-east'

for region in $REGIONS; do
  ibmcloud target -r $region
  import_image $BUCKET_NAME anand-gklm-sep12-anand-gklm-sep12.qcow2 $IMAGE_NAME
done
```


## Make Images Public
```shell
ibmcloud login --apikey xxxxxxxxxxxxx -r us-south
export iam_token=$(ibmcloud iam oauth-tokens | awk '{print $4}') && echo $iam_token


export image_id=xxxxxxxxxxxxxxxxxxxx
export api_endpoint="https://us-south.iaas.cloud.ibm.com"

curl -X PATCH "$api_endpoint/v1/images/$image_id?generation=2&version=2021-02-26" -H "Authorization: Bearer $iam_token" -d '{"visibility": "public"} '

```