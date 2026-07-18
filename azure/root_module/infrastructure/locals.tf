locals {
  #------------------------------------------------------------------
  # 1. NETWORK SECURITY GROUP (NSG) POLICIES COMPONENT MATRIX
  #------------------------------------------------------------------
  # We define rules as a deeply structured map grouped by target tier.
  # This makes it easy for an operations engineer to audit cross-subnet rules.
  nsg_rule_matrix = {
    compute = [
      {
        name        = "Allow_APIM_Ingress_To_AKS_API"
        priority    = 100
        direction   = "Inbound"
        access      = "Allow"
        protocol    = "Tcp"
        source      = "10.240.2.0/24"  # APIM / Integration Subnet
        dest        = "10.240.3.0/22"  # AKS Cluster Subnet Space
        dest_ports  = ["443", "6443", "8443"]
      },
      {
        name        = "Allow_VPN_Admin_Direct_Access"
        priority    = 110
        direction   = "Inbound"
        access      = "Allow"
        protocol    = "Tcp"
        source      = "10.10.0.0/16"   # P2S / S2S VPN Client Space
        dest        = "10.240.3.0/22"
        dest_ports  = ["22", "443"]
      }
    ]

    data = [
      {
        name        = "Allow_AKS_Compute_To_Data_EndPoints"
        priority    = 100
        direction   = "Inbound"
        access      = "Allow"
        protocol    = "Tcp"
        source      = "10.240.3.0/22"  # Compute Subnet
        dest        = "10.240.7.0/24"  # Private Endpoints Subnet
        dest_ports  = ["443", "10255"] # HTTPS + Cosmos DB Engine Wire Protocol
      },
      {
        name        = "Deny_All_Cross_Subnet_Exfiltration"
        priority    = 999
        direction   = "Inbound"
        access      = "Deny"
        protocol    = "*"
        source      = "*"
        dest        = "*"
        dest_ports  = ["*"]
      }
    ]
  }

  # ADVANCED PATTERN: Flattening rule matrices for consumption by standard for_each resource blocks
  # This translates our friendly map structure above into a flattened array of unique cryptographic keys.
  flattened_nsg_rules = flatten([
    for subnet_key, rules in local.nsg_rule_matrix : [
      for rule in rules : [
        for port in rule.dest_ports : {
          lookup_key = "${subnet_key}_${rule.name}_${port}"
          subnet     = subnet_key
          name       = "${rule.name}_port_${port}"
          priority   = rule.priority
          direction  = rule.direction
          access     = rule.access
          protocol   = rule.protocol
          source     = rule.source
          dest       = rule.dest
          dest_port  = port
        }
      ]
    ]
  ])

  # A map indexable by the unique lookup_key for direct ingestion into azurerm_network_security_rule
  nsg_rules = { for r in local.flattened_nsg_rules : r.lookup_key => r }


  #------------------------------------------------------------------
  # 2. AZURE PREMIUM FIREWALL POLICY ENGAGEMENT MATRIX
  #------------------------------------------------------------------
  # Groups firewall rules into highly structured application and network layer collections
  firewall_application_collections = {
    "AI-Platform-Egress-Rules" = {
      priority = 100
      action   = "Allow"
      rules = {
        "Allow_Confluence_Data_Ingestion" = {
          source_addresses  = ["10.240.3.0/22"] # AKS Private Workers Subnet[cite: 1]
          destination_fqdns = ["*.atlassian.net", "api.confluence.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        },
        "Allow_Azure_AI_Foundry_Global_Dependencies" = {
          source_addresses  = ["10.240.3.0/22", "10.240.7.0/24"]
          destination_fqdns = ["*.openai.azure.com", "*.cognitiveservices.azure.com", "management.azure.com"]
          protocols = [
            { type = "Https", port = 443 }
          ]
        }
      }
    }
  }

  firewall_network_collections = {
    "Core-Platform-Infrastructure-Rules" = {
      priority = 200
      action   = "Allow"
      rules = {
        "Allow_Internal_DNS_Forwarding" = {
          source_addresses      = ["10.240.0.0/16"]
          destination_addresses = ["168.63.129.16"] # Azure DNS Infrastructure Private Virtual Node
          destination_ports     = ["53"]
          protocols             = ["UDP", "TCP"]
        },
        "Allow_NTP_Time_Sync" = {
          source_addresses      = ["10.240.1.0/24", "10.240.3.0/22"]
          destination_addresses = ["*"]
          destination_ports     = ["123"]
          protocols             = ["UDP"]
        }
      }
    }
  }
}