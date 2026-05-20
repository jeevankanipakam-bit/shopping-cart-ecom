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

key_name        = "terraform-key"
public_key_path = "~/.ssh/id_rsa.pub"

github_repo_url = "https://github.com/jeevankanipakam-bit/shopping-cart-ecom.git"