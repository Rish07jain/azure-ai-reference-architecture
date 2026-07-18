# Secure Enterprise AI Platform - Azure Architecture Specification

## 1. High-Level Architecture Approach
This repository houses the Infrastructure as Code (IaC) scaffold for a secure, multi-environment enterprise AI platform hosted on Azure. The platform is designed around a strict **Zero Trust Network Architecture**, isolating compute, data engineering, and generative AI resources completely from the public internet[cite: 1]. 

The platform supports a production-ready application lifecycle[cite: 1]:
*   **Ingestion & RAG Pipeline:** Secure, network-isolated background workloads (e.g., Kubernetes CronJobs) handle incremental data syncs from internal SaaS boundaries (like Confluence), streaming vectorized knowledge securely into backend storage layers[cite: 1].
*   **Serving Path:** End-users traverse a secure edge-to-compute boundary where API orchestration layers validate, throttle, and route traffic to localized application containers[cite: 1].

---

## 2. Advanced Networking & DNS Resolution Model

### Ingress & Backend Pool Routing (App Gateway to APIM)
1. Edge traffic passes through external security boundaries (Cloudflare) down to the **Azure Application Gateway (WAF)** situated in the Hub VNet ingress subnet[cite: 1].
2. The Application Gateway's backend pool targets the private virtual IP of the internal **Azure API Management (APIM)** instance located in the Spoke VNet[cite: 1].
3. Traffic transitions over private network paths via **Private Endpoints / Internal Load Balancer integration**, ensuring the APIM gateway remains entirely hidden from public internet exposure[cite: 1].

### Private Link & Private DNS Zone Topology
To maintain zero public endpoints, every dependent cloud resource utilizes Azure Private Link[cite: 1]:
*   **Target Resources:** Azure AI Foundry, Azure Machine Learning Workspaces, Azure Key Vault, Azure Storage Accounts, and Azure Cosmos DB are paired with dedicated Private Endpoints[cite: 1].
*   **DNS Resolution:** Private DNS Zones (e.g., `privatelink.openai.azure.com`, `privatelink.documents.azure.com`) are linked directly to the Spoke VNet[cite: 1]. 
*   **Internal Resolution Behavior:** Applications natively reference standard public Fully Qualified Domain Names (FQDNs), but internal DNS interception automatically translates these calls to the internal Private Endpoint IPs, completely eliminating data exfiltration risks over public pathways[cite: 1].

### Hybrid DNS Resolution for P2S/S2S VPN Users
*   Remote internal employees and administrators connect securely via a **VPN Tunnel** hitting the Virtual Network Gateway[cite: 1].
*   To seamlessly resolve internal AI application endpoints and private links, VPN client ranges point to an **Azure DNS Private Resolver** (Inbound Endpoint Subnet)[cite: 1].
*   The resolver transparently forwards lookups to the Azure-provided DNS IP (`168.63.129.16`), allowing remote developers and enterprise consumers to resolve `*.azurecr.io` or `*.openai.azure.com` directly to their private cluster IPs without manual hosts file modifications[cite: 1].

---

## 3. API Management (APIM) Architecture & Policies

APIM functions as the secure enterprise gatekeeper for all internal AI microservices, orchestrating traffic down to the internal application components (like the NGINX Ingress and internal AI Chatbot APIs)[cite: 1].

### API Operations
*   `/chat/stream`: Main asynchronous real-time token streaming endpoint for user interaction.
*   `/embeddings`: Vectorization routing operation interacting with downstream Azure OpenAI components.
*   `/sync/status`: Administrative endpoints tracking the state of background RAG data pipelines.

### Policy Enforcement Strategy
APIM policies are compartmentalized into **Global** and **Operational** scopes to enforce governance without code modification:

*   **Global Policies (All APIs):**
    *   *JWT Validation:* Inspects the OAuth2 bearer token passed from the frontend authentication proxy (validating identity against Microsoft Entra ID)[cite: 1].
    *   *CORS & Headers:* Standardizes cross-origin resource sharing boundaries and strips backend infrastructure fingerprinting headers.
    *   *Global Logging:* Generates distributed telemetry sent straight to enterprise analytics mirrors.

*   **Operational Policies (Route-Specific):**
    *   *Rate Limiting & Throttling (by Claims):* Applied strictly to `/chat/stream` and `/embeddings` based on user token group claims to prevent backend LLM compute starvation.
    *   *Backend URL Rewrite:* Dynamically translates public API calls to down-stream private cluster services (`http://nginx-internal.spoke.local`).
    *   *Caching:* Operational caching on vector lookups to lower duplicate token costs on standard system prompts.

---

## 4. Identity, Governance & Secret Management

