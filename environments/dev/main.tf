# ==============================================================================
# AIONOS DEV ENVIRONMENT - ROOT INFRASTRUCTURE ORCHESTRATOR
# Enterprise Domain-Driven Modular Layout
# ==============================================================================

locals {
  default_tags = {
    env                = "dev"
    environment        = "dev"
    cost_center        = "engineering"
    dataClassification = "confidential"
    managed_by         = "terraform"
    owner              = "devops"
    product            = "holosport"
    project            = "aionos-microservices"
    team               = "engineering"
  }
}

