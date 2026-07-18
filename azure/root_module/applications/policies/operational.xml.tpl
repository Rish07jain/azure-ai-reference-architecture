<policies>
    <inbound>
        <!-- Enforce Role-Based Access Control inside the JWT claims array -->
        <choose>
            <when condition="@(!context.Request.Headers.GetValueOrDefault("Authorization").Split(' ')[1].AsJwt().Claims.GetValueOrDefault("roles", "").Contains("PlatformGPT.PowerUser"))">
                <!-- Apply tighter throttling rules to standard users -->
                <rate-limit-by-key calls="50" duration="60" counter-key="@(context.Request.Headers.GetValueOrDefault("Authorization").Split(' ')[1].AsJwt()?.Subject)" />
            </when>
            <otherwise>
                <!-- Relaxed rate limit for designated Power Users -->
                <rate-limit-by-key calls="500" duration="60" counter-key="@(context.Request.Headers.GetValueOrDefault("Authorization").Split(' ')[1].AsJwt()?.Subject)" />
            </otherwise>
        </choose>
        
        <!-- Inject validated user telemetry headers down to the internal NGINX compute plane -->
        <set-header name="X-User-Principal" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Authorization").Split(' ')[1].AsJwt()?.Subject)</value>
        </set-header>
        <set-header name="X-User-Email" exists-action="override">
            <value>@(context.Request.Headers.GetValueOrDefault("Authorization").Split(' ')[1].AsJwt()?.Claims.GetValueOrDefault("unique_name", "Unknown"))</value>
        </set-header>

        <set-backend-service base-url="${backend_url}" />
    </inbound>
</policies>