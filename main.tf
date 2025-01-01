module "certificate" {
  source      = "app.terraform.io/ptonini-org/acm-certificate/aws"
  version     = "~> 1.0.0"
  domain_name = var.domain_name
  zone_id     = var.zone_id
}

resource "aws_api_gateway_domain_name" "this" {
  certificate_arn = module.certificate.this.arn
  domain_name     = var.domain_name
}

resource "aws_api_gateway_base_path_mapping" "this" {
  api_id      = var.api_id
  stage_name  = var.stage_name
  domain_name = aws_api_gateway_domain_name.this.domain_name
}

module "dns_record" {
  source  = "app.terraform.io/ptonini-org/route53-record/aws"
  version = "~> 1.0.0"
  count   = var.zone_id == null ? 0 : 1
  name    = aws_api_gateway_domain_name.this.domain_name
  zone_id = var.zone_id
  alias = {
    name    = aws_api_gateway_domain_name.this.cloudfront_domain_name
    zone_id = aws_api_gateway_domain_name.this.cloudfront_zone_id
  }
}