### Managed Identities & RBAC Strategy
The architecture relies entirely on **User-Assigned Managed Identities** bound to the compute layer (e.g., AKS Pods/App Services), executing a modern credentialless strategy[cite: 1]:
*   **Least-Privilege Roles:** RBAC roles are granularly assigned at the resource group scope. For example, the AI Chatbot's Managed Identity is granted `Cognitive Services User` on Azure AI Foundry and `Azure Cosmos DB Built-in Data Reader` on Cosmos DB.
*   No database passwords or cognitive service master keys are ever hardcoded or injected into application runtime variables.

### Key Vault Architecture
*   **Azure Key Vault** acts as the solitary secure hardware security module (HSM) zone for storing third-party integration secrets (e.g., Confluence APIs, ServiceNow webhooks)[cite: 1].
*   It is provisioned with public network access strictly disabled, accessible only through its Private Endpoint[cite: 1].
*   Workloads dynamically fetch short-lived secret strings at application initialization using their Azure Managed Identity credentials via internal Key Vault Secrets Provider protocols.

---

## 5. CI/CD Architecture via GitHub Enterprise

The lifecycle management utilizes automated workflows segmented strictly by environment boundaries[cite: 1].

### Environment Isolation & Pipeline Secrets
The repository leverages **GitHub Environments** to manage deployments across **Development**, **UAT/Staging**, and **Production** domains[cite: 1]:
*   Each environment maps to a protected state requiring manual approvals from designated engineering leads before code applies to high-tier environments.
*   **Scoped Variables & Secrets:** Environment-specific secrets (e.g., `AZURE_CLIENT_ID`, `AZURE_TENANT_ID`, `AZURE_SUBSCRIPTION_ID`) are configured inside isolated GitHub Environment Vaults. The automation workflow dynamically injects the correct identity credentials depending on the branch context (`main` vs `develop`).

### Execution Runner Strategy
*   To bridge the gap between GitHub Enterprise and network-isolated Azure subnets, pipelines run via **Self-Hosted Azure DevOps/GitHub Runner Agents** provisioned in an isolated subnet inside the Spoke VNet[cite: 1].
*   Runners pull build definitions, communicate securely through the Azure Firewall to build application artifacts, push built container images to the private **Azure Container Registry (ACR)**, and trigger blue-green deployments into the private compute clusters[cite: 1].

---

## 6. Enterprise Baseline & Operational Assumptions

To ensure seamless compliance with corporate infrastructure strategies, this architecture scaffold builds directly upon the following mandated organizational baselines:

### Mandated Case Study Baselines
*   **Azure Landing Zone & Management Groups:** The root subscription hierarchies, global management flags, and corporate policy definitions conform entirely to the pre-existing enterprise Azure Landing Zone architecture.
*   **Identity Provider Integration:** All authentication mechanisms, federated pipelines, and workload tokens natively trust the pre-existing Microsoft Entra ID tenant tenant structure.
*   **Hub-and-Spoke Networking:** Core routing fabrics assume a pre-built centralized Hub Virtual Network containing corporate ExpressRoute/VPN Gateways and baseline transit routing engines[cite: 1].
*   **Source Control & Continuous Integration System:** Enterprise pipelines execute natively out of the organization's existing GitHub Enterprise subscription using OIDC federated trust anchors.
*   **Distributed Logging Matrix:** Log forwarding configurations assume immediate access to the existing enterprise logging and monitoring telemetry plane (e.g., centralized Log Analytics Workspaces).

### Derived Engineering Assumptions
*   **Subscription Isolation:** While structured as a modular dynamic environment loop, it is assumed that Development, UAT, and Production tiers span independent Azure Subscriptions to preserve absolute blast radius isolation.
*   **Transit Firewall Capability:** It is assumed that the pre-existing central Hub network features an Azure Firewall Premium instance capable of performing FQDN application filtering to validate secure RAG tool exfiltration boundaries.

---

## 7. Key Design Trade-offs & Risks

*   **Internal Self-Hosted Runners vs. GitHub Cloud-Hosted Runners:**
    *   *Trade-off:* Using hosted GitHub runners would require opening firewall rules or utilizing complex OIDC IP-whitelisting matrices.
    *   *Reasoning:* Maintaining self-hosted private runners ensures the deployment plane remains fully inside the organizational private network boundary, aligning with high-compliance zero-trust initiatives.
*   **DNS Private Resolver vs. Custom VM DNS Forwarders:**
    *   *Trade-off:* Azure DNS Private Resolver introduces managed service costs compared to running basic BIND/Windows DNS virtual machines.
    *   *Reasoning:* The resolver scales natively without maintenance overhead, guarantees high availability across zones, and natively integrates with Azure Private DNS Zones without complex sync scripts.

---

## 8. AI Assistance Declaration
In absolute alignment with the instructions provided in the case study overview, this architecture specification, repository scaffold mapping, dynamic CI/CD configuration pipelines, and localized parameter engines were designed and optimized with the active support of advanced AI coding assistants (Gemini / Claude / Copilot).