# Private Application Gateway instance

The current available SKUs `Standard_v2` and `WAF_v2` doesn't support truly private Application Gateway instances. Meaning,
there is no way we can restrict the Application Gateway instance to be assigned with a public IP. However, we can restrict the
Application Gateway instance to be exposed only on the private IP address by some workarounds.
- Creating listeners to listen on private IP address only.
- Using NSG to restrict the inbound traffic to the Application Gateway instance.

In order to enable Private Application Gateway instance, while creating select the option `Private and Public`. This will force the
users to input a static `private IP address` that will be assigned to the Application Gateway instance. This IP address must be
within the range of the mandatory `subnet` assigned to the Application Gateway instance.


While using terraform, the below input variables are particularly important in case of private Application Gateway instance:

```hcl
# When this is true, the Application Gateway listener will be created to listen on the private IP address only.
appgw_private = true
# Subnet associated with the Application Gateway instance.
subnet_id = "/subscriptions/<subscription-id>/resourceGroups/<rg-name>/providers/Microsoft.Network/virtualNetworks/<vnet-name>/subnets/<subnet-name>"
# Static private IP address that will be assigned to the Application Gateway instance.
private_ip_address = "10.0.20.8"
```

## Assign Custom Private DNS

By default, Azure doesn't assign any Private DNS record to the Application Gateway instance. However, we can create an
A-record in our custom Private DNS zone and assign it to the Application Gateway instance (`private ip address`).
This will enable the users to refer to the Application Gateway instance using the custom DNS name.

```hcl
custom_private_dns_record = {
  name                  = "apgw"
  private_dns_zone_name = "<private-dns-zone-name>"
  private_dns_zone_rg   = "<private-dns-zone-rg>"
}
```

## TLS Termination
If we want the Application Gateway to terminate the TLS connection, this can be configured on the listener that refers to the
private IP configuration.

To enable, end-to-end tls encryption, we can enable TLS on the backend pool. This will ensure that the traffic between the
application gateway and the backend servers is encrypted.

### TLS Certificates
Application Gateway can refer to the certificates required to establish the TLS connection by
- Uploading them directly to the Application Gateway instance as base64 encode data
- Referencing the certificates stored in the Key Vault

#### Certificates in Key Vault

**Note**:
- While using `terraform`, it only supports certificates stored in the Key Vault as `secrets` and not as `certificates`.
- While using the `portal`, The keyvault using RBAC permission model is not supported. The keyvault must be using the `access policy` permission model.

Following steps must be followed to refer to the certificates stored in the Key Vault:
- A user assigned managed identity must be created and assigned to the Application Gateway instance.
- The above MSI must be assigned role to read the secrets from the Key Vault. This requires the `Key Vault` to enable RBAC.
- The certificate must be in the `.pfx` format and must not have a password.
- The pfx formatted certificate must be base64 encoded and stored in the Key Vault as a `secret` and **not** as a `certificate.
- In case the certificate is self-signed or not issued by a trusted CA, the certificate must be imported to the
   `Trusted Root Certification Authorities` of the browsers or other clients that would be accessing the Application Gateway.

#### Create Self signed certs using open-ssl
```bash

### Create CA
CANAME="Launch-RootCA"
mkdir $CANAME
cd $CANAME
# CA Private Key
openssl genrsa -aes256 -out $CANAME.key 4096

# CA Certificate. This must be added to the trust store of the clients
openssl req -x509 -new -nodes -key $CANAME.key -sha256 -days 1826 -out $CANAME.crt \
  -subj '/CN=Launch Root CA/C=OH/ST=Cleveland/L=Cleveland/O=Launch'


# Create Server Certificate
# Any server you want to set up TLS on, you need to provision private key and CSR. The CSR is then signed by the CA.

MYCERT=apgw.ado-k8s.launchbynttdata.com
# Create a private key and a CSR
openssl req -new -nodes -out $MYCERT.csr -newkey rsa:4096 -keyout $MYCERT.key \
  -subj '/CN=apgw/C=OH/ST=Cleveland/L=Cleveland/O=Launch'

