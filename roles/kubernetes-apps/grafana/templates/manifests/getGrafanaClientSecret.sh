#!/bin/bash
hyperauthserver={{ grafana_hyperauth_url }}
hyperauthrealm={{ grafana_hyperauth_realm }}

#Get Admin Token
token=$(curl -X POST 'http://{{ keycloak }}:8080/auth/realms/master/protocol/openid-connect/token' \
 -H "Content-Type: application/x-www-form-urlencoded" \
 -d "username=admin" \
 -d 'password=admin' \
 -d 'grant_type=password' \
 -d 'client_id=admin-cli' | jq -r '.access_token')

clientid=$(curl -i -X GET \
   -H "Authorization:Bearer $token" \
 'http://{{ keycloak }}:8080/auth/admin/realms/tmax/clients?clientId=grafana' | grep id | cut -f 2 -d ':' | cut -f 2 -d '"' | sed 's/"/ /g')

clientsecret=$(curl -i -X GET \
   -H "Authorization:Bearer $token" \
 'http://{{ keycloak }}:8080/auth/admin/realms/tmax/clients/grafana/client-secret' | grep value | cut -f 3 -d ':' | cut -f 1 -d '}' | sed 's/"/ /g')

echo $clientsecret
