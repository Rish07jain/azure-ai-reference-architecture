<policies>
    <inbound>
        <cors allow-credentials="true">
            <allowed-origins><origin>*</origin></allowed-origins>
        </cors>
        <!-- Enterprise EntraID Token Validation Framework -->
        <validate-jwt header-name="Authorization" failed-validation-httpcode="401" failed-validation-reason="Invalid or Expired Enterprise Access Token">
            <openid-config url="https://login.microsoftonline.com/${tenant_id}/v2.0/.well-known/openid-configuration" />
            <audiences>
                <audience>${api_audience_uri}</audience> <!-- e.g., api://platformgpt-prod -->
            </audiences>
            <issuers>
                <issuer>https://sts.windows.net/${tenant_id}/</issuer>
            </issuers>
            <required-claims>
                <!-- Validating that the client application has the correct scope claim -->
                <claim name="scp" match="any">
                    <value>AI.Chat.ReadWrite</value>
                </claim>
            </required-claims>
        </validate-jwt>
    </inbound>
</policies>