# Add SANs
cat > $MYCERT.v3.ext << EOF
authorityKeyIdentifier=keyid,issuer
basicConstraints=CA:FALSE
keyUsage = digitalSignature, nonRepudiation, keyEncipherment, dataEncipherment
subjectAltName = @alt_names
[alt_names]
DNS.1 = apgw.ado-k8s.launchbynttdata.com
EOF

# Sign the server certificate using the CA private key
# -extfile is required to add SANs
# Output is the signed cert in pem format
openssl x509 -req -in $MYCERT.csr -CA $CANAME.crt -CAkey $CANAME.key -CAcreateserial -out $MYCERT.crt -days 730 \
  -sha256 -extfile $MYCERT.v3.ext



# Combine the certificate and private key
#Some servers and key vaults need the certificate and private key to be in a single file.
# Below command combines the certificate and private key into a single file.

cat $MYCERT.crt $MYCERT.key > $MYCERT.pem

# Convert to pfx
# PKCS12 is another certificate format used by some servers. Below command converts the certificate and private key in PEM to pfx format.

# -des3 is not required while exporting because it is encrypted by default
# Some server mandate use of export password. so provide a password as `password`
# --passout pass: is used to provide empty password
openssl pkcs12 -export -des3 -out $MYCERT.pfx -inkey $MYCERT.key -in $MYCERT.crt -certfile $CANAME.crt -passout pass:
```

#### Upload to Key Vault as secret
```bash
SECRET_DATA=$(cat $MYCERT.pfx | base64)
az keyvault secret set --vault-name <key-vault-name> --name <secret-name> --value $SECRET_DATA
```

At this point, we are all set to set up TLS on the Application Gateway instance.

```hcl
# Instructs the module to create an User Assigned Managed Identity and assign it to the Application Gateway instance.
create_user_managed_identity = true
# Assigns roles to the MSI to read the secrets from the Key Vault.
role_assignments = {
  key-vault = ["Key Vault Reader", "/subscriptions/4554e249-e00f-4668-9be3-da31ed200163/resourceGroups/dso-k8s-001/providers/Microsoft.KeyVault/vaults/dso-ado-k8s-7990012886"]
}

# Create ssl certificates configurations
# key_vault_secret_id must be a secret. certificate is not working
ssl_certificates_configs = [
  {
    name = "appgw-cert"
    key_vault_secret_id = "https://dso-ado-k8s-7990012886.vault.azure.net/secrets/app-gateway-secret/42ee2edc52b747dd85dfd6b9286413b9"
  }
]

# HTTPS listener to listen on port 443
appgw_http_listeners = [
  {
    name               = "https_listener"
    frontend_port_name = "port_443"
    protocol           = "Https"
    # Hostname same as CN in the certificate and the A-record in the Private DNS zone
    hostname           = "apgw.ado-k8s.launchbynttdata.com"
    # Same name as the ssl_certificates_configs.name
    ssl_certificate_name = "appgw-cert"
  }
]

appgw_routings = [
  {
    name                       = "apim_routing"
    backend_address_pool_name  = "apim_backend_pool"
    backend_http_settings_name = "apim_backend_http_settings"
    # Refers to the https listener above
    http_listener_name         = "https_listener"
    priority = 100
  }
]
```

## Backend Pool

This example shows the APIM instance as the backend pool.

The backend pool can be any service that is accessible to the Application Gateway.
In case of private backends, they should be in the same Vnet as the Application Gateway instance or any Peered Vnet.

The backend pool can be a single instance or a set of instances

Backends can be referred to either by their IP address or FQDN.

```hcl
appgw_backend_pools = [
  {
    name         = "apim_backend_pool"
    fqdns = ["dso-apim-eus-dev-000-apim-000.azure-api.net"]
  }
]
```

## Health Probe
The default health probe would check the health of the backend pool by sending a `GET` request to the `/` path.

### Custom Health Probe

Users can add custom health probes to the Application Gateway instance. This can be done by specifying the `health_probe` block in the module.

```hcl
appgw_probes = [
  {
    name     = "apim_probe"
    protocol = "Https"
    path     = "/dotnet/env"
    interval = 30
    timeout  = 30
    unhealthy_threshold = 3
    pick_host_name_from_backend_http_settings = true
    match = {
      # Backend needs authentication. No endpoint without authentication currently available
      status_code = ["401"]
    }
  }
]
```
