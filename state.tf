terraform{
    backend "s3" {
        bucket = "mohsin-terraform-state"
        encrypt = true
        key = "terraform.tfstate"
        region = "eu-central-1"
    }
}

provider "aws" {
    region = "eu-central-1"
}