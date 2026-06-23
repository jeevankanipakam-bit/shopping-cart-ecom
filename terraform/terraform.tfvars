region = "us-west-2"

vpc_cidr      = "10.0.0.0/16"
subnet_cidr   = "10.0.1.0/24"
subnet_cidr_b = "10.0.2.0/24"

vpc_name         = "my-vpc"
subnet_name      = "public-subnet"
igw_name         = "my-igw"
route_table_name = "public-route-table"

ami           = "ami-02166c47d457c16a3"
instance_type = "t3.micro"

key_name           = "terraform-key"
ec2_ssh_public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDRVADKiu9teyt2f3vl+igT2C8cbsRYuNCQjh/AgN4VBorpjWlD886bKniq/ICuy5yNdMyU3ysdOt0Dhg8RWZNTN6oN32TqDIa0CnBIdpH6LAn811uyKxxWeJ6u5eGP4hQXZ727qlagoC1dHGU8TEAk+qXxCXtzu697kFHREiCfogYHkPlurZ99mX1Hn7H/j1VXPahosSRrfC/pyqejqcOUAz9Y4UTMv/AQFQAhxIVW37yHu7EMWiK14vYzm0H4PnMlvinVVWp7iQgyRWNoe4brZ5cKMx2mkEa10Z6GhRZOrgAq241J5Tj/VGxCFPGCOjWLoblfB78sfi8ppLSB8qfD/pnd46JgROVjtHgxeyR8rMrmBVClMsZEZ0VCipZGo4ym3qxwnjZ/6zLZbFqBtBs0pbhlL+nbQaKXSmlzbTdjm5GYXKuh2rzyloFgrVYCAUUeC+MAvt8JFfezFUA4hiihlnhUlUZf3WVBZ8AKq1JweFjF2pTWZLmVr0zA0a99W6lXzVU6YLPu5MisCbHB8uyFcKnI9mIpyoAWpc1cohrgg3WghZYuDNBXoen9vu/wVsfJzzam7wx5elXnxnU8Ym4zs4UPAqEbpwq6rUuQZpodRkXkbhoc9YXJ2YRcCXkcWeLjKa5fd+tWZ4c1Za/zPtUMwRNACPvSAv2tgY2rePCshQ== user@ODL00545"

github_repo_url = "https://github.com/jeevankanipakam-bit/shopping-cart-ecom.git"

ecr_repository_name = "shopping-cart-ecom"