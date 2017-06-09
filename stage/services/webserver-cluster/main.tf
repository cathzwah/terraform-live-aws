terraform {
    required_version = ">= 0.9"

    backend "s3" {
        bucket = "my.terraform.example"
        key    = "stage/services/webserver-cluster/terraform.tfstate" 
        region = "eu-central-1"
        dynamodb_table = "lock.example"
    }
}

provider "aws" {
    region = "${var.aws_region}"
}

module "webserver_cluster" {
    source = "../../../modules/services/webserver-cluster"
    # if using git
    # source = "git::git@github.com:cathzwah/terraform-aws.git//webserver-cluster?ref=v0.0.1"

    aws_region             = "${var.aws_region}"
    cluster_name           = "${var.cluster_name}"
    db_remote_state_bucket = "${var.db_remote_state_bucket}"
    db_remote_state_key    = "${var.db_remote_state_key}"


    # cluster_name           = "webservers-stage"
    # db_remote_state_bucket = "my.terraform.example"
    # db_remote_state_key    = "stage/data-stores/terraform.tfstate"

    ami           = "ami-060cde69"
    instance_type = "t2.micro"
    min_size      = 2
    max_size      = 2
}


resource "aws_security_group_rule" "allow_testing_inbound" {
    type = "ingress"
    security_group_id = "${module.webserver_cluster.elb_security_group_id}"

    from_port   = 12345 
    to_port     = 12345 
    protocol    = "tcp" 
    cidr_blocks = ["0.0.0.0/0"]